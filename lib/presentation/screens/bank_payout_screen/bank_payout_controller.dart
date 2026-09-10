import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankPayoutController extends GetxController {
  // View mode vs edit mode
  final RxBool isEditing = false.obs;

  // Saved values
  final RxString bankName = 'HDFC Bank'.obs;
  final RxString accountHolder = 'Gourav Mehra'.obs;
  final RxString accountNumber = '5010 1234 5678 90'.obs;
  final RxString ifscCode = 'HDFC0001234'.obs;
  final RxString upiId = 'gouravmehra@upi'.obs;

  // Form controllers
  final bankNameCtrl = TextEditingController();
  final accountHolderCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  final panCtrl = TextEditingController(text: 'ABCDE1234F');
  final gstCtrl = TextEditingController(text: '22AAAAA0000A1Z5');

  final RxBool isAccountVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    bankNameCtrl.text = bankName.value;
    accountHolderCtrl.text = accountHolder.value;
    accountNumberCtrl.text = accountNumber.value;
    ifscCtrl.text = ifscCode.value;
    upiCtrl.text = upiId.value;
  }

  @override
  void onClose() {
    bankNameCtrl.dispose();
    accountHolderCtrl.dispose();
    accountNumberCtrl.dispose();
    ifscCtrl.dispose();
    upiCtrl.dispose();
    panCtrl.dispose();
    gstCtrl.dispose();
    super.onClose();
  }

  void onVerifyAccount() {
    isAccountVerified.value = true;
    Get.snackbar(
      'Verified',
      'Account verified successfully.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void onSave() {
    bankName.value = bankNameCtrl.text;
    accountHolder.value = accountHolderCtrl.text;
    accountNumber.value = accountNumberCtrl.text;
    ifscCode.value = ifscCtrl.text;
    upiId.value = upiCtrl.text;
    isEditing.value = false;
    Get.snackbar(
      'Saved',
      'Payout details updated.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
