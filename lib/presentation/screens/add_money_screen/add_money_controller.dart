import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethod {
  final String name;
  final String subtitle;
  final IconData icon;
  PaymentMethod({required this.name, required this.subtitle, required this.icon});
}

class AddMoneyController extends GetxController {
  final amountController = TextEditingController();
  final selectedAmount = RxnInt();
  final selectedMethodIndex = 0.obs;

  final quickAmounts = [500, 2000, 1000, 5000];

  final paymentMethods = [
    PaymentMethod(name: 'UPI / GPay', subtitle: 'Instant Settlement', icon: Icons.account_balance_wallet_outlined),
    PaymentMethod(name: 'Visa Card •••• 4492', subtitle: 'Expires 12/26', icon: Icons.credit_card),
    PaymentMethod(name: 'Mastercard •••• 8810', subtitle: 'Expires 05/25', icon: Icons.credit_card),
  ];

  void selectQuickAmount(int amount) {
    selectedAmount.value = amount;
    amountController.text = amount.toString();
  }

  void proceedToPay() {
    final amount = int.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.snackbar('Success', 'Processing payment of \$$amount', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
