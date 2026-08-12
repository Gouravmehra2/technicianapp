import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/location_detail_screen/location_detail_controller.dart';

class LocationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocationDetailController());
  }
}
