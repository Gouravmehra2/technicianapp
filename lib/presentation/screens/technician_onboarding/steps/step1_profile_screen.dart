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

class Step1ProfileScreen extends GetView<TechnicianOnboardingController> {
  const Step1ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Identity Verification'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  const OnboardingStepIndicator(currentStep: 1),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Stack(
                      children: [
                      CircleAvatar(
                      radius: 52,
                      backgroundImage:  const AssetImage('assets/images/person_image.png'),
                    ),
                        // Obx(() {
                        //   final path = controller.data.profileImagePath;
                        //   return CircleAvatar(
                        //     radius: 52,
                        //     backgroundImage: path != null
                        //         ? FileImage(File(path)) as ImageProvider
                        //         : const AssetImage('assets/images/person_image.png'),
                        //   );
                        // }),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColor.lightGreyColor),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColor.brownAccentPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Text('Change Picture', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Full Name'),
                        const SizedBox(height: 6),
                        CommonTextFormField(controller: controller.nameController, hintText: 'Gourav Mehra', prefixIcon: Icons.person_outline, borderRadius: 12),
                        const SizedBox(height: 14),
                        _LabelRow('Phone Number', 'Change Phone Number?'),
                        const SizedBox(height: 6),
                        CommonTextFormField(controller: controller.phoneController, prefixIcon: Icons.phone_outlined, readOnly: true, borderRadius: 12),
                        const SizedBox(height: 14),
                        _LabelRow('Email Address', 'Change Email Address?'),
                        const SizedBox(height: 6),
                        CommonTextFormField(controller: controller.emailController, prefixIcon: Icons.mail_outline, borderRadius: 12),
                        const SizedBox(height: 14),
                        _Label('Gender'),
                        const SizedBox(height: 6),
                        Obx(() => _DropdownField(
                          value: controller.gender.value,
                          items: const ['Male', 'Female', 'Other'],
                          onChanged: (v) => controller.gender.value = v ?? controller.gender.value,
                        )),
                        const SizedBox(height: 14),
                        _Label('Date of Birth'),
                        const SizedBox(height: 6),
                        Obx(() => CommonTextFormField(
                          hintText: controller.dob.value,
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => controller.pickDate(context),
                          suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20, color: AppColor.coolGrayText),
                          borderRadius: 12,
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
              label: 'Continue →',
              onTap: () => Get.toNamed(AppRoutes.technicianDocOverviewScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1));
}

class _LabelRow extends StatelessWidget {
  final String label, action;
  const _LabelRow(this.label, this.action);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
          Text(action, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
        ],
      );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 20, color: AppColor.coolGrayText),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColor.coolGrayText),
                style: AppTextStyle.titleSmallMedium.copyWith(color: AppColor.blackShade1),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
