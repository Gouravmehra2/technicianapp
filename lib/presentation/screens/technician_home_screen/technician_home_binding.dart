import 'package:get/get.dart';
import 'technician_home_controller.dart';

class TechnicianHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TechnicianHomeController>(() => TechnicianHomeController());
  }
}
