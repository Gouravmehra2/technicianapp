import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/tip_technician_screen/tip_technician_controller.dart';

class TipTechnicianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TipTechnicianController());
  }
}
