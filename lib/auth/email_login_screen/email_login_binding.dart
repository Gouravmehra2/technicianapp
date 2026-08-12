import 'package:get/get.dart';
import 'package:technicianapp/auth/email_login_screen/email_login_controller.dart';

class EmailLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailLoginController(), fenix: false);
  }
}
