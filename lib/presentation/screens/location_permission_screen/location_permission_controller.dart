import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_service.dart';

class LocationPermissionController extends GetxController {
  final RxString address = ''.obs;
  final RxBool isFetching = false.obs;

  // ── Allow-location flow (from permission screen) ──────────────────────────

  /// Called when the user taps "Allow Location Access".
  /// Handles: denied once, denied forever (settings), service disabled.
  /// On success → navigates to TechnicianHomeScreen.
  Future<void> requestLocationAndFetch() async {
    final bool ok = await _ensurePermission();
    if (!ok) return;

    isFetching.value = true;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final resolvedAddress = await _reverseGeocode(pos.latitude, pos.longitude);
      address.value = resolvedAddress;

      // Persist in the shared service so the home screen can read it.
      LocationService.to.setLocation(
        address: resolvedAddress,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      // Short pause so the dialog text update is visible before closing.
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      address.value = '';
      Get.snackbar(
        'Location Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFetching.value = false;
    }

    // Navigate home only when we have an address.
    if (address.value.isNotEmpty) {
      Get.offAllNamed(AppRoutes.technicianHomeScreen);
    }
  }

  // ── Permission helper ─────────────────────────────────────────────────────

  /// Returns `true` when the app has (or just obtained) location permission.
  /// Handles the three platform edge-cases:
  ///   1. Service disabled   → snackbar, return false
  ///   2. Denied forever     → open app settings, return false
  ///   3. Denied once        → re-request once more, return false if still denied
  Future<bool> _ensurePermission() async {
    // ── Service check ─────────────────────────────────────────────────────
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Off',
        'Please enable location services on your device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // ── Permission check ──────────────────────────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await _openSettings(
        'Permission Required',
        'Location access is permanently denied. '
            'Please enable it in your device settings.',
      );
      return false;
    }

    if (permission == LocationPermission.denied) {
      Get.snackbar(
        'Permission Denied',
        'Location permission is required to detect your area.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true; // whileInUse or always
  }

  // ── Open device app-settings ──────────────────────────────────────────────

  Future<void> _openSettings(String title, String message) async {
    final bool? confirmed = await Get.dialog<bool>(
      _SettingsDialog(title: title, message: message),
      barrierDismissible: false,
    );
    if (confirmed == true) {
      await Geolocator.openAppSettings();
    }
  }

  // ── Geocoding ─────────────────────────────────────────────────────────────

  static Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final p = placemarks.first;
      return [
        p.name,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((s) => s != null && s.isNotEmpty).join(', ');
    } catch (_) {
      return '$lat, $lng';
    }
  }
}

// ─── Settings dialog ──────────────────────────────────────────────────────────

class _SettingsDialog extends StatelessWidget {
  final String title;
  final String message;

  const _SettingsDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // Use a Cupertino-style dialog on iOS for native feel.
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Open Settings',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text(
            'Open Settings',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
