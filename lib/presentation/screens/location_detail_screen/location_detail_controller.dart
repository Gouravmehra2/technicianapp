import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_manager.dart';
import 'package:technicianapp/core/services/location_service.dart';

export 'location_detail_controller.dart' show SaveAsType;

enum SaveAsType { home, office, other }

class LocationDetailController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  final Rx<SaveAsType> selectedSaveAs = SaveAsType.home.obs;
  final RxBool isLocating = false.obs;

  @override
  void onClose() {
    searchController.dispose();
    houseController.dispose();
    apartmentController.dispose();
    landmarkController.dispose();
    super.onClose();
  }

  void selectSaveAs(SaveAsType type) => selectedSaveAs.value = type;

  void onSearchChanged(String value) {
    debugPrint('[LocationDetail] search: $value');
  }

  Future<void> useCurrentLocation() async {
    isLocating.value = true;
    final result = await LocationManager.to.fetchLocation();
    isLocating.value = false;

    if (!result.success) return;

    searchController.text = result.address;
    LocationService.to.setLocation(
      address: result.address,
      lat: result.lat,
      lng: result.lng,
    );
    update();
  }

  void confirmLocation() {
    if (!formKey.currentState!.validate()) return;

    final parts = <String>[
      if (houseController.text.trim().isNotEmpty) houseController.text.trim(),
      if (apartmentController.text.trim().isNotEmpty) apartmentController.text.trim(),
      if (searchController.text.trim().isNotEmpty) searchController.text.trim(),
      if (landmarkController.text.trim().isNotEmpty)
        'Near ${landmarkController.text.trim()}',
    ];
    final fullAddress = parts.join(', ');

    LocationService.to.setLocation(
      address: fullAddress.isNotEmpty ? fullAddress : searchController.text.trim(),
    );

    Get.offAllNamed(AppRoutes.dashboardScreen);
  }
}
