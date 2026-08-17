import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/login_screen/login_controller.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_country_code_picker.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return AuthLayout(
          imagePath: AppAssets.authBackgroundImage,
          body: _LoginPanel(controller: controller),
        );
      },
    );
  }
}

class _LoginPanel extends StatelessWidget {
  final LoginController controller;

  const _LoginPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    // NOTE: no outer horizontal Padding here — AuthLayout already applies
    // horizontal: 10 to `body`. Adding it again here doubled the inset
    // and made the card narrower than intended.
    return Container(
      // clipBehavior ensures the rounded corners are actually enforced on
      // child content (ripples, images, colored chips near the edge),
      // not just on the background paint of the BoxDecoration.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              /// Title
              Text(
                'login_title'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blackShade1,
                ),
              ),
              const SizedBox(height: 6),

              /// Subtitle
              Text(
                'login_subtitle'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColor.coolGrayText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              /// Phone Number Row — rebuilds when country or live error changes
              Obx(() {
                // Registering observables as Obx dependencies
                controller.selectedCountry.value;
                final phoneErr = controller.phoneError.value;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Country code picker
                    CommonCountryCodePicker(
                      onChanged: controller.onCountryChanged,
                      initialSelection:
                      controller.selectedCountry.value.code ?? 'IN',
                      backgroundColor: Colors.white,
                      borderColor: AppColor.lightGreyColor,
                    ),
                    const SizedBox(width: 10),

                    /// Phone number field — formatters + validator re-created
                    /// on every country change; errorText shows live feedback.
                    /// NOTE: verify CommonCountryCodePicker reserves matching
                    /// space for an error line so the row doesn't go lopsided
                    /// when phoneErr is non-empty.
                    Expanded(
                      child: CommonTextFormField(
                        controller: controller.phoneController,
                        hintText: 'login_hint_phone'.tr,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: controller.phoneFormatters,
                        validator: controller.validatePhone,
                        onChanged: controller.onPhoneChanged,
                        errorText: phoneErr.isEmpty ? null : phoneErr,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 14),

              /// Password field
              /// NOTE: login only checks "not empty" — strongPassword()
              /// belongs on sign-up/reset screens where a password is being
              /// created. On login it can reject a correct existing
              /// password before the request ever reaches the server.
              Obx(
                    () => CommonTextFormField.password(
                  controller: controller.passwordController,
                  hintText: 'login_hint_password'.tr,
                  obscureText: !controller.isPasswordVisible.value,
                  onToggleObscure: controller.togglePasswordVisibility,
                  validator: CommonValidators.compose([
                    CommonValidators.required(
                        message: 'validation_password_required'.tr),
                  ]),
                  textInputAction: TextInputAction.done,
                ),
              ),

              /// Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.navigateToForgotPassword,
                  child: Text(
                    'login_forgot_password'.tr,
                    style: const TextStyle(
                      color: AppColor.brownAccentPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              /// Sign In Button
              Obx(
                    () => CommonButton(
                  label: 'login_sign_in_btn'.tr,
                  onTap: controller.handleLogin,
                  isLoading: controller.isLoading.value,
                ),
              ),
              const SizedBox(height: 16),

              /// OR divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                        color: AppColor.lightGreyColor, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'login_or_divider'.tr,
                      style: const TextStyle(
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

              /// Social login buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => SocialLoginButton(
                        onTap: controller.handleAppleLogin,
                        icon: Image.asset(AppAssets.appleImage, height: 20),
                        isLoading: controller.isAppleLoading.value,
                        enabled: !controller.isGoogleLoading.value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Obx(
                          () => SocialLoginButton(
                        onTap: controller.handleGoogleLogin,
                        icon: Image.asset(AppAssets.googleImage, height: 20),
                        isLoading: controller.isGoogleLoading.value,
                        enabled: !controller.isAppleLoading.value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Sign Up link
              /// NOTE: switched from a bare GestureDetector on 13px text
              /// (well under the ~44px minimum recommended tap target) to
              /// a TextButton, matching the Forgot Password pattern above.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'login_no_account'.tr,
                    style: const TextStyle(
                        fontSize: 13, color: AppColor.coolGrayText),
                  ),
                  TextButton(
                    onPressed: controller.navigateToSignUp,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    child: Text(
                      'login_sign_up_link'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}