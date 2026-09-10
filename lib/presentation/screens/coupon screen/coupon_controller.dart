import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponController extends GetxController {
  final couponCodeController = TextEditingController();
  final redeemCodeController = TextEditingController();

  final coupons = [
    {
      'code': 'SOS10',
      'discount': '10% OFF',
      'desc': 'Up to ₹150\non all services',
      'validTill': 'Valid till 31 May 2024',
      'isValid': true,
    },
    {
      'code': 'WELCOME50',
      'discount': '₹50 OFF',
      'desc': 'on your first service',
      'validTill': 'Valid till 15 Jun 2024',
      'isValid': true,
    },
    {
      'code': 'SOSFLAT100',
      'discount': '₹100 OFF',
      'desc': 'on orders above\n₹999',
      'validTill': 'Valid till 30 Jun 2024',
      'isValid': true,
    },
  ];

  void applyCoupon() {
    final code = couponCodeController.text.trim();
    if (code.isEmpty) return;
    Get.snackbar('Coupon', 'Applying coupon: $code', snackPosition: SnackPosition.TOP);
  }

  void redeemCode() {
    final code = redeemCodeController.text.trim();
    if (code.isEmpty) return;
    Get.snackbar('Promo Code', 'Redeeming code: $code', snackPosition: SnackPosition.TOP);
  }

  @override
  void onClose() {
    couponCodeController.dispose();
    redeemCodeController.dispose();
    super.onClose();
  }
}
