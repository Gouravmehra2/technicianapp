import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page map:
//  0  Doc Overview          (Step 1)
//  1  Driving License       (Step 1)
//  2  Residential Proof     (Step 1)
//  3  Tax Info              (Step 1)
//  4  CV / Resume           (Step 1)
//  5  Background Check      (Step 1)
//  6  Skills                (Step 2)
//  7  Experience            (Step 2)
//  8  Bank Details          (Step 3)
//  9  Under Review          (Step 4)
// ─────────────────────────────────────────────────────────────────────────────

class TechnicianOnboardingScreen
    extends GetView<TechnicianOnboardingController> {
  const TechnicianOnboardingScreen({super.key});

  static const _appBarTitles = [
    'Document Verification', // 0
    'Document Verification', // 1
    'Document Verification', // 2
    'Document Verification', // 3
    'Document Verification', // 4
    'Document Verification', // 5
    'Skill Set Updation', // 6
    'Update Experience', // 7
    'Bank Details', // 8
    'Under Review', // 9
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.currentPage.value;
      final isUploading = controller.isUploadingDocs.value;
      final isReview = page == 9;
      // Page 0 = doc overview → no back button (can't go to a previous screen)
      final isOverview = page == 0;
      return MyScaffold(
        backgroundColor: Colors.white,
        appBar: isReview
            ? onboardingAppBar(_appBarTitles[page])
            : _buildAppBar(_appBarTitles[page], hideBack: isOverview),
        body: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DocOverviewPage(controller: controller),
                _DrivingLicensePage(controller: controller),
                _ResidentialPage(controller: controller),
                _TaxInfoPage(controller: controller),
                _CvPage(controller: controller),
                _BackgroundPage(controller: controller),
                _SkillsPage(controller: controller),
                _ExperiencePage(controller: controller),
                _BankPage(controller: controller),
                _UnderReviewPage(),
              ],
            ),
            if (isUploading)
              AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  AppBar _buildAppBar(String title, {bool hideBack = false}) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    leading: hideBack
        ? null
        : GestureDetector(
            onTap: controller.isUploadingDocs.value ? null : controller.prevPage,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black87),
            ),
          ),
    title: Text(
      title,
      style: AppTextStyle.titleLargeBold.copyWith(color: Colors.black87),
    ),
    centerTitle: true,
    actions: [
      GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.supportScreen),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.support_agent_outlined,
            color: Colors.black87,
            size: 20,
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0 – Doc Overview
// ─────────────────────────────────────────────────────────────────────────────

