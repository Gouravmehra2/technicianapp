import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/splash_screen/splash_controller.dart';

class SplashBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
  }

}