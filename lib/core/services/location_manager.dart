import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Result returned by [LocationManager.fetchLocation].
class LocationResult {
  final bool success;
  final double lat;
  final double lng;
  final String address;
  final String? error;

  const LocationResult._({
    required this.success,
    this.lat = 0,
    this.lng = 0,
    this.address = '',
    this.error,
  });

  factory LocationResult.ok({
    required double lat,
    required double lng,
    required String address,
  }) => LocationResult._(success: true, lat: lat, lng: lng, address: address);

  factory LocationResult.fail(String error) =>
      LocationResult._(success: false, error: error);
}

/// Central service for all location permission and GPS logic.
/// Register once in main.dart / initial bindings, then call anywhere via
/// `LocationManager.to`.
///
/// Handles:
///   • Location service disabled  → snackbar
///   • Permission denied once     → re-request
///   • Permission denied forever  → settings dialog (Android & iOS)
///   • Silent check (no prompt)   → [checkIfGranted]
class  LocationManager extends GetxService {
  static LocationManager get to => Get.find<LocationManager>();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns `true` if location permission is already granted — no dialog shown.
  Future<bool> checkIfGranted() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always ||
        p == LocationPermission.whileInUse;
  }

  /// Ensures permission is granted (requesting if needed) and fetches the
  /// current GPS position + reverse-geocoded address.
  ///
  /// Always returns a [LocationResult] — never throws.
  /// Shows snackbars / settings dialog automatically.
  Future<LocationResult> fetchLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final bool ok = await _ensurePermission();
    if (!ok) return LocationResult.fail('Permission not granted');

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );
      final address = await reverseGeocode(pos.latitude, pos.longitude);
      return LocationResult.ok(
        lat: pos.latitude,
        lng: pos.longitude,
        address: address,
      );
    } catch (e) {
      _snackbar('Location Error', e.toString());
      return LocationResult.fail(e.toString());
    }
  }

  /// Fetches location silently — only if permission is already granted.
  /// Returns `null` if not granted (no dialog, no snackbar).
  Future<LocationResult?> fetchIfGranted() async {
    if (!await checkIfGranted()) return null;
    return fetchLocation();
  }

  /// Converts lat/lng to a human-readable address string.
  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final p = placemarks.first;
      return [p.name, p.subLocality, p.locality, p.administrativeArea]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
    } catch (_) {
      return '$lat, $lng';
    }
  }

  // ── Permission logic ───────────────────────────────────────────────────────

  Future<bool> _ensurePermission() async {
    // 1. Location service (GPS toggle)
    if (!await Geolocator.isLocationServiceEnabled()) {
      _snackbar('Location Off', 'Please enable location services on your device.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // 2. Already granted
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    // 3. Denied forever → open settings
    if (permission == LocationPermission.deniedForever) {
      await _showSettingsDialog(
        'Permission Required',
        'Location access is permanently denied.\nPlease enable it in ${Platform.isIOS ? 'Settings → Privacy → Location Services' : 'Settings → App Permissions'}.',
      );
      return false;
    }

    // 4. Denied once → request
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      await _showSettingsDialog(
        'Permission Required',
        'Location access is permanently denied.\nPlease enable it in ${Platform.isIOS ? 'Settings → Privacy → Location Services' : 'Settings → App Permissions'}.',
      );
      return false;
    }

    _snackbar('Permission Denied', 'Location permission is required to detect your area.');
    return false;
  }

  // ── Settings dialog ────────────────────────────────────────────────────────

  Future<void> _showSettingsDialog(String title, String message) async {
    final bool? open = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(message,
            style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              Platform.isIOS ? 'Open Settings' : 'Settings',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (open == true) await Geolocator.openAppSettings();
  }

  // ── Snackbar helper ────────────────────────────────────────────────────────

  void _snackbar(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.TOP);
  }
}
