import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/service_review_screen/service_review_controller.dart';

class ServiceReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServiceReviewController());
  }
}
