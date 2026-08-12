import 'package:get/get.dart';
import 'professional_info_controller.dart';

class ProfessionalInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfessionalInfoController>(() => ProfessionalInfoController());
  }
}
