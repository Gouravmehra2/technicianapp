import 'package:get/get.dart';

/// Singleton that holds the confirmed location across the app.
/// Both [LocationPermissionController] and [LocationDetailController] write here.
/// [TechnicianHomeController] reads from here.
class LocationService extends GetxService {
  static LocationService get to => Get.find<LocationService>();

  /// Human-readable address shown in the home header.
  final RxString confirmedAddress = ''.obs;

  /// Raw latitude, longitude — optional, useful for future map centering.
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  void setLocation({
    required String address,
    double lat = 0.0,
    double lng = 0.0,
  }) {
    confirmedAddress.value = address;
    latitude.value = lat;
    longitude.value = lng;
  }

  void clear() {
    confirmedAddress.value = '';
    latitude.value = 0.0;
    longitude.value = 0.0;
  }
}
