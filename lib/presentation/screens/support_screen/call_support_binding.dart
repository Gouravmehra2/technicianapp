import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/support_screen/call_support_controller.dart';

class CallSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CallSupportController());
  }
}
