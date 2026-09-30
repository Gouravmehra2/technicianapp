import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/common_dialog.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/models/user_model.dart';

class ProfileController extends GetxController {
  final _apiRepo = Get.find<ApiRepo>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Profile image
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;

  // User info
  final RxString userName = '-'.obs;
  final RxString memberSince = '-'.obs;
  final RxString experienceLevel = '-'.obs;
  final RxString verificationStatus = '-'.obs;

  // Settings
  final RxBool notificationsEnabled = true.obs;
  final RxString selectedLanguage = 'English'.obs;

  // Subscription
  final RxString subscriptionStatus = '-'.obs;
  final RxString subscriptionName = '-'.obs;

  // Wallet / coupon
  final RxString walletBalance = '-'.obs;
  final RxInt couponCount = 0.obs;
  final RxString savingsThisMonth = '-'.obs;

  // Referral
  final RxString referralCode = '-'.obs;
  final RxString jobsCompleted = '-'.obs;
  final RxString earnings = '-'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiRepo.getMeApi();
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Invalid profile response');
      }

      final profile = UserModel.fromJson(body).user;
      if (profile == null) {
        throw const FormatException('Profile data is unavailable');
      }

      userName.value = _valueOrFallback(profile.name);
      memberSince.value = _memberSince(profile.createdAt);
      experienceLevel.value = _valueOrFallback(
        profile.technicianProfile?.experienceLevel ?? profile.experienceLevel,
      );
      verificationStatus.value = _valueOrFallback(
        profile.technicianProfile?.verificationStatus,
      );
      profileImageUrl.value =
          profile.profileImage?.url ??
          profile.technicianProfile?.photoUrl ??
          '';
      jobsCompleted.value = profile.totalJobsDone?.toString() ?? '-';
      earnings.value = profile.totalEarnings == null
          ? '-'
          : '\$${profile.totalEarnings}';
    } catch (error) {
      errorMessage.value = 'Unable to load profile';
      debugPrint('[Profile] /me fetch failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  String _valueOrFallback(String? value) =>
      value == null || value.trim().isEmpty ? '-' : value;

  String _memberSince(String? createdAt) {
    if (createdAt == null) return '-';
    final date = DateTime.tryParse(createdAt);
    return date == null ? '-' : 'Member Since ${date.year}';
  }

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
    final locale = lang == 'Spanish'
        ? const Locale('es', 'ES')
        : const Locale('en', 'US');
    Get.updateLocale(locale);
  }
}
