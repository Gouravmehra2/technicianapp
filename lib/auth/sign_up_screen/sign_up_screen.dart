import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/sign_up_screen/sign_up_controller.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_country_code_picker.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/social_login_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      init: SignUpController(),
      builder: (controller) {
        return AuthLayout(
              imagePath: AppAssets.authBackgroundImage,
              body: _signUpPanel(controller),
            );
      },
    );
  }
}

Widget _signUpPanel(SignUpController controller) {
  return Container(
    decoration:  BoxDecoration(
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
              const SizedBox(height: 28),

              /// Title
              Text(
                'signup_title'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blackShade1,
                ),
              ),
              const SizedBox(height: 6),

              /// Subtitle
              Text(
                controller.subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColor.coolGrayText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              /// Input — email field in email mode, phone picker row otherwise
              if (controller.isEmailMode)
                CommonTextFormField(
                  controller: controller.emailController,
                  hintText: 'signup_hint_email'.tr,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: controller.emailValidator,
                )
              else
                /// Phone Number Row — rebuilds when country or live error changes
                Obx(() {
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

                      /// Phone number field
                      Expanded(
                        child: CommonTextFormField(
                          controller: controller.phoneController,
                          hintText: 'login_hint_phone'.tr,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          inputFormatters: controller.phoneFormatters,
                          validator: controller.validatePhone,
                          onChanged: controller.onPhoneChanged,
                          errorText: phoneErr.isEmpty ? null : phoneErr,
                        ),
                      ),
                    ],
                  );
                }),

              const SizedBox(height: 20),

              /// Continue Button
              Obx(
                () => CommonButton(
                  label: 'signup_continue_btn'.tr,
                  onTap: controller.handleContinue,
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
              /// Social sign-up buttons
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => SocialLoginButton(
                        onTap: controller.handleAppleSignUp,
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
                        onTap: controller.handleGoogleSignUp,
                        icon: Image.asset(AppAssets.googleImage, height: 20),
                        isLoading: controller.isGoogleLoading.value,
                        enabled: !controller.isAppleLoading.value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              /// Sign In link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'signup_have_account'.tr,
                    style: const TextStyle(
                        fontSize: 13, color: AppColor.coolGrayText),
                  ),
                  GestureDetector(
                    onTap: controller.navigateToLogin,
                    child: Text(
                      'signup_sign_in_link'.tr,
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
  );
}

