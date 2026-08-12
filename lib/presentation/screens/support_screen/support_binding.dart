import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/support_screen/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupportController());
  }
}
