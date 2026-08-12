import 'package:get/get.dart';
import 'package:technicianapp/auth/sign_up_detail_screen/sign_up_detail_controller.dart';

class SignUpDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpDetailController(), fenix: false);
  }
}
