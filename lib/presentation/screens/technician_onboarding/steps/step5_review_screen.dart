import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';

class Step5UnderReviewScreen extends StatelessWidget {
  const Step5UnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Under Review'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  const OnboardingStepIndicator(currentStep: 5),
                  const SizedBox(height: 40),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF5EFE6),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFD4B896).withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.search, size: 52, color: AppColor.brownAccentPrimary),
                  ),
                  const SizedBox(height: 28),
                  Text("We're Reviewing Your\nDocuments", textAlign: TextAlign.center, style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 24, height: 1.3)),
                  const SizedBox(height: 10),
                  Text('Verification usually takes 24–72 Hours.', style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText)),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verification Status', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                        const SizedBox(height: 16),
                        _StatusItem(color: Colors.green, title: 'Documents Received', subtitle: 'Completed on 2 Aug', isLast: false),
                        _StatusItem(color: Colors.orange, title: 'Background and Document Verification', subtitle: 'In progress', isLast: false),
                        _StatusItem(color: Colors.grey.shade300, title: 'Final Approval', subtitle: 'Pending', isLast: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Color color;
  final String title, subtitle;
  final bool isLast;
  const _StatusItem({required this.color, required this.title, required this.subtitle, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            if (!isLast) Container(width: 2, height: 36, color: AppColor.lightGreyColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── All Set screen ────────────────────────────────────────────────────────────

class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5EFE6),
              border: Border.all(color: const Color(0xFFE8D5B7), width: 2),
            ),
            child: const Icon(Icons.verified, color: AppColor.brownAccentPrimary, size: 52),
          ),
          const SizedBox(height: 24),
          Text('All Set!', style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 28)),
          const SizedBox(height: 10),
          Text(
            'Your technician account has been\nverified and you are ready to earn.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText, height: 1.6),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: CommonButton(
              label: 'Start Earning',
              onTap: () => Get.offAllNamed(AppRoutes.dashboardScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