class _DocOverviewPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _DocOverviewPage({required this.controller});

  static const _docs = [
    {
      'key': 'driving_license',
      'label': 'Driving License',
      'icon': Icons.badge_outlined,
    },
    {
      'key': 'residential_proof',
      'label': 'Residential Proof',
      'icon': Icons.home_outlined,
    },
    {
      'key': 'tax_info',
      'label': 'Tax Information',
      'icon': Icons.receipt_long_outlined,
    },
    {
      'key': 'cv_resume',
      'label': 'CV / Resume',
      'icon': Icons.description_outlined,
    },
    {
      'key': 'background_check',
      'label': 'Background Check',
      'icon': Icons.security_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Complete your Verification',
                        style: AppTextStyle.titleLargeBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '5 quick steps to get verified and start accepting jobs. These documents help verify your identity, eligibility, and payment details.',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Get ready with all your documents listed below\nEstimated Time to complete\n8-10 minutes',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMediumMedium.copyWith(
                      color: AppColor.blackShade1,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Doc list — no tap, no right arrow, show lock icon
                ...List.generate(_docs.length, (i) {
                  final doc = _docs[i];
                  return GetBuilder<TechnicianOnboardingController>(
                    builder: (c) {
                      final done = c.isDocComplete(doc['key'] as String);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
                              child: Icon(
                                doc['icon'] as IconData,
                                color: AppColor.brownAccentPrimary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                doc['label'] as String,
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: done
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: done ? Colors.green : Colors.redAccent,
                                ),
                              ),
                              child: Text(
                                done ? 'Complete' : 'Incomplete',
                                style: AppTextStyle.labelSmallMedium.copyWith(
                                  color: done ? Colors.green : Colors.redAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Lock icon — user cannot jump directly from overview
                            const Icon(
                              Icons.lock_outline,
                              color: AppColor.coolGrayText,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        _BottomButton(
          label: 'Start Document Verification →',
          onTap: () => controller.goToPage(1),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 1 – Driving License
// ─────────────────────────────────────────────────────────────────────────────

class _DrivingLicensePage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _DrivingLicensePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 16),
                const _DocSubStepIndicator(currentDoc: 1),
                const SizedBox(height: 16),
                const StepHeaderCard(
                  stepLabel: 'Step 1 of 5',
                  title: 'Driving License',
                  description:
                      "Upload a clear photo of your valid government-issued driver's license.",
                ),
                const SizedBox(height: 12),
                const InfoCard(
                  title: 'Requirements:',
                  body:
                      'Front and back must be clear, unexpired, and all four corners visible. Avoid glare and shadows.',
                ),
                const SizedBox(height: 20),
                const _RequiredLabel('Upload Front'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.drivingLicenseFront.value,
                    onTap: () =>
                        controller.pickAndSet(controller.drivingLicenseFront),
                    onDelete: () => controller.drivingLicenseFront.value = null,
                  ),
                ),
                const SizedBox(height: 20),
                const _RequiredLabel('Upload Back'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.drivingLicenseBack.value,
                    onTap: () =>
                        controller.pickAndSet(controller.drivingLicenseBack),
                    onDelete: () => controller.drivingLicenseBack.value = null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() => _BottomButton(
          label: 'Next →',
          onTap: controller.canProceedDrivingLicense
              ? () {
                  controller.markDocComplete('driving_license');
                  controller.nextPage();
                }
              : null,
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 2 – Residential Proof
// ─────────────────────────────────────────────────────────────────────────────

class _ResidentialPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _ResidentialPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 16),
                const _DocSubStepIndicator(currentDoc: 2),
                const SizedBox(height: 16),
                const StepHeaderCard(
                  stepLabel: 'Step 2 of 5',
                  title: 'Residential Proof',
                  description:
                      'Upload a document to verify your current address.',
                ),
                const SizedBox(height: 12),
                const InfoCard(
                  title: 'Requirements:',
                  body:
                      'Document must be issued within the last 90 days and match your profile name and make sure that Address clearly visible.',
                ),
                const SizedBox(height: 16),
                Text(
                  'ACCEPTED DOCUMENTS',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: AppColor.blackShade1,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            'Utility Bill',
                            'Internet Bill',
                            'Bank Statement',
                            'Lease Agreement',
                          ]
                          .map(
                            (label) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColor.lightGreyColor,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 14,
                                    color: AppColor.brownAccentPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    label,
                                    style: AppTextStyle.bodySmallMedium
                                        .copyWith(color: AppColor.blackShade1),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
                const _RequiredLabel('Upload Document'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.residentialProof.value,
                    onTap: () =>
                        controller.pickAndSet(controller.residentialProof),
                    onDelete: () => controller.residentialProof.value = null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() => _BottomButton(
          label: 'Next →',
          onTap: controller.canProceedResidential
              ? () {
                  controller.markDocComplete('residential_proof');
                  controller.nextPage();
                }
              : null,
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 3 – Tax Info
// ─────────────────────────────────────────────────────────────────────────────

class _TaxInfoPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _TaxInfoPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 16),
                const _DocSubStepIndicator(currentDoc: 3),
                const SizedBox(height: 16),
                const StepHeaderCard(
                  stepLabel: 'Step 3 of 5',
                  title: 'Tax Information Proof',
                  description:
                      'Please upload your completed and signed W-9 Form and 1099 Information Form',
                ),
                const SizedBox(height: 12),
                const InfoCard(
                  title: 'Requirements:',
                  body:
                      'This is required for legal and payment processing before you can accept jobs.',
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
                      const Icon(
                        Icons.download_outlined,
                        color: AppColor.brownAccentPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Need a blank W-9? Download Template',
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: AppColor.brownAccentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _RequiredLabel('Upload W-9 Document'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.w9Doc.value,
                    onTap: () => controller.pickAndSet(controller.w9Doc),
                    onDelete: () => controller.w9Doc.value = null,
                  ),
                ),
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
                      Text(
                        '1099 Information Document',
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Have you previously received a 1099 from SquadOnSite?',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.blackShade1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Column(
                          children: [
                            _RadioOption(
                              label: 'Yes',
                              selected: controller.has1099.value == true,
                              onTap: () => controller.has1099.value = true,
                            ),
                            const SizedBox(height: 8),
                            _RadioOption(
                              label: 'No',
                              selected: controller.has1099.value == false,
                              onTap: () => controller.has1099.value = false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _RequiredLabel('Upload your most recent 1099 PDF/Image'),
                      const SizedBox(height: 10),
                      Obx(
                        () => UploadBox(
                          filePath: controller.doc1099.value,
                          onTap: () =>
                              controller.pickAndSet(controller.doc1099),
                          onDelete: () => controller.doc1099.value = null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() => _BottomButton(
          label: 'Next →',
          onTap: controller.canProceedTaxInfo
              ? () {
                  controller.markDocComplete('tax_info');
                  controller.nextPage();
                }
              : null,
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 4 – CV / Resume
// ─────────────────────────────────────────────────────────────────────────────

class _CvPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _CvPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 16),
                const _DocSubStepIndicator(currentDoc: 4),
                const SizedBox(height: 16),
                const StepHeaderCard(
                  stepLabel: 'Step 4 of 5',
                  title: 'Professional CV / Resume',
                  description:
                      'Upload your latest resume to verify your skills and work history.',
                ),
                const SizedBox(height: 12),
                const InfoCard(
                  title: 'Accepted Formats:',
                  body: 'PDF, DOC, DOCX. Maximum Size: 10MB.',
                ),
                const SizedBox(height: 20),
                const _RequiredLabel('Upload Document'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.cvResume.value,
                    onTap: () => controller.pickAndSet(controller.cvResume),
                    onDelete: () => controller.cvResume.value = null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() => _BottomButton(
          label: 'Next →',
          onTap: controller.canProceedCv
              ? () {
                  controller.markDocComplete('cv_resume');
                  controller.nextPage();
                }
              : null,
        )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 5 – Background Check
// API call fires here on "Continue →"
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _BackgroundPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 1),
                const SizedBox(height: 16),
                const _DocSubStepIndicator(currentDoc: 5),
                const SizedBox(height: 16),
                const StepHeaderCard(
                  stepLabel: 'Step 5 of 5',
                  title: 'Background Verification',
                  description:
                      'We partner with a secure verification service to perform background screenings.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: AppColor.brownAccentPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure & Confidential',
                              style: AppTextStyle.titleSmallSemiBold.copyWith(
                                color: AppColor.blackShade1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your information is encrypted and securely processed.',
                              style: AppTextStyle.bodySmallRegular.copyWith(
                                color: AppColor.coolGrayText,
                              ),
                            ),
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
                      Text(
                        'What we Check',
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        [
                          'Criminal Record',
                          'National and County level screening.',
                        ],
                        [
                          'SSN Trace',
                          'Verification of identity and address history.',
                        ],
                        ['Drug Test', 'Medical and Fitness Test'],
                        [
                          'Global Watchlist',
                          'Checks against domestic and international lists.',
                        ],
                      ].map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColor.brownAccentPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${item[0]}\n',
                                        style: AppTextStyle.bodySmallMedium
                                            .copyWith(
                                              color: AppColor.blackShade1,
                                            ),
                                      ),
                                      TextSpan(
                                        text: item[1],
                                        style: AppTextStyle.bodySmallRegular
                                            .copyWith(
                                              color: AppColor.coolGrayText,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.backgroundAuthorized.value =
                        !controller.backgroundAuthorized.value,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: controller.backgroundAuthorized.value,
                          onChanged: (v) =>
                              controller.backgroundAuthorized.value =
                                  v ?? false,
                          activeColor: AppColor.brownAccentPrimary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyle.bodySmallRegular.copyWith(
                                color: AppColor.blackShade1,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'I authorize 1App Technologies to conduct a background check and agree to the ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.brownAccentPrimary,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Drug Screening',
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A drug screening is required before activation. Upload valid drug test report.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
                const SizedBox(height: 12),
                const _RequiredLabel('Upload Document'),
                const SizedBox(height: 10),
                Obx(
                  () => UploadBox(
                    filePath: controller.drugScreeningDoc.value,
                    onTap: () =>
                        controller.pickAndSet(controller.drugScreeningDoc),
                    onDelete: () => controller.drugScreeningDoc.value = null,
                  ),
                ),
              ],
            ),
          ),
        ),
        // "Continue →" triggers the upload API
        Obx(
          () => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Continue →',
              onTap: controller.submitDocuments,
              enabled: controller.canProceedBackground,
              isLoading: controller.isUploadingDocs.value,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 6 – Skills
// ─────────────────────────────────────────────────────────────────────────────

class _SkillsPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _SkillsPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 2),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skill Set Updation',
                        style: AppTextStyle.titleLargeBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select all skills that apply.',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextFormField(
                  hintText: 'Search categories',
                  prefixIcon: Icons.search,
                  borderRadius: 30,
                  onChanged: (v) => controller.skillSearchQuery.value = v,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.filteredSkills.map((skill) {
                      final selected = controller.selectedSkills.contains(
                        skill,
                      );
                      return GestureDetector(
                        onTap: () => controller.toggleSkill(skill),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColor.blackShade1
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: selected
                                  ? AppColor.blackShade1
                                  : AppColor.lightGreyColor,
                            ),
                          ),
                          child: Text(
                            skill,
                            style: AppTextStyle.bodyMediumMedium.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColor.blackShade1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'EXPERIENCE LEVEL',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: AppColor.blackShade1,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: ['Beginner', 'Intermediate', 'Expert'].map((
                      level,
                    ) {
                      final selected =
                          controller.experienceLevel.value == level;
                      return GestureDetector(
                        onTap: () => controller.experienceLevel.value = level,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColor.blackShade1
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: selected
                                  ? AppColor.blackShade1
                                  : AppColor.lightGreyColor,
                            ),
                          ),
                          child: Text(
                            level,
                            style: AppTextStyle.bodyMediumMedium.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColor.blackShade1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomButton(label: 'Next →', onTap: controller.nextPage),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 7 – Experience
// ─────────────────────────────────────────────────────────────────────────────

class _ExperiencePage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _ExperiencePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 2),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience',
                        style: AppTextStyle.titleLargeBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your experience',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Years of Experience',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.yearsController,
                  hintText: 'e.g. 3',
                  borderRadius: 30,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'Previous Company (optional)',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.company1Controller,
                  hintText: 'Company name',
                  borderRadius: 30,
                ),
                const SizedBox(height: 16),
                Text(
                  'Previous Company (optional)',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.company2Controller,
                  hintText: 'Company name',
                  borderRadius: 30,
                ),
                const SizedBox(height: 16),
                _UploadRowTile(
                  label: 'Certificates',
                  actionLabel: '+ Add',
                  onTap: controller.pickCertificate,
                  files: controller.certificates,
                  onDelete: controller.removeCertificate,
                ),
                const SizedBox(height: 12),
                _UploadRowTile(
                  label: 'Portfolio Photos',
                  actionLabel: '+ Upload',
                  onTap: controller.pickPortfolioPhoto,
                  files: controller.portfolioPhotos,
                  onDelete: controller.removePortfolioPhoto,
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: controller.submitSkillsAndExperience,
              isLoading: controller.isSubmittingProfile.value,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 8 – Bank Details
// ─────────────────────────────────────────────────────────────────────────────

class _BankPage extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _BankPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TappableStepIndicator(controller: controller, step: 3),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank Details',
                        style: AppTextStyle.titleLargeBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your bank details for payouts.',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Holder Name',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.accountNameController,
                  hintText: 'As per bank records',
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bank Name',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.bankNameController,
                  hintText: 'e.g. HDFC Bank',
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),
                Text(
                  'Account Number',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.accountNumberController,
                  hintText: 'XXXXXXXXXXXXX',
                  borderRadius: 12,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'IFSC Code',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.ifscController,
                  hintText: 'SBIN0000123',
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'UPI ID',
                      style: AppTextStyle.bodyMediumMedium.copyWith(
                        color: AppColor.blackShade1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(optional)',
                      style: AppTextStyle.bodySmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CommonTextFormField(
                  controller: controller.upiController,
                  hintText: 'name@upi',
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final path = controller.cancelledCheque.value;
                  if (path != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FFF6),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              path.split('/').last,
                              style: AppTextStyle.bodySmallMedium.copyWith(
                                color: AppColor.blackShade1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final confirmed = await showDeleteFileDialog();
                              if (confirmed) {
                                controller.cancelledCheque.value = null;
                              }
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () =>
                        controller.pickAndSet(controller.cancelledCheque),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColor.lightGreyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cancelled Cheque',
                            style: AppTextStyle.bodyMediumMedium.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                          Text(
                            'Upload',
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: controller.submitBankDetails,
              isLoading: controller.isSubmittingBank.value,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 9 – Under Review  (reactive: pending / rejected states)
// ─────────────────────────────────────────────────────────────────────────────

class _UnderReviewPage extends GetView<TechnicianOnboardingController> {
  const _UnderReviewPage();

  // Map API documentId values → icon + display label
  static IconData _iconFor(String documentId) {
    switch (documentId) {
      case 'drivingLicenseFront':
      case 'drivingLicenseBack':
        return Icons.badge_outlined;
      case 'residentialProof':
        return Icons.home_outlined;
      case 'taxInformationW9':
      case 'taxInformation1099':
        return Icons.receipt_long_outlined;
      case 'cvResume':
        return Icons.description_outlined;
      case 'backgroundVerification':
        return Icons.security_outlined;
      case 'profilePhoto':
        return Icons.person_outline;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  // No merging — show each document exactly as the API returns it.
  // DL front and back are separate cards with separate re-upload targets.
  static List<DocumentItem> _prepareDocuments(List<DocumentItem> docs) {
    // Filter out profilePhoto from the re-upload list; user can't resubmit it here
    return docs.where((d) => d.documentId != 'profilePhoto').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.verificationStatus.value;
      final isRejected = status == 'rejected';

      if (isRejected) {
        return _RejectedView(
          controller: controller,
          prepareDocuments: _prepareDocuments,
          iconFor: _iconFor,
        );
      }
      // Default: pending / in-review state
      return _PendingReviewView(controller: controller);
    });
  }
}

// ── Pending / In-Review state ─────────────────────────────────────────────────

class _PendingReviewView extends StatelessWidget {
  final TechnicianOnboardingController controller;

  const _PendingReviewView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                const _StepIndicator(step: 4),
                const SizedBox(height: 40),
                // Icon circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5EFE6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4B896).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 52,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "We're Reviewing Your\nDocuments",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.headlineLargeBold.copyWith(
                    color: AppColor.blackShade1,
                    fontSize: 24,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Verification usually takes 24–72 Hours.',
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
                const SizedBox(height: 28),
                // Verification status timeline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Status',
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StatusItem(
                        color: Colors.green,
                        title: 'Documents Received',
                        subtitle: 'Completed',
                        isLast: false,
                      ),
                      _StatusItem(
                        color: Colors.orange,
                        title: 'Background and Document Verification',
                        subtitle: 'In progress',
                        isLast: false,
                        trailing: null,
                      ),
                      _StatusItem(
                        color: Colors.grey.shade300,
                        title: 'Final Approval',
                        subtitle: 'Pending',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rejected state ────────────────────────────────────────────────────────────

class _RejectedView extends StatelessWidget {
  final TechnicianOnboardingController controller;
  final List<DocumentItem> Function(List<DocumentItem>) prepareDocuments;
  final IconData Function(String) iconFor;

  const _RejectedView({
    required this.controller,
    required this.prepareDocuments,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = prepareDocuments(controller.documents.toList());
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top icon + headline ──────────────────────────────────
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFAEDE0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.insert_drive_file_outlined,
                              size: 56,
                              color: AppColor.brownAccentPrimary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Documents not Approved',
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: AppColor.blackShade1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Verification usually takes 24–72 Hours.',
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.coolGrayText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Action Required banner ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Action Required',
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Some documents need your attention. Please review the feedback below and update your documents to continue.',
                                style: AppTextStyle.bodySmallRegular.copyWith(
                                  color: AppColor.blackShade1,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Verification Status timeline ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Status',
                          style: AppTextStyle.titleSmallSemiBold.copyWith(
                            color: AppColor.blackShade1,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatusItem(
                          color: Colors.green,
                          title: 'Documents Received',
                          subtitle: 'Completed',
                          isLast: false,
                        ),
                        _StatusItem(
                          color: Colors.red,
                          title: 'Background and Document Verification',
                          subtitle: 'Rejected',
                          isLast: false,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                color: AppColor.brownAccentPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'View Feedback  ›',
                                style: AppTextStyle.bodySmallMedium.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusItem(
                          color: Colors.grey.shade300,
                          title: 'Final Approval',
                          subtitle: 'Pending',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Document cards ───────────────────────────────────────
                  ...docs.map(
                    (doc) => _DocumentCard(
                      doc: doc,
                      icon: iconFor(doc.documentId),
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom CTA ───────────────────────────────────────────────────
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: CommonButton(
                label: 'Confirm and Update Document',
                onTap: controller.submitReUpload,
                isLoading: controller.isReUploading.value,
                backgroundColor: AppColor.brownAccentPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Individual document card (approved or rejected) ───────────────────────────

class _DocumentCard extends StatefulWidget {
  final DocumentItem doc;
  final IconData icon;
  final TechnicianOnboardingController controller;

  const _DocumentCard({
    required this.doc,
    required this.icon,
    required this.controller,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _expanded = true; // rejection reason starts expanded

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final isRejected = doc.isRejected;

    // Filename extracted from s3Key for display ("…/abc.jpg" → "abc.jpg")
    final uploadedFileName = doc.s3Key.isNotEmpty
        ? doc.s3Key.split('/').last
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRejected
              ? Colors.red.withValues(alpha: 0.5)
              : AppColor.lightGreyColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? const Color(0xFFFFF0EE)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: isRejected
                        ? Colors.red
                        : AppColor.brownAccentPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.label,
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isRejected
                              ? Colors.red.withValues(alpha: 0.1)
                              : doc.status.toLowerCase() == 'pending'
                              ? Colors.yellow.withValues(alpha: 0.2)
                              : AppColor.lightGreen1Color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isRejected
                                ? Colors.red
                                : doc.status.toLowerCase() == 'pending'
                                ? Colors.orange.withValues(alpha: 0.2)
                                : AppColor.green2Color,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isRejected
                                    ? Colors.red
                                    : doc.status.toLowerCase() == 'pending'
                                    ? Colors.orange
                                    : AppColor.green2Color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isRejected
                                  ? 'Rejected'
                                  : doc.status.capitalizeFirst.toString(),
                              style: AppTextStyle.labelSmallMedium.copyWith(
                                color: isRejected
                                    ? Colors.red
                                    : doc.status.toLowerCase() == 'pending'
                                    ? Colors.orange
                                    : AppColor.green2Color,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Approved: show already-uploaded filename ─────────────────────
          if (!isRejected && uploadedFileName != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: doc.status.toLowerCase() == 'pending'
                      ? Colors.yellow.withValues(alpha: 0.2): Color(0xFFF6FFF6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color:  doc.status.toLowerCase() == 'pending'
                      ? Colors.orange.withValues(alpha: 0.2) :Colors.green.shade300),
                ),
                child: Row(
                  children: [
                     Icon(
                      Icons.insert_drive_file_outlined,
                      color: doc.status.toLowerCase() == 'pending'
                          ? Colors.orange :
                      Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploadedFileName,
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: AppColor.blackShade1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      doc.status.toLowerCase() == 'pending'
                          ? Icons.info
                          : Icons.check_circle,
                      color: doc.status.toLowerCase() == 'pending'
                          ? Colors.orange
                          : Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (!isRejected)
            const SizedBox(height: 14),

          // ── Rejected detail section ──────────────────────────────────────
          if (isRejected) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reason for rejection',
                      style: AppTextStyle.titleSmallSemiBold.copyWith(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  doc.rejectionReason?.isNotEmpty == true
                      ? doc.rejectionReason!
                      : 'Document is blurry and some information is not clearly visible.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.blackShade1,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // How to fix hint
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to fix',
                              style: AppTextStyle.bodySmallMedium.copyWith(
                                color: AppColor.blackShade1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please upload a clear, high-resolution image.\nAll edges and details should be visible.',
                              style: AppTextStyle.bodySmallRegular.copyWith(
                                color: AppColor.coolGrayText,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Re-upload button OR chosen file chip
              Obx(() {
                final newPath = widget.controller.reUploadPaths[doc.documentId];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: newPath != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6FFF6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  newPath.split('/').last,
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.blackShade1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => widget.controller.reUploadPaths
                                    .remove(doc.documentId),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.controller.pickReUploadFile(
                              doc.documentId,
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text('Re-upload Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: AppTextStyle.buttonMedium,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                );
              }),
              const SizedBox(height: 8),
              // "Go back to update" — navigates to the original doc page
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              //   child: GestureDetector(
              //     onTap: () =>
              //         widget.controller.goToDocPageForId(doc.documentId),
              //     child: Container(
              //       width: double.infinity,
              //       padding: const EdgeInsets.symmetric(vertical: 13),
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(10),
              //         border: Border.all(color: AppColor.lightGreyColor),
              //       ),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(
              //             Icons.arrow_back_ios_new,
              //             size: 14,
              //             color: AppColor.brownAccentPrimary,
              //           ),
              //           const SizedBox(width: 6),
              //           Text(
              //             'Go back to update this document',
              //             style: AppTextStyle.bodySmallMedium.copyWith(
              //               color: AppColor.brownAccentPrimary,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ] else
              const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status item widget (Under Review page)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusItem extends StatelessWidget {
  final Color color;
  final String title, subtitle;
  final bool isLast;
  final Widget? trailing;

  const _StatusItem({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isLast,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            if (!isLast)
              Container(width: 2, height: 36, color: AppColor.lightGreyColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared local widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Non-interactive outer step indicator (used only on Review page)
class _StepIndicator extends StatelessWidget {
  final int step; // 1-4
  const _StepIndicator({required this.step});

  static const _labels = ['Documents', 'Skills', 'Bank', 'Review'];

  @override
  Widget build(BuildContext context) => OnboardingStepIndicator(
    currentStep: step,
    totalSteps: 4,
    labels: _labels,
  );
}

/// Tappable outer step indicator — users can tap steps they have already reached.
/// Forward navigation is blocked if the step hasn't been unlocked yet.
class _TappableStepIndicator extends StatelessWidget {
  final TechnicianOnboardingController controller;
  final int step; // active step shown in the indicator (1-4)
  const _TappableStepIndicator({required this.controller, required this.step});

  static const _labels = ['Documents', 'Skills', 'Bank', 'Review'];

  // Fixed width per step "column" (circle + label). Wide enough for the
  // longest label ('Documents') on one line without widening the row.
  static const double _stepWidth = 60;
  static const double _circleSize = 36;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const totalSteps = 4;
      // Highest step the user has reached (based on current page)
      final highestStep = controller.indicatorStep;

      return Row(
        // start (not center) so a label wrapping to 2 lines on one step
        // never pushes that step's circle out of vertical alignment.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < step - 1;
            // Height-matched to the circle and vertically centered
            // within it, so the connector always meets the circle's
            // midpoint regardless of label height beneath.
            return Expanded(
              child: SizedBox(
                height: _circleSize,
                child: Center(
                  child: Container(
                    height: 2,
                    color:
                    done ? AppColor.blackShade1 : AppColor.lightGreyColor,
                  ),
                ),
              ),
            );
          }

          final s = i ~/ 2 + 1;
          final done = s < step;
          final active = s == step;
          final unlocked = s <= highestStep;

          // Circle and its label live in the SAME Column, inside the SAME
          // fixed-width box — so whatever width this box resolves to,
          // both are centered relative to each other. The old two-Row
          // layout couldn't guarantee this: each Row resolved its
          // Expanded connector widths independently, and the label Text
          // widgets had intrinsic (not fixed) widths, so a long label
          // like "Documents" threw its row's layout out of step with the
          // circle row above it.
          return SizedBox(
            width: _stepWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => controller.tryGoToStep(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (done || active)
                          ? AppColor.blackShade1
                          : Colors.white,
                      border: Border.all(
                        color: (done || active)
                            ? AppColor.blackShade1
                            : AppColor.lightGreyColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: unlocked
                          ? Text(
                        '$s',
                        style: AppTextStyle.labelSmallMedium.copyWith(
                          color: (done || active)
                              ? Colors.white
                              : AppColor.coolGrayText,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                          : Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: (done || active)
                            ? Colors.white
                            : AppColor.coolGrayText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _labels[s - 1],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.labelSmallRegular.copyWith(
                    color: (done || active)
                        ? AppColor.blackShade1
                        : AppColor.coolGrayText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

/// Inner 5-dot indicator used inside doc sub-steps (1–5)
class _DocSubStepIndicator extends StatelessWidget {
  final int currentDoc; // 1-5
  const _DocSubStepIndicator({required this.currentDoc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(9, (i) {
        if (i.isOdd) {
          final done = i ~/ 2 < currentDoc - 1;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? AppColor.blackShade1 : AppColor.lightGreyColor,
            ),
          );
        }
        final s = i ~/ 2 + 1;
        final active = s <= currentDoc;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColor.blackShade1 : Colors.white,
            border: Border.all(
              color: active ? AppColor.blackShade1 : AppColor.lightGreyColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$s',
              style: AppTextStyle.labelSmallMedium.copyWith(
                color: active ? Colors.white : AppColor.coolGrayText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Label with a red asterisk suffix — e.g. "Upload Front *"
class _RequiredLabel extends StatelessWidget {
  final String text;
  const _RequiredLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTextStyle.titleSmallSemiBold.copyWith(
              color: AppColor.blackShade1,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sticky button shared across all pages
class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _BottomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: CommonButton(
      label: label,
      onTap: onTap ?? () {},
      enabled: onTap != null,
      backgroundColor: AppColor.brownAccentPrimary,
      foregroundColor: Colors.white,
    ),
  );
}

/// Radio-style option row (used in tax info page)
class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
            Text(
              label,
              style: AppTextStyle.bodyMediumRegular.copyWith(
                color: AppColor.blackShade1,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColor.brownAccentPrimary
                      : AppColor.lightGreyColor,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.brownAccentPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Upload row tile with file chips (used in experience page)
class _UploadRowTile extends StatelessWidget {
  final String label, actionLabel;
  final VoidCallback onTap;
  final RxList<String>? files;
  final Future<void> Function(String)? onDelete;

  const _UploadRowTile({
    required this.label,
    required this.actionLabel,
    required this.onTap,
    this.files,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                Text(
                  actionLabel,
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (files != null)
          Obx(
            () => files!.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: files!.map((path) {
                        final name = path.split('/').last;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6FFF6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 140,
                                ),
                                child: Text(
                                  name,
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.blackShade1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () async {
                                  final confirmed =
                                      await showDeleteFileDialog();
                                  if (confirmed) onDelete?.call(path);
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
      ],
    );
  }
}
