import 'package:get/get.dart';
import 'identity_verification_controller.dart';

class IdentityVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IdentityVerificationController());
  }
}
