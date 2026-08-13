import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/social_login_button.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/widget/login_bottom_sheet_controller.dart';

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginBottomSheetController>(
      init: LoginBottomSheetController(),
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Available height the sheet can use
            final availableHeight = constraints.maxHeight;

            // Proportional gap — shrinks on small screens, caps on large ones
            final gap = (availableHeight * 0.018).clamp(6.0, 16.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ───────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: gap, bottom: gap),
                    decoration: BoxDecoration(
                      color: AppColor.shadowGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Logo ──────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration:  BoxDecoration(
                    color: AppColor.brownColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(AppAssets.appLogoIcon,height: 25,fit: BoxFit.cover,),
                ),

                SizedBox(height: gap),

                // ── Headline ──────────────────────────────────────────────────
                Text(
                  'login_sheet_headline'.tr,
                  style: AppTextStyle.displayMediumBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),

                SizedBox(height: gap * 0.5),

                // ── Sub-headline ──────────────────────────────────────────────
                Text(
                  'login_sheet_subheadline'.tr,
                  style: AppTextStyle.bodyLargeRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),

                SizedBox(height: gap * 1.5),

                // ── Guest ─────────────────────────────────────────────────────
                // CommonButton(
                //   label: 'login_sheet_guest_btn'.tr,
                //   onTap: () => Get.toNamed(AppRoutes.locationPermissionScreen),
                //   backgroundColor: AppColor.blackColor,
                //   foregroundColor: Colors.white,
                // ),

                // SizedBox(height: gap),

                // ── Phone ─────────────────────────────────────────────────────
                CommonButton(
                  backgroundColor: AppColor.shadowGrey,
                  foregroundColor: AppColor.blackColor,
                  label: 'login_sheet_phone_btn'.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.loginScreen);
                  },
                  leadingIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColor.blackColor,
                    size: 20,
                  ),
                ),

                SizedBox(height: gap),

                // ── Email ─────────────────────────────────────────────────────
                CommonButton(
                  backgroundColor: AppColor.shadowGrey,
                  foregroundColor: AppColor.blackColor,
                  label: 'login_sheet_email_btn'.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.emailLoginScreen);
                  },
                  leadingIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColor.blackColor,
                    size: 20,
                  ),
                ),

                SizedBox(height: gap),

                // ── Social row ────────────────────────────────────────────────
                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: Obx(
                        () => SocialLoginButton(
                          onTap: controller.handleAppleLogin,
                          icon: Image.asset(AppAssets.appleImage, height: 20),
                          backgroundColor: AppColor.shadowGrey,
                          border: Border.all(color: Colors.transparent),
                          isLoading: controller.isAppleLoading.value,
                          enabled: !controller.isGoogleLoading.value,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => SocialLoginButton(
                          onTap: controller.handleGoogleLogin,
                          icon: Image.asset(
                            AppAssets.googleImage,
                            height: 20,
                            color: Colors.black,
                          ),
                          backgroundColor: AppColor.shadowGrey,
                          border: Border.all(color: Colors.transparent),
                          isLoading: controller.isGoogleLoading.value,
                          enabled: !controller.isAppleLoading.value,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: gap),
              ],
            ).paddingSymmetric(horizontal: 20);
          },
        );
      },
    );
  }
}
