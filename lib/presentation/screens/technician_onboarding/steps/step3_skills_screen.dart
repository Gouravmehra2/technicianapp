import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

class Step3SkillsScreen extends GetView<TechnicianOnboardingController> {
  const Step3SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Skill Set Updation'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingStepIndicator(currentStep: 3),
                  const SizedBox(height: 16),
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
                        Text('Skill Set Updation', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Select all that skills apply.', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
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
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.filteredSkills.map((skill) {
                      final selected = controller.selectedSkills.contains(skill);
                      return GestureDetector(
                        onTap: () => controller.toggleSkill(skill),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColor.blackShade1 : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: selected ? AppColor.blackShade1 : AppColor.lightGreyColor),
                          ),
                          child: Text(skill, style: AppTextStyle.bodyMediumMedium.copyWith(color: selected ? Colors.white : AppColor.blackShade1)),
                        ),
                      );
                    }).toList(),
                  )),
                  const SizedBox(height: 24),
                  Text('EXPERIENCE LEVEL', style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.blackShade1, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Obx(() => Row(
                    children: ['Beginner', 'Intermediate', 'Expert'].map((level) {
                      final selected = controller.experienceLevel.value == level;
                      return GestureDetector(
                        onTap: () => controller.experienceLevel.value = level,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColor.blackShade1 : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: selected ? AppColor.blackShade1 : AppColor.lightGreyColor),
                          ),
                          child: Text(level, style: AppTextStyle.bodyMediumMedium.copyWith(color: selected ? Colors.white : AppColor.blackShade1)),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () => Get.toNamed(AppRoutes.technicianExperienceScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Step3bExperienceScreen extends GetView<TechnicianOnboardingController> {
  const Step3bExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Update Experience'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingStepIndicator(currentStep: 3),
                  const SizedBox(height: 16),
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
                        Text('Experience', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Update your experience', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Years of Experience'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.yearsController, hintText: 'Search categories', borderRadius: 30, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _FieldLabel('Previous Company (optional)'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.company1Controller, hintText: 'Search categories', borderRadius: 30),
                  const SizedBox(height: 16),
                  _FieldLabel('Previous Company (optional)'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.company2Controller, hintText: 'Search categories', borderRadius: 30),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: () => Get.toNamed(AppRoutes.technicianBankScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.blackShade1));
}

class _UploadRowTile extends StatelessWidget {
  final String label, actionLabel;
  final VoidCallback onTap;
  final RxList<String>? files;
  final Future<void> Function(String)? onDelete;
  const _UploadRowTile({required this.label, required this.actionLabel, required this.onTap, this.files, this.onDelete});

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
                Text(label, style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.blackShade1)),
                Text(actionLabel, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
              ],
            ),
          ),
        ),
        if (files != null)
          Obx(() => files!.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: files!.map((path) {
                      final name = path.split('/').last;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FFF6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(name, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () async {
                                final confirmed = await showDeleteFileDialog();
                                if (confirmed) onDelete?.call(path);
                              },
                              child: const Icon(Icons.close, size: 14, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )),
      ],
    );
  }
}
