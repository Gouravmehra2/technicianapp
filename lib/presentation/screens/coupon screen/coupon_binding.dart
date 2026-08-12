import 'package:get/get.dart';
import 'coupon_controller.dart';

class CouponBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => CouponController());
}
