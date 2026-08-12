import 'package:get/get.dart';
import 'add_money_controller.dart';

class AddMoneyBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AddMoneyController());
}
