import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/common_dialog.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/socket_service.dart';

class ProfileController extends GetxController {
  // Profile image
  final Rx<File?> profileImage = Rx<File?>(null);

  // User info
  final RxString userName = 'Gourav Mehra'.obs;
  final RxString memberSince = 'Member Since 2026'.obs;

  // Settings
  final RxBool notificationsEnabled = true.obs;
  final RxString selectedLanguage = 'English'.obs;

  // Subscription
  final RxString subscriptionStatus = 'ACTIVE'.obs;
  final RxString subscriptionName = 'SquadCare+'.obs;

  // Wallet / coupon
  final RxString walletBalance = '\$56.7'.obs;
  final RxInt couponCount = 4.obs;
  final RxString savingsThisMonth = '\$124.50'.obs;

  // Referral
  final RxString referralCode = 'gouravm007'.obs;

  Future<void> pickProfileImage() async {
    final file = await CommonDialog.showImagePickerDialog();
    if (file != null) {
      profileImage.value = File(file.path);
    }
  }

  void onEditName() {}

  void onViewBenefits() {}

  void onMenuTap(String item) {}

  void onLogout() {
    Get.toNamed(AppRoutes.logoutScreen);
  }

  void changeLanguage(String lang) {
    selectedLanguage.value = lang;
    final locale =
        lang == 'Spanish' ? const Locale('es', 'ES') : const Locale('en', 'US');
    Get.updateLocale(locale);
  }
}
