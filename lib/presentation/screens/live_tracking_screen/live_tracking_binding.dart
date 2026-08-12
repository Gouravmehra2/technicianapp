import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/live_tracking_screen/live_tracking_controller.dart';

class LiveTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiveTrackingController());
  }
}
