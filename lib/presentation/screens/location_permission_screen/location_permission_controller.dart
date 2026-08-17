import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_manager.dart';
import 'package:technicianapp/core/services/location_service.dart';

class LocationPermissionController extends GetxController {
  final RxString address = ''.obs;
  final RxBool isFetching = false.obs;

  Future<void> requestLocationAndFetch() async {
    isFetching.value = true;
    final result = await LocationManager.to.fetchLocation();
    isFetching.value = false;

    if (!result.success) {
      Get.offAllNamed(AppRoutes.locationDetailScreen);
      return;
    }

    address.value = result.address;
    LocationService.to.setLocation(
      address: result.address,
      lat: result.lat,
      lng: result.lng,
    );

    await Future.delayed(const Duration(milliseconds: 800));
    Get.offAllNamed(AppRoutes.dashboardScreen);
  }
}
