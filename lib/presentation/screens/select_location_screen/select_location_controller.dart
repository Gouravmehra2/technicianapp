import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/pages/app_pages.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_manager.dart';
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
    isFetchingLocation.value = true;
    final result = await LocationManager.to.fetchLocation();
    isFetchingLocation.value = false;

    if (!result.success) return;

    LocationService.to.setLocation(
      address: result.address,
      lat: result.lat,
      lng: result.lng,
    );
    Get.snackbar('Location Updated', result.address,
        snackPosition: SnackPosition.TOP);
    Get.back();
  }

  void onAddNewAddress() {
    Get.toNamed(AppRoutes.mapScreen);
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
