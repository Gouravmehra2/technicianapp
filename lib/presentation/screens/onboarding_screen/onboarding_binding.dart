import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/onboarding_controller.dart';

class OnboardingBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingController());
  }
}