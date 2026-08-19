import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
