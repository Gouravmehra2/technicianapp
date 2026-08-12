import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_service.dart';

export 'location_detail_controller.dart' show SaveAsType;

enum SaveAsType { home, office, other }

class LocationDetailController extends GetxController {
  // ── Form ──────────────────────────────────────────────────────────────────

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ── Text controllers ──────────────────────────────────────────────────────

  final TextEditingController searchController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  // ── Reactive state ────────────────────────────────────────────────────────

  final Rx<SaveAsType> selectedSaveAs = SaveAsType.home.obs;
  final RxBool isLocating = false.obs;

  // ── Permission-deny counter (resets when controller is re-created) ────────
  int _denyCount = 0;
  static const int _maxDenyBeforeSettings = 3;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onClose() {
    searchController.dispose();
    houseController.dispose();
    apartmentController.dispose();
    landmarkController.dispose();
    super.onClose();
  }

  // ── Save-as selection ─────────────────────────────────────────────────────

  void selectSaveAs(SaveAsType type) => selectedSaveAs.value = type;

  // ── Search ────────────────────────────────────────────────────────────────

  void onSearchChanged(String value) {
    // Autocomplete can be wired here.
    debugPrint('[LocationDetail] search: $value');
  }

  // ── Use current location ──────────────────────────────────────────────────

  /// Requests GPS permission with full edge-case handling:
  ///   • Service disabled   → snackbar
  ///   • Denied 3× in a row → open app settings (Android & iOS)
  ///   • Denied forever     → open app settings immediately
  ///   • Granted            → reverse-geocode and fill search field
  Future<void> useCurrentLocation() async {
    final bool ok = await _ensurePermission();
    if (!ok) return;

    isLocating.value = true;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final addr = await _reverseGeocode(pos.latitude, pos.longitude);
      searchController.text = addr;

      // Also persist immediately so if the user closes without confirming,
      // the home screen still has the most recent GPS address.
      LocationService.to.setLocation(
        address: addr,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      // Reset deny counter on success.
      _denyCount = 0;
      update();
    } catch (e) {
      Get.snackbar(
        'Location Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLocating.value = false;
    }
  }

  // ── Confirm location ──────────────────────────────────────────────────────

  void confirmLocation() {
    if (!formKey.currentState!.validate()) return;

    // Build a human-readable address from the form fields.
    final parts = <String>[
      if (houseController.text.trim().isNotEmpty) houseController.text.trim(),
      if (apartmentController.text.trim().isNotEmpty)
        apartmentController.text.trim(),
      if (searchController.text.trim().isNotEmpty) searchController.text.trim(),
      if (landmarkController.text.trim().isNotEmpty)
        'Near ${landmarkController.text.trim()}',
    ];
    final fullAddress = parts.join(', ');

    LocationService.to.setLocation(address: fullAddress.isNotEmpty
        ? fullAddress
        : searchController.text.trim());

    // Replace entire back-stack up to home so pressing back from home
    // doesn't loop through the location flow.
    Get.offAllNamed(AppRoutes.technicianHomeScreen);
  }

  // ── Permission helper ─────────────────────────────────────────────────────

  Future<bool> _ensurePermission() async {
    // Service check.
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Off',
        'Please enable location services on your device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Already granted — no need to ask.
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _denyCount = 0;
      return true;
    }

    // Denied forever — go straight to settings.
    if (permission == LocationPermission.deniedForever) {
      await _promptSettings(
        'Permission Required',
        'Location access is permanently denied. '
            'Open Settings and enable it to use this feature.',
      );
      return false;
    }

    // Denied (but not forever) — request.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _denyCount = 0;
        return true;
      }

      // User denied again.
      _denyCount++;

      if (permission == LocationPermission.deniedForever ||
          _denyCount >= _maxDenyBeforeSettings) {
        // After 3 denials or a permanent denial, send to settings.
        await _promptSettings(
          'Permission Required',
          'You have denied location access ${ _denyCount >= _maxDenyBeforeSettings ? "$_maxDenyBeforeSettings times" : "permanently" }. '
              'Please open Settings and allow location access for this app.',
        );
        return false;
      }

      Get.snackbar(
        'Permission Denied',
        'Location permission is needed to use your current location.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return false;
  }

  // ── Open app settings dialog ──────────────────────────────────────────────

  Future<void> _promptSettings(String title, String message) async {
    final bool? open = await Get.dialog<bool>(
      _SettingsDialog(title: title, message: message),
      barrierDismissible: false,
    );
    if (open == true) {
      await Geolocator.openAppSettings();
      // After user returns from Settings, check permission silently.
      // If now granted, fill the location automatically.
      await _fillLocationAfterSettings();
    }
  }

  /// Called after the user returns from the OS settings screen.
  /// If permission was granted, fetches location silently.
  Future<void> _fillLocationAfterSettings() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _denyCount = 0;
      // Trigger the full use-current-location flow now that permission is set.
      await useCurrentLocation();
    }
  }

  // ── Reverse geocoding ─────────────────────────────────────────────────────

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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.5,
        ),
      ),
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
    );
  }
}
