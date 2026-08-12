import 'package:get/get.dart';
import 'technician_onboarding_controller.dart';

class TechnicianOnboardingBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => TechnicianOnboardingController());
}
