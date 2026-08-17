import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class JobQuoteSentScreen extends StatelessWidget {
  const JobQuoteSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColor.brownAccentPrimary,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quote Sent!',
              style: AppTextStyle.headlineMediumSemiBold.copyWith(color: AppColor.blackShade1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your custom quote has been submitted successfully. The customer will review it and respond shortly.',
              style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Back to Jobs
            GestureDetector(
              onTap: () => Get.offNamedUntil(
                AppRoutes.jobScreen,
                (route) => route.settings.name == AppRoutes.dashboardScreen,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Back to Jobs',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColor.brownAccentPrimary),
                ),
                child: Text(
                  'View Quote',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.buttonLarge.copyWith(color: AppColor.brownAccentPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
