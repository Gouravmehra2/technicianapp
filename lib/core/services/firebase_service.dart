import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/firebase_options.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background message handler — MUST be a top-level function (not a closure or
// instance method). Flutter's isolate constraint requires this.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Ensure Firebase is initialised in the background isolate too.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(
    '[FCM-BG] id=${message.messageId} '
    'title=${message.notification?.title} '
    'data=${message.data}',
  );

  // Route the message to the service for any background processing
  // (e.g. saving to local DB, badge count, etc.)
  await FirebaseService._handleBackgroundMessage(message);
}

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseService — single source of truth for all Firebase operations
// ─────────────────────────────────────────────────────────────────────────────
class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find<FirebaseService>();

  // ── Observable state ─────────────────────────────────────────────────────

  /// The current FCM token (Android) / APNs-backed FCM token (iOS).
  final Rx<String?> fcmToken = Rx<String?>(null);

  /// Whether the user has granted notification permission.
  final RxBool notificationsGranted = false.obs;

  // ── Internal refs ─────────────────────────────────────────────────────────

  // Lazy — must NOT be accessed before Firebase.initializeApp() completes.
  late final FirebaseMessaging _messaging;

  /// Name of the currently active chat screen route.
  /// Set this whenever a chat screen opens so notifications from that
  /// conversation are suppressed while the user can already see the messages.
  String? _activeChatRoute;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initialise Firebase + Messaging. Call once from main().
  ///
  /// ```dart
  /// await Get.putAsync(() => FirebaseService().init(), permanent: true);
  /// ```
  Future<FirebaseService> init() async {
    // 1. Core initialisation
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Assign messaging instance only AFTER Firebase is initialised.
    _messaging = FirebaseMessaging.instance;

    // 2. Register background handler (Android / iOS)
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // 3. Request notification permission
    await _requestPermission();

    // 4. Retrieve device token
    await _fetchToken();

    // 5. Listen for token refreshes (e.g. after app reinstall / token rotation)
    _messaging.onTokenRefresh.listen(_onTokenRefreshed);

    // 6. Set up foreground & tap handlers
    _setupForegroundHandler();
    _setupNotificationTapHandlers();

    // 7. iOS foreground notification presentation
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    debugPrint('[FirebaseService] Initialised. token=${fcmToken.value}');
    return this;
  }

  // ── Permission ────────────────────────────────────────────────────────────

  /// Request notification permission from the OS.
  ///
  /// On Android 13+ this shows the system permission dialog.
  /// On iOS this shows the native notification permission prompt.
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // true = quiet delivery on iOS, no prompt
      sound: true,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    notificationsGranted.value = granted;

    debugPrint(
      '[FirebaseService] Permission status: ${settings.authorizationStatus.name}',
    );
  }

  // ── Token management ──────────────────────────────────────────────────────

  /// Retrieve the device token.
  ///
  /// • Android  → standard FCM registration token.
  /// • iOS (real device) → waits for the APNs token with retries, then gets
  ///   the FCM token which Firebase maps to APNs internally.
  /// • iOS (simulator) → APNs is never available; skipped gracefully.
  Future<void> _fetchToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _getApnsTokenWithRetry();
        if (apnsToken == null) {
          // Simulator or APNs genuinely unavailable — skip FCM token fetch.
          debugPrint(
            '[FirebaseService] APNs token unavailable (simulator or APNs not '
            'ready). Skipping FCM token fetch.',
          );
          return;
        }
        debugPrint('[FirebaseService] APNs token: $apnsToken');
      }

      final token = await _messaging.getToken();
      fcmToken.value = token;
      debugPrint('[FirebaseService] FCM token: $token');
    } catch (e) {
      debugPrint('[FirebaseService] Token fetch error: $e');
    }
  }

  /// Polls for the APNs token up to [maxAttempts] times with an exponential
  /// back-off. Returns null if the token never arrives (e.g. on a simulator).
  Future<String?> _getApnsTokenWithRetry({
    int maxAttempts = 5,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    Duration delay = initialDelay;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;

      debugPrint(
        '[FirebaseService] APNs token not ready — attempt $attempt/$maxAttempts. '
        'Retrying in ${delay.inSeconds}s…',
      );
      await Future.delayed(delay);
      delay *= 2; // exponential back-off: 1s → 2s → 4s → 8s → 16s
    }
    return null;
  }

  /// Called automatically when the FCM token changes (rotation / reinstall).
  Future<void> _onTokenRefreshed(String newToken) async {
    debugPrint('[FirebaseService] Token refreshed: $newToken');
    fcmToken.value = newToken;

    // Push the fresh token to the server if the user is already logged in.
    await _pushTokenToServer(newToken);
  }

  /// A callback that is invoked whenever the token changes after initial load.
  /// Set this from outside (e.g. LoginController / SplashController) to push
  /// the token to your backend without creating a circular dependency.
  ///
  /// ```dart
  /// FirebaseService.to.onTokenUpdated = (token) async {
  ///   await _apiRepo.updateFcmTokenApi(token: token, platform: Platform.isIOS ? 'ios' : 'android');
  /// };
  /// ```
  Future<void> Function(String token)? onTokenUpdated;

  /// Send the token to the backend via the [onTokenUpdated] callback.
  Future<void> _pushTokenToServer(String token) async {
    try {
      await onTokenUpdated?.call(token);
    } catch (e) {
      debugPrint('[FirebaseService] Token push error: $e');
    }
  }

  // ── Foreground notifications ──────────────────────────────────────────────

  /// Handle messages that arrive while the app is in the foreground.
  ///
  /// On Android, FCM does not show a notification heads-up when the app is in
  /// the foreground — we show our own in-app banner here.
  ///
  /// On iOS, foreground presentation is controlled by
  /// `setForegroundNotificationPresentationOptions` (set above).
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[FCM-FG] id=${message.messageId} '
        'title=${message.notification?.title} '
        'data=${message.data}',
      );

      _handleForegroundMessage(message);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Suppress notification if the user is on the chat screen for
    // the same conversation.
    if (_isChatScreen(message)) {
      debugPrint(
        '[FCM-FG] User is on the active chat screen — notification suppressed.',
      );
      return;
    }

    // Show an in-app snackbar / banner for foreground messages.
    _showInAppBanner(
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: message.data,
    );
  }

  /// Returns true when the incoming message is a chat message and the user
  /// is currently viewing that chat conversation.
  bool _isChatScreen(RemoteMessage message) {
    if (_activeChatRoute == null) return false;

    // Convention: chat messages carry { "type": "chat", "chatId": "<id>" }
    // in message.data. Adjust the key names to match your backend payload.
    final type = message.data['type']?.toString();
    if (type != 'chat') return false;

    // If you track the active chatId, compare it here.
    // final chatId = message.data['chatId']?.toString();
    // return chatId != null && chatId == _activeChatId;

    // For now, any chat notification is suppressed while any chat screen is open.
    return true;
  }

  // ── Notification tap handlers ─────────────────────────────────────────────

  /// Handle taps on notifications:
  ///   • App was terminated → `getInitialMessage()` returns the message.
  ///   • App was in background → `onMessageOpenedApp` stream fires.
  void _setupNotificationTapHandlers() {
    // Terminated state — user tapped a notification that launched the app.
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint(
          '[FCM-TERM] App opened from terminated state. '
          'data=${message.data}',
        );
        // Slight delay to ensure the widget tree is mounted before navigation.
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message);
        });
      }
    });

    // Background state — user tapped a notification; app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        '[FCM-BG-TAP] Notification tapped from background. '
        'data=${message.data}',
      );
      _handleNotificationTap(message);
    });
  }

  /// Navigate the user to the correct screen based on the notification payload.
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString();
    final targetRoute = _routeForType(type, data);

    if (targetRoute != null) {
      debugPrint('[FCM] Navigating to $targetRoute');
      Get.toNamed(targetRoute, arguments: data);
    }
  }

  /// Map notification type → app route.
  ///
  /// Extend this switch with any new notification types your backend sends.
  /// The `data` map is the payload from the FCM message — match the keys
  /// your backend uses.
  String? _routeForType(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'chat':
        // Backend sends the target route directly in the payload.
        return data['route']?.toString() ?? AppRoutes.chatSupportScreen;
      case 'job_request':
        return AppRoutes.jobDetailScreen;
      case 'job_accepted':
        return AppRoutes.scheduleJobScreen;
      case 'payment':
        return AppRoutes.walletScreen;
      case 'document_verified':
        return AppRoutes.profileScreen;
      case 'notification':
        return AppRoutes.notificationScreen;
      default:
        return null; // no navigation for unhandled types
    }
  }

  // ── Background message processing (called from top-level handler) ─────────

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Place any background-safe work here:
    // • Update badge count (using flutter_app_badger or similar)
    // • Write to local storage / Hive
    // Avoid UI operations — no widget context available in background isolates.
    debugPrint(
      '[FCM-BG] Processing background message: ${message.messageId}',
    );
  }

  // ── In-app banner ─────────────────────────────────────────────────────────

  void _showInAppBanner({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    if (title.isEmpty && body.isEmpty) return;

    AppSnackbar.info(
      body.isNotEmpty ? body : title,
      title: title.isNotEmpty ? title : 'Notification',
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call this when a chat screen opens to suppress chat notifications.
  ///
  /// ```dart
  /// // In your chat controller's onInit
  /// FirebaseService.to.onChatScreenOpened('/chat-support');
  /// ```
  void onChatScreenOpened(String routeName) {
    _activeChatRoute = routeName;
    debugPrint('[FirebaseService] Chat screen active: $routeName');
  }

  /// Call this when the chat screen closes (controller.onClose).
  ///
  /// ```dart
  /// @override
  /// void onClose() {
  ///   FirebaseService.to.onChatScreenClosed();
  ///   super.onClose();
  /// }
  /// ```
  void onChatScreenClosed() {
    debugPrint('[FirebaseService] Chat screen closed.');
    _activeChatRoute = null;
  }

  /// Returns the current FCM/APNs token, or null if not yet available.
  String? get token => fcmToken.value;

  /// Whether notification permission has been granted.
  bool get isPermissionGranted => notificationsGranted.value;

  /// Manually re-request notification permission.
  ///
  /// Useful if the user previously denied and you want to prompt again
  /// (the OS will not show a new dialog; you must deep-link to Settings).
  Future<AuthorizationStatus> checkPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    notificationsGranted.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    return settings.authorizationStatus;
  }

  /// Force-refresh the FCM token and return the new value.
  ///
  /// Call this after login if the stored token may be stale.
  /// Returns null on iOS simulator where APNs is unavailable.
  Future<String?> refreshToken() async {
    await _fetchToken();
    return fcmToken.value;
  }

  /// Subscribe to a named topic (e.g. 'technicians', 'promotions').
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FirebaseService] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a named topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FirebaseService] Unsubscribed from topic: $topic');
  }

  /// Delete the current FCM token (e.g. on logout so no more messages arrive).
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      fcmToken.value = null;
      debugPrint('[FirebaseService] FCM token deleted.');
    } catch (e) {
      debugPrint('[FirebaseService] Token delete error: $e');
    }
  }
}
