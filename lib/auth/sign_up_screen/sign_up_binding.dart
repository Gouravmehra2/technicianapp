import 'package:get/get.dart';
import 'package:technicianapp/auth/sign_up_screen/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController());
  }
}
