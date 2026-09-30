import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import '../technician_home_controller.dart';

class EarningsCard extends StatelessWidget {
  final TechnicianHomeController controller;

  const EarningsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onEarningsTapped,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF3E7),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Image.asset(AppAssets.earningIcon, height: 15),
            ),
            const SizedBox(width: 5),
            Text(
              'Total Earnings:',
              style: AppTextStyle.titleMediumSemiBold.copyWith(
                color: AppColor.blackShade1,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                controller.totalEarnings.value,
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.brownColor,
                  fontSize: 24,
                ),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward,
              color: AppColor.brownColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
