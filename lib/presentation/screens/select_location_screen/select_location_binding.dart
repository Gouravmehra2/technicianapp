import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/select_location_screen/select_location_controller.dart';

class SelectLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectLocationController());
  }
}
