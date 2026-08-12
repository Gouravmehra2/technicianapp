import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/personal_information_screen/personal_information_controller.dart';

class PersonalInformationBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInformationController());
  }

}