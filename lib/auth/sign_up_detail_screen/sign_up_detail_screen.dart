import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/sign_up_detail_screen/sign_up_detail_controller.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/social_login_button.dart';

class SignUpDetailScreen extends StatelessWidget {
  const SignUpDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpDetailController>(
      builder: (controller) {
        return AuthLayout(
          imagePath: AppAssets.authBackgroundImage,
          body: _SignUpDetailPanel(controller: controller),
        );
      },
    );
  }
}

// ─── Panel ────────────────────────────────────────────────────────────────────

class _SignUpDetailPanel extends StatelessWidget {
  final SignUpDetailController controller;

  const _SignUpDetailPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 28),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  'signup_detail_title'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Subtitle ───────────────────────────────────────────────
                Text(
                  'signup_detail_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.coolGrayText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Profile image picker ───────────────────────────────────
                _ProfileImagePicker(controller: controller),
                const SizedBox(height: 20),

                // ── Name field ─────────────────────────────────────────────
                CommonTextFormField(
                  controller: controller.nameController,
                  hintText: 'signup_detail_hint_name'.tr,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: controller.nameValidator,
                ),
                const SizedBox(height: 14),

                // ── Email field (pre-filled & disabled if email-verified) ──
                CommonTextFormField(
                  controller: controller.emailController,
                  hintText: 'signup_detail_hint_email'.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  enabled: !controller.isEmailMode,
                  validator: controller.emailValidator,
                  backgroundColor: controller.isEmailMode
                      ? AppColor.lightGreyColor.withValues(alpha: 0.4)
                      : Colors.white,
                ),
                const SizedBox(height: 14),

                // ── Phone field (pre-filled & disabled if phone-verified) ──
                CommonTextFormField(
                  controller: controller.phoneController,
                  hintText: 'signup_detail_hint_phone'.tr,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: controller.isEmailMode,
                  backgroundColor: !controller.isEmailMode
                      ? AppColor.lightGreyColor.withValues(alpha: 0.4)
                      : Colors.white,
                ),
                const SizedBox(height: 14),

                // ── Password field ─────────────────────────────────────────
                Obx(
                  () => CommonTextFormField.password(
                    controller: controller.passwordController,
                    hintText: 'signup_detail_hint_password'.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    onToggleObscure: controller.togglePasswordVisibility,
                    validator: controller.passwordValidator,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Confirm Password field ─────────────────────────────────
                Obx(
                  () => CommonTextFormField.password(
                    controller: controller.confirmPasswordController,
                    hintText: 'signup_detail_hint_confirm_password'.tr,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    onToggleObscure: controller.toggleConfirmPasswordVisibility,
                    validator: controller.confirmPasswordValidator,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign Up button ─────────────────────────────────────────
                Obx(
                  () => CommonButton(
                    label: 'signup_detail_btn'.tr,
                    onTap: controller.handleSignUp,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: 16),

                // ── OR divider ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                          color: AppColor.lightGreyColor, thickness: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                            fontSize: 13, color: AppColor.coolGrayText),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                          color: AppColor.lightGreyColor, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Social buttons ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        onTap: () {},
                        icon: Image.asset(AppAssets.appleImage, height: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SocialLoginButton(
                        onTap: () {},
                        icon: Image.asset(AppAssets.googleImage, height: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Log In link ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'signup_detail_have_account'.tr,
                      style: const TextStyle(
                          fontSize: 13, color: AppColor.coolGrayText),
                    ),
                    GestureDetector(
                      onTap: controller.navigateToLogin,
                      child: Text(
                        'signup_detail_login_link'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.brownAccentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile Image Picker ─────────────────────────────────────────────────────

class _ProfileImagePicker extends StatelessWidget {
  final SignUpDetailController controller;
  static const double _size = 90;

  const _ProfileImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickProfileImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          Obx(() {
            final file = controller.profileImage.value;
            return Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.lightGreyColor.withValues(alpha: 0.4),
                border: Border.all(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 36,
                            color: AppColor.coolGrayText,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Photo',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),

          // Camera badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColor.brownAccentPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
