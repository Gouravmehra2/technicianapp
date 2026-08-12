import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

enum BookingStep { findingTechnician, technicinaAssigned, technicianOnWay, serviceInProgress, completed }

class BookingStatusController extends GetxController {
  late ServiceModel service;
  final currentStep = BookingStep.findingTechnician.obs;

  @override
  void onInit() {
    super.onInit();
    service = Get.arguments as ServiceModel;
  }

  void advance() {
    final steps = BookingStep.values;
    final idx = steps.indexOf(currentStep.value);
    if (idx < steps.length - 1) {
      currentStep.value = steps[idx + 1];
    } else {
      Get.toNamed(AppRoutes.serviceReviewScreen, arguments: service);
    }
  }

  bool isCompleted(BookingStep step) => step.index < currentStep.value.index;
  bool isCurrent(BookingStep step) => step == currentStep.value;

  void trackNow() => Get.toNamed(AppRoutes.liveTrackingScreen, arguments: service);
}
