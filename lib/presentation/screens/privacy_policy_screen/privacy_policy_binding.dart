import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/privacy_policy_screen/privacy_policy_controller.dart';

class PrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrivacyPolicyController());
  }
}
