import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/core/services/location_service.dart';

/// Model for a saved address entry
class SavedAddress {
  final String type; // e.g. "Home", "Work", "Other"
  final String fullAddress;
  final String distance; // e.g. "3 m", "0 m", "300 m"
  final Color iconBgColor;
  final String icon;
  final bool isSelected;
  final Color iconColor;

  const SavedAddress({
    required this.type,
    required this.fullAddress,
    required this.distance,
    required this.iconBgColor,
    required this.icon,
    required this.iconColor,
    this.isSelected = false,
  });

  SavedAddress copyWith({bool? isSelected}) => SavedAddress(
    type: type,
    fullAddress: fullAddress,
    distance: distance,
    iconBgColor: iconBgColor,
    icon: icon,
    isSelected: isSelected ?? this.isSelected,
    iconColor: iconColor,
  );
}

class SelectLocationController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  /// Index of the currently selected saved address (-1 = none)
  final RxInt selectedIndex = RxInt(0);

  final List<SavedAddress> savedAddresses = [
    SavedAddress(
      type: 'Home',
      fullAddress:
          'Ep 331 Inside Saidan Gate Tanchi Wali Gali, Bajwa Colony, Jalandhar, Punjab 144008',
      distance: '3 m',
      iconBgColor: Color(0xFFEDE9FE),
      // light purple
      icon: AppAssets.outlinedHomeIcon,
      iconColor: AppColor.purpleColor,
      isSelected: true,
    ),
    SavedAddress(
      type: 'Work',
      fullAddress:
          'CXO Suites, Ground Floor, IT Park, Sector 22, Panchkula, Haryana 134109, India',
      distance: '0 m',
      iconBgColor: Color(0xFFFFEDD5),
      // light orange
      icon: AppAssets.workOutlineIcon,
      iconColor: AppColor.darkBrown,
    ),
    SavedAddress(
      type: 'Other',
      fullAddress:
          'R118, PG Kiran, Sector 91, Sahibzada Ajit Singh Nagar, Mohali, Punjab, 140308, India',
      distance: '300 m',
      iconBgColor: Color(0xFFDCFCE7),
      // light green
      icon: AppAssets.outlinedHomeIcon,
      iconColor: AppColor.greenColor,
    ),
  ];

  final RxBool isFetchingLocation = false.obs;

  void onSearchChanged(String value) => searchQuery.value = value;

  void selectAddress(int index) => selectedIndex.value = index;

  Future<void> onUseCurrentLocation() async {
    final bool ok = await _ensurePermission();
    if (!ok) return;

    isFetchingLocation.value = true;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final resolvedAddress = await _reverseGeocode(pos.latitude, pos.longitude);

      LocationService.to.setLocation(
        address: resolvedAddress,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      Get.snackbar(
        'Location Updated',
        resolvedAddress,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back(); // return to home
    } catch (e) {
      Get.snackbar(
        'Location Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<bool> _ensurePermission() async {
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
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      final bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Permission Required'),
          content: const Text(
            'Location access is permanently denied. '
            'Please enable it in your device settings.',
          ),
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
        ),
        barrierDismissible: false,
      );
      if (confirmed == true) await Geolocator.openAppSettings();
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

    return true;
  }

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

  void onAddNewAddress() {
    // TODO: navigate to add-address form
  }

  void onRequestFromFriend() {
    // TODO: share link / deep-link flow
  }

  void onEditAddress(int index) {
    // TODO: navigate to edit-address screen
  }

  void onDeleteAddress(int index) {
    // TODO: delete address from backend
  }

  void onShareAddress(int index) {
    // TODO: share address
  }

  void onViewAll() {
    // TODO: navigate to all addresses screen
  }

  void onConfirmLocation() {
    final idx = selectedIndex.value;
    if (idx < 0 || idx >= savedAddresses.length) {
      Get.back();
      return;
    }
    final selected = savedAddresses[idx];
    LocationService.to.setLocation(address: selected.fullAddress);
    Get.back();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
