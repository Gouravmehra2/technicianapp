import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/payment_screen/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentController());
  }
}
