import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralised snackbar helpers used across the whole app.
///
/// Usage:
/// ```dart
/// AppSnackbar.success('OTP sent to your email');
/// AppSnackbar.error('Invalid OTP. Please try again.');
/// ```
class AppSnackbar {
  AppSnackbar._();

  // ── Success ───────────────────────────────────────────────────────────────

  static void success(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF2E7D32), // dark green
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  static void error(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFC62828), // dark red
    );
  }

  // ── Info ──────────────────────────────────────────────────────────────────

  static void info(String message, {String title = 'Notification'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF1565C0), // dark blue
      icon: Icons.notifications_outlined,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    IconData? icon,
  }) {
    // Dismiss any snackbar already on screen to prevent stacking.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final resolvedIcon = icon ??
        (backgroundColor == const Color(0xFF2E7D32)
            ? Icons.check_circle_outline
            : Icons.error_outline);

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      icon: Icon(
        resolvedIcon,
        color: Colors.white,
        size: 22,
      ),
      shouldIconPulse: false,
    );
  }
}
