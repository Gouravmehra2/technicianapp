import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

class Step2DocOverviewScreen extends GetView<TechnicianOnboardingController> {
  const Step2DocOverviewScreen({super.key});

  static const _docs = [
    {'key': 'driving_license', 'label': 'Driving License', 'icon': Icons.badge_outlined},
    {'key': 'residential_proof', 'label': 'Residential Proof', 'icon': Icons.home_outlined},
    {'key': 'tax_info', 'label': 'Tax Information', 'icon': Icons.receipt_long_outlined},
    {'key': 'cv_resume', 'label': 'CV/ Resume', 'icon': Icons.description_outlined},
    {'key': 'background_check', 'label': 'Background Check', 'icon': Icons.security_outlined},
  ];

  static  final List<String>_docRoutes = [
    AppRoutes.technicianDocDrivingLicenseScreen,
    AppRoutes.technicianDocResidentialScreen,
    AppRoutes.technicianDocTaxScreen,
    AppRoutes.technicianDocCvScreen,
    AppRoutes.technicianDocBackgroundScreen,
  ];

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Document Verification'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingStepIndicator(currentStep: 2),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Complete your Verification', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
                        const SizedBox(height: 8),
                        Text(
                          '5 quick steps to get verified and start accepting jobs. These documents help verify your identity, eligibility, and payment details before you can start accepting jobs.',
                          style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Get ready with all your documents listed below\nEstimated Time to complete\n8-10 minutes',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.blackShade1, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_docs.length, (i) {
                    final doc = _docs[i];
                    final isFirst = i == 0;
                    return GetBuilder(init: controller,builder: (controller) {
                      final done = controller.isDocComplete(doc['key'] as String);
                      return GestureDetector(
                        onTap: isFirst ? () => Get.toNamed(_docRoutes[i]) : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.lightGreyColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(doc['icon'] as IconData, color: AppColor.brownAccentPrimary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(doc['label'] as String, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: done ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: done ? Colors.green : Colors.redAccent),
                                ),
                                child: Text(
                                  done ? 'Complete' : 'Incomplete',
                                  style: AppTextStyle.labelSmallMedium.copyWith(color: done ? Colors.green : Colors.redAccent),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isFirst ? Icons.chevron_right : Icons.lock_outline,
                                color: AppColor.coolGrayText,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Start Document Verification →',
              onTap: () => Get.toNamed(AppRoutes.technicianDocDrivingLicenseScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
