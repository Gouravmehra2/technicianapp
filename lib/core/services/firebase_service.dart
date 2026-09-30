import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

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

  await _showBackgroundNotification(message);

  // Route the message to the service for any background processing
  // (e.g. saving to local DB, badge count, etc.)
  await FirebaseService._handleBackgroundMessage(message);
}

const _notificationChannel = AndroidNotificationChannel(
  'technician_notifications',
  'Technician notifications',
  description: 'Notifications for jobs, messages, and account activity.',
  importance: Importance.high,
);

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  if (message.notification != null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await plugin.initialize(settings: settings);
  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_notificationChannel);

  final title =
      message.notification?.title ?? message.data['title']?.toString();
  final body =
      message.notification?.body ??
      message.data['body']?.toString() ??
      message.data['message']?.toString();
  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }

  await plugin.show(
    id: message.hashCode,
    title: title ?? 'Notification',
    body: body ?? '',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'technician_notifications',
        'Technician notifications',
        channelDescription:
            'Notifications for jobs, messages, and account activity.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: jsonEncode(message.data),
  );
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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _localNotificationsInitialized = false;
  bool _initialized = false;

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

    await _initializeLocalNotifications();

    await _fetchToken();

    // 5. Listen for token refreshes (e.g. after app reinstall / token rotation)
    _messaging.onTokenRefresh.listen(_onTokenRefreshed);

    // 6. Set up foreground & tap handlers
    _setupForegroundHandler();
    _setupNotificationTapHandlers();

    // 7. iOS foreground notification presentation
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    debugPrint('[FirebaseService] Initialised. token=${fcmToken.value}');
    _initialized = true;
    return this;
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_notificationChannel);
    _localNotificationsInitialized = true;
  }

  // ── Permission ────────────────────────────────────────────────────────────

  /// Request notification permission from the OS.
  ///
  /// On Android 13+ this shows the system permission dialog.
  /// On iOS this shows the native notification permission prompt.
  Future<AuthorizationStatus> requestNotificationPermission() async {
    if (!_initialized) return AuthorizationStatus.notDetermined;
    var settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    if (Platform.isAndroid &&
        settings.authorizationStatus != AuthorizationStatus.denied) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    notificationsGranted.value = granted;

    debugPrint(
      '[FirebaseService] Permission status: ${settings.authorizationStatus.name}',
    );
    if (granted && fcmToken.value == null) await _fetchToken();
    return settings.authorizationStatus;
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

    _showLocalNotification(
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: message.data,
    );
  }

  /// Handle the equivalent notification delivered over the authenticated
  /// Socket.IO connection while the app is open.
  void handleSocketNotification(dynamic payload) {
    if (payload is! Map) return;
    final notification = payload['notification'];
    if (notification is! Map) return;

    final title =
        notification['title']?.toString() ?? payload['title']?.toString() ?? '';
    final body =
        notification['message']?.toString() ??
        notification['body']?.toString() ??
        payload['body']?.toString() ??
        payload['message']?.toString() ??
        '';
    _showLocalNotification(
      title: title,
      body: body,
      data: Map<String, dynamic>.from(
        (notification['data'] is Map ? notification['data'] : payload) as Map,
      ),
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

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      final targetRoute = _routeForType(data['type']?.toString(), data);
      if (targetRoute != null) Get.toNamed(targetRoute, arguments: data);
    } catch (error) {
      debugPrint(
        '[FirebaseService] Invalid local notification payload: $error',
      );
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
      case 'new_job':
      case 'job_invitation':
      case 'technician_job_request':
      case 'technician_counter_offer':
      case 'admin_counter_offer':
      case 'job_assigned':
      case 'job_rescheduled':
      case 'technician_request_response':
        return AppRoutes.jobDetailScreen;
      case 'job_accepted':
        return AppRoutes.scheduleJobScreen;
      case 'payment':
      case 'wallet_payment':
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
    debugPrint('[FCM-BG] Processing background message: ${message.messageId}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    if (title.isEmpty && body.isEmpty) return Future.value();
    return _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title.isNotEmpty ? title : 'Notification',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'technician_notifications',
          'Technician notifications',
          channelDescription:
              'Notifications for jobs, messages, and account activity.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
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

  Future<void> openNotificationSettings() async {
    final launched = await launchUrl(Uri.parse('app-settings:'));
    if (!launched) {
      debugPrint('[FirebaseService] Unable to open notification settings.');
    }
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
