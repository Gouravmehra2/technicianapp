import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

class Step2aDrivingLicenseScreen extends GetView<TechnicianOnboardingController> {
  const Step2aDrivingLicenseScreen({super.key});

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
                  const _DocStepIndicator(currentDoc: 1),
                  const SizedBox(height: 16),
                  const StepHeaderCard(
                    stepLabel: 'Step 1 of 5',
                    title: 'Driving License',
                    description: "Upload a clear photo of your valid government-issued driver's license.",
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    title: 'Requirements:',
                    body: 'Front and back must be clear, unexpired, and all four corners visible. Avoid glare and shadows.',
                  ),
                  const SizedBox(height: 20),
                  Text('Upload Front', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.drivingLicenseFront.value,
                    onTap: () => controller.pickAndSet(controller.drivingLicenseFront),
                    onDelete: () => controller.drivingLicenseFront.value = null,
                  )),
                  const SizedBox(height: 20),
                  Text('Upload Back', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.drivingLicenseBack.value,
                    onTap: () => controller.pickAndSet(controller.drivingLicenseBack),
                    onDelete: () => controller.drivingLicenseBack.value = null,
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () {
                controller.markDocComplete('driving_license');
                Get.toNamed(AppRoutes.technicianDocResidentialScreen);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Step2bResidentialScreen extends GetView<TechnicianOnboardingController> {
  const Step2bResidentialScreen({super.key});

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
                  const _DocStepIndicator(currentDoc: 2),
                  const SizedBox(height: 16),
                  const StepHeaderCard(
                    stepLabel: 'Step 2 of 5',
                    title: 'Residential Proof',
                    description: 'Upload a document to verify your current address.',
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    title: 'Requirements:',
                    body: 'Document must be issued within the last 90 days and match your profile name and make sure that Address clearly visible.',
                  ),
                  const SizedBox(height: 16),
                  Text('ACCEPTED DOCUMENTS', style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.blackShade1, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Utility Bill', 'Internet Bill', 'Bank Statement', 'Lease Agreement'].map((label) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColor.lightGreyColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.description_outlined, size: 14, color: AppColor.brownAccentPrimary),
                            const SizedBox(width: 4),
                            Text(label, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Upload Document', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.residentialProof.value,
                    onTap: () => controller.pickAndSet(controller.residentialProof),
                    onDelete: () => controller.residentialProof.value = null,
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () {
                controller.markDocComplete('residential_proof');
                Get.toNamed(AppRoutes.technicianDocTaxScreen);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Step2cTaxInfoScreen extends GetView<TechnicianOnboardingController> {
  const Step2cTaxInfoScreen({super.key});

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
                  const _DocStepIndicator(currentDoc: 3),
                  const SizedBox(height: 16),
                  const StepHeaderCard(
                    stepLabel: 'Step 3 of 5',
                    title: 'Tax Information Proof',
                    description: 'Please upload your completed and signed W-9 Form and 1099 Information Form',
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    title: 'Requirements:',
                    body: 'This is required for legal and payment processing before you can accept jobs.',
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    title: 'Why we need this',
                    body: 'We use this form for tax reporting purposes.',
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.download_outlined, color: AppColor.brownAccentPrimary, size: 16),
                        const SizedBox(width: 6),
                        Text('Need a blank W-9? Download Template', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Upload W-9 Document', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.w9Doc.value,
                    onTap: () => controller.pickAndSet(controller.w9Doc),
                    onDelete: () => controller.w9Doc.value = null,
                  )),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1099 Information Document', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 15)),
                        const SizedBox(height: 10),
                        Text('Have you previously received a 1099 from SquadOnSite?', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.blackShade1)),
                        const SizedBox(height: 10),
                        Obx(() => Column(
                          children: [
                            _RadioOption(label: 'Yes', selected: controller.has1099.value == true, onTap: () => controller.has1099.value = true),
                            const SizedBox(height: 8),
                            _RadioOption(label: 'No', selected: controller.has1099.value == false, onTap: () => controller.has1099.value = false),
                          ],
                        )),
                        const SizedBox(height: 14),
                        Text('Upload your most recent 1099 PDF/Image', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1)),
                        const SizedBox(height: 10),
                        Obx(() => UploadBox(
                          filePath: controller.doc1099.value,
                          onTap: () => controller.pickAndSet(controller.doc1099),
                          onDelete: () => controller.doc1099.value = null,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () {
                controller.markDocComplete('tax_info');
                Get.toNamed(AppRoutes.technicianDocCvScreen);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Step2dCvScreen extends GetView<TechnicianOnboardingController> {
  const Step2dCvScreen({super.key});

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
                  const _DocStepIndicator(currentDoc: 4),
                  const SizedBox(height: 16),
                  const StepHeaderCard(
                    stepLabel: 'Step 4 of 5',
                    title: 'Professional CV / Resume',
                    description: 'Upload your latest resume to verify your skills and work history.',
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    title: 'Accepted Formats:',
                    body: 'PDF, DOC, DOCX., Maximum Size: 10MB.',
                  ),
                  const SizedBox(height: 20),
                  Text('Upload Document', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.cvResume.value,
                    onTap: () => controller.pickAndSet(controller.cvResume),
                    onDelete: () => controller.cvResume.value = null,
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () {
                controller.markDocComplete('cv_resume');
                Get.toNamed(AppRoutes.technicianDocBackgroundScreen);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Step2eBackgroundScreen extends GetView<TechnicianOnboardingController> {
  const Step2eBackgroundScreen({super.key});

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
                  const _DocStepIndicator(currentDoc: 5),
                  const SizedBox(height: 16),
                  const StepHeaderCard(
                    stepLabel: 'Step 5 of 5',
                    title: 'Background Verification',
                    description: 'We partner with a secure verification service to perform background screenings.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFFFF3E0), shape: BoxShape.circle),
                          child: const Icon(Icons.lock_outline, color: AppColor.brownAccentPrimary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Secure & Confidential', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                              const SizedBox(height: 2),
                              Text('Your information is encrypted and securely processed.', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What we Check', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                        const SizedBox(height: 12),
                        ...[
                          ['Criminal Record', 'National and Country level screening.'],
                          ['SSN Trace', 'Verification of identity and address history.'],
                          ['Drug Test', 'Medical and Fitness Test'],
                          ['Global Watchlist', 'Checks against domestic and international lists.'],
                        ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColor.brownAccentPrimary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(text: '${item[0]}\n', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1)),
                                    TextSpan(text: item[1], style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => GestureDetector(
                    onTap: () => controller.backgroundAuthorized.value = !controller.backgroundAuthorized.value,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: controller.backgroundAuthorized.value,
                          onChanged: (v) => controller.backgroundAuthorized.value = v ?? false,
                          activeColor: AppColor.brownAccentPrimary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.blackShade1),
                              children: [
                                const TextSpan(text: 'I authorize 1App Technologies to conduct a background check and agree to the '),
                                TextSpan(text: 'Terms of Service', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 20),
                  Text('Drug Screening', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('A drug screening is required before activation. Upload valid drug test report.', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                  const SizedBox(height: 12),
                  Text('Upload Document', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => UploadBox(
                    filePath: controller.drugScreeningDoc.value,
                    onTap: () => controller.pickAndSet(controller.drugScreeningDoc),
                    onDelete: () => controller.drugScreeningDoc.value = null,
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Continue →',
              onTap: () {
                controller.markDocComplete('background_check');
                Get.toNamed(AppRoutes.technicianSkillsScreen);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared doc step indicator (1-5 circles only, no labels) ──────────────────

class _DocStepIndicator extends StatelessWidget {
  final int currentDoc;
  const _DocStepIndicator({required this.currentDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(9, (i) {
        if (i.isOdd) {
          final done = i ~/ 2 < currentDoc - 1;
          return Expanded(child: Container(height: 2, color: done ? AppColor.blackShade1 : AppColor.lightGreyColor));
        }
        final step = i ~/ 2 + 1;
        final active = step <= currentDoc;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColor.blackShade1 : Colors.white,
            border: Border.all(color: active ? AppColor.blackShade1 : AppColor.lightGreyColor, width: 1.5),
          ),
          child: Center(
            child: Text('$step', style: AppTextStyle.labelSmallMedium.copyWith(color: active ? Colors.white : AppColor.coolGrayText, fontWeight: FontWeight.w700)),
          ),
        );
      }),
    );
  }
}

// ── Radio option ──────────────────────────────────────────────────────────────

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.lightGreyColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1)),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor, width: 2),
              ),
              child: selected
                  ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColor.brownAccentPrimary)))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
