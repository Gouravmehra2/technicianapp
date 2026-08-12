import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_country_code_picker.dart';
import 'package:technicianapp/constant/common_widgets/common_dialog.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/personal_information_screen/personal_information_controller.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PersonalInformationController>();
    return MyScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profile',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile picture ──────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      CommonDialog.showImagePickerDialog();
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundImage: const AssetImage(
                            'assets/images/person_image.png',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.lightGreyColor,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(onTap: ()=>CommonDialog.showImagePickerDialog(),
                    child: Text(
                      'Change Picture',
                      style: AppTextStyle.titleSmallSemiBold.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Personal info card ───────────────────────────────────────────
            _SectionCard(
              children: [
                CommonTextFormField(
                  label: 'Full Name',
                  hintText: 'Jagriti Sachdeva',
                  prefixIcon: Icons.person_outline,
                  controller: c.nameController,
                  borderRadius: 10.0,
                ),
                const SizedBox(height: 16),
                CommonTextFormField(
                  label: 'Phone Number',
                  hintText: '+91 94639 XXXXX',
                  prefixIcon: Icons.phone_outlined,
                  controller: c.phoneController,
                  readOnly: true,
                  backgroundColor: AppColor.lightGreyColor,
                  borderRadius: 10.0,
                ),
                const SizedBox(height: 16),
                CommonTextFormField.email(
                  label: 'Email Address',
                  hintText: 'jags.jagriti12@gmail.com',
                  controller: c.emailController,
                  backgroundColor: AppColor.lightGreyColor,
                  borderRadius: 10.0,
                ),
                const SizedBox(height: 16),
                // Gender dropdown
                _FieldLabel(label: 'Gender'),
                const SizedBox(height: 6),
                Obx(
                  () => _DropdownField(
                    value: c.gender.value,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (v) => c.gender.value = v ?? c.gender.value,
                  ),
                ),
                const SizedBox(height: 16),
                // Date of birth
                _FieldLabel(label: 'Date of Birth'),
                const SizedBox(height: 6),
                Obx(
                  () => CommonTextFormField(
                    borderRadius: 10.0,
                    hintText: c.dob.value,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => c.pickDate(context),
                    suffixIcon: const Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: AppColor.coolGrayText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Additional Contact ───────────────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  color: AppColor.brownAccentPrimary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Additional Contact',
                  style: AppTextStyle.headlineSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                Text(
                  'Alternative Phone',
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CommonCountryCodePicker(
                      onChanged: c.onCountryChanged,
                      initialSelection: 'IN',
                      height: 52,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CommonTextFormField(
                        hintText: '(555) 000-0000',
                        keyboardType: TextInputType.phone,
                        controller: c.altPhoneController,
                        borderRadius: 12,
                        backgroundColor: AppColor.lightGreyColor,
                        borderColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Used only for account recovery and critical security alerts.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Save button ──────────────────────────────────────────────────
            CommonButton(
              label: 'Save Profile',
              onTap: c.saveProfile,
              backgroundColor: AppColor.brownAccentPrimary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.brownAccentPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.titleSmallSemiBold.copyWith(
        color: AppColor.blackShade1,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightGreyColor, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            size: 20,
            color: AppColor.coolGrayText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColor.coolGrayText,
                ),
                style: AppTextStyle.titleSmallMedium.copyWith(
                  color: AppColor.blackShade1,
                ),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
