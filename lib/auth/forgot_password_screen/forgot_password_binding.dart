import 'package:get/get.dart';
import 'package:technicianapp/auth/forgot_password_screen/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: false — always create a fresh instance on navigation so the
    // GlobalKey inside the controller is never duplicated.
    Get.lazyPut(() => ForgotPasswordController(), fenix: false);
  }
}
