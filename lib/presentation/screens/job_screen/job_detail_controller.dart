import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'job_controller.dart';

class JobDetailController extends GetxController {
  JobModel? get job => Get.arguments as JobModel?;

  void acceptJob() {
    // Navigate to active job or confirmation
    Get.back();
  }

  void quoteOwnPrice() {
    Get.toNamed(AppRoutes.jobSendQuoteScreen, arguments: job);
  }

  void callSupport() {
    // Launch phone call
  }

  void rejectJob() {
    Get.back();
  }
}
