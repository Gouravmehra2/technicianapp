import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/forgot_password_screen/forgot_password_controller.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_country_code_picker.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      builder: (controller) {
        return AuthLayout(
              imagePath: AppAssets.authBackgroundImage,
              body: _ForgotPasswordPanel(controller: controller),
            );
      },
    );
  }
}

// ─── Panel ────────────────────────────────────────────────────────────────────

class _ForgotPasswordPanel extends StatelessWidget {
  final ForgotPasswordController controller;

  const _ForgotPasswordPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
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
                  'forgot_title'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle — adapts to phone / email mode ────────────────
                Text(
                  controller.subtitleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.coolGrayText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Input field — phone picker row OR plain email field ─────
                if (controller.isEmailMode)
                  // Email field
                  CommonTextFormField(
                    controller: controller.inputController,
                    hintText: controller.fieldHintText,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: controller.validateInput,
                  )
                else
                  // Phone row with country picker
                  Obx(() {
                    controller.selectedCountry.value;
                    final phoneErr = controller.phoneError.value;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonCountryCodePicker(
                          onChanged: controller.onCountryChanged,
                          initialSelection:
                              controller.selectedCountry.value.code ?? 'IN',
                          backgroundColor: Colors.white,
                          borderColor: AppColor.lightGreyColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CommonTextFormField(
                            controller: controller.inputController,
                            hintText: controller.fieldHintText,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: controller.phoneFormatters,
                            validator: controller.validateInput,
                            onChanged: controller.onInputChanged,
                            errorText: phoneErr.isEmpty ? null : phoneErr,
                          ),
                        ),
                      ],
                    );
                  }),

                const SizedBox(height: 20),

                // ── Get Recovery Link button ───────────────────────────────
                Obx(
                  () => CommonButton(
                    label: controller.buttonLabel,
                    onTap: controller.handleGetRecoveryLink,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Resend row (visible after first send) ──────────────────
                Obx(() {
                  if (!controller.linkSent.value) {
                    return const SizedBox.shrink();
                  }

                  final canResend = controller.canResend.value;
                  final countdown = controller.countdownText;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: canResend ? controller.handleResend : null,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Resend Link',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColor.blackShade1,
                              ),
                            ),
                            if (!canResend)
                              TextSpan(
                                text: '  in $countdown',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.blackShade1,
                                ),
                              ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),

                // ── Back to Login ──────────────────────────────────────────
                GestureDetector(
                  onTap: controller.navigateBack,
                  child: Text(
                    'forgot_back_to_login'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.brownAccentPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
