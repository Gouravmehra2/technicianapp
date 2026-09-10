import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/core/services/firebase_service.dart';

/// Global auth state — persists token + user across app restarts.
///
/// Register once in main.dart:
/// ```dart
/// await Get.putAsync(() => AuthService().init(), permanent: true);
/// ```
///
/// Read from anywhere:
/// ```dart
/// final auth = AuthService.to;
/// if (auth.isLoggedIn) { ... }
/// ```
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ── Observable state ────────────────────────────────────────────────────────

  final Rx<String?> token = Rx<String?>(null);
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  bool get isLoggedIn => token.value != null && token.value!.isNotEmpty;

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<AuthService> init() async {
    await _loadFromStorage();
    return this;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUser = prefs.getString(_userKey);

      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
      }

      if (savedUser != null && savedUser.isNotEmpty) {
        final decoded = jsonDecode(savedUser) as Map<String, dynamic>;
        user.value = UserModel.fromJson(decoded);
      }

      debugPrint(
        '[AuthService] Loaded from storage — '
        'token: ${isLoggedIn ? "present" : "absent"}, '
        'user: ${user.value?.name ?? "none"}',
      );
    } catch (e) {
      debugPrint('[AuthService] Failed to load from storage: $e');
    }
  }

  // ── Save after login ────────────────────────────────────────────────────────

  Future<void> saveSession({
    required String authToken,
    required UserModel userData,
  }) async {
    token.value = authToken;
    user.value = userData;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, authToken);
      await prefs.setString(_userKey, jsonEncode(userData.toJson()));
      debugPrint('[AuthService] Session saved for ${userData.name}');
    } catch (e) {
      debugPrint('[AuthService] Failed to save session: $e');
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    // Delete the FCM token from Firebase so this device stops receiving
    // push notifications after logout. Do this before clearing auth state.
    try {
      final firebase = Get.find<FirebaseService>();
      await firebase.deleteToken();
    } catch (_) {
      // FirebaseService may not be registered in test environments — safe to ignore.
    }

    token.value = null;
    user.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      debugPrint('[AuthService] Session cleared');
    } catch (e) {
      debugPrint('[AuthService] Failed to clear session: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Whether the technician has completed onboarding and been approved.
  bool get isTechnicianApproved => user.value?.isTechnicianApproved ?? false;

  /// Whether docs were submitted but still under review.
  bool get isTechnicianPending => user.value?.isTechnicianPending ?? false;

  /// Whether some docs were rejected and need re-upload.
  bool get isTechnicianRejected => user.value?.isTechnicianRejected ?? false;

  /// Whether any docs have been submitted (status is non-empty).
  bool get hasSubmittedDocs => user.value?.hasSubmittedDocs ?? false;

  /// Whether no docs have been submitted yet (fresh / not-yet-started account).
  bool get hasNotStartedOnboarding =>
      user.value?.hasNotStartedOnboarding ?? true;
}
