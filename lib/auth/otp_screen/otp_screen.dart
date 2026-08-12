import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/otp_screen/otp_controller.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_pin_input_field.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(
      builder: (controller) {
        return AuthLayout(
              imagePath: AppAssets.authBackgroundImage,
              body: _OtpPanel(controller: controller),
            );
      },
    );
  }
}

// ─── OTP panel ────────────────────────────────────────────────────────────────

class _OtpPanel extends StatelessWidget {
  final OtpController controller;

  const _OtpPanel({required this.controller});

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
                const SizedBox(height: 32),

                // ── Title — adapts to phone / email mode ───────────────────
                Text(
                  controller.titleText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtitle ───────────────────────────────────────────────
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

                // ── PIN input ──────────────────────────────────────────────
                CommonPinInputField(
                  length: 6,
                  controller: controller.pinController,
                  onChanged: controller.onOtpChanged,
                  onCompleted: controller.onOtpCompleted,
                  cellSize: 50,
                  borderRadius: 50,
                  spacing: 8,
                  borderColor: AppColor.lightGreyColor,
                  focusedBorderColor: AppColor.brownAccentPrimary,
                  filledBorderColor: AppColor.blackShade1,
                  errorBorderColor: Colors.red,
                ),
                const SizedBox(height: 28),

                // ── Verify & Continue button ───────────────────────────────
                Obx(
                  () => CommonButton(
                    label: 'otp_verify_btn'.tr,
                    onTap: controller.handleVerify,
                    isLoading: controller.isVerifyLoading.value,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Resend + countdown ─────────────────────────────────────
                Obx(() {
                  final canResend = controller.canResend.value;
                  final countdown = controller.countdownText;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'otp_no_code'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blackShade1,
                        ),
                      ),
                      GestureDetector(
                        onTap: canResend ? controller.handleResend : null,
                        child: Text(
                          canResend
                              ? 'otp_resend'.tr
                              : 'otp_resend_countdown'.trArgs([countdown]),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.brownAccentPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),

                // ── Change number / email — label adapts to mode ───────────
                GestureDetector(
                  onTap: controller.handleChangeDestination,
                  child: Text(
                    controller.changeLinkText,
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
