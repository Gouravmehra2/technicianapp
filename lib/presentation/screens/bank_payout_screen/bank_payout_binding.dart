import 'package:get/get.dart';
import 'bank_payout_controller.dart';

class BankPayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankPayoutController>(() => BankPayoutController());
  }
}
