import 'package:get/get.dart';
import 'home_services_controller.dart';

class HomeServicesBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => HomeServicesController());
}
