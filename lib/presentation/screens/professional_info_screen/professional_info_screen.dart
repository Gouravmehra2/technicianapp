import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'professional_info_controller.dart';

class ProfessionalInfoScreen extends GetView<ProfessionalInfoController> {
  const ProfessionalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'Professional Information',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: [
                // ─── Trade & Skills ──────────────────────────────────
                _SectionCard(
                  children: [
                    // Primary Trade dropdown
                    _FieldLabel(label: 'Primary Trade'),
                    const SizedBox(height: 8),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.lightGreyColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_outlined,
                                color: AppColor.brownAccentPrimary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                controller.primaryTrade.value,
                                style: AppTextStyle.bodyMediumRegular
                                    .copyWith(color: AppColor.blackShade1),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: AppColor.coolGrayText, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Secondary Skills chips
                    _FieldLabel(label: 'Secondary Skills (Multi-select)'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...controller.skills.map(
                              (skill) => Obx(
                                () => GestureDetector(
                              onTap: () => controller.toggleSkill(skill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: skill.isSelected.value
                                      ? AppColor.brownAccentPrimary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: skill.isSelected.value
                                        ? AppColor.brownAccentPrimary
                                        : AppColor.lightGreyColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (skill.isSelected.value) ...[
                                      const Icon(Icons.check,
                                          size: 13, color: Colors.white),
                                      const SizedBox(width: 4),
                                    ] else ...[
                                      const Icon(Icons.add,
                                          size: 13, color: AppColor.coolGrayText),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      skill.name,
                                      style: AppTextStyle.bodySmallMedium.copyWith(
                                        color: skill.isSelected.value
                                            ? Colors.white
                                            : AppColor.coolGrayText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Add More chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColor.brownAccentPrimary,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 13,
                                  color: AppColor.brownAccentPrimary),
                              const SizedBox(width: 4),
                              Text(
                                'Add More',
                                style: AppTextStyle.bodySmallMedium.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Experience slider ───────────────────────────────
                _SectionCard(
                  children: [
                    _FieldLabel(label: 'Experience'),
                    const SizedBox(height: 12),
                    // Thumb display
                    Center(
                      child: Obx(
                        () => Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColor.brownAccentPrimary),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${controller.experience.value.toInt()}',
                                style: AppTextStyle.headlineLargeBold.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                  fontSize: 26,
                                ),
                              ),
                              Text(
                                'Years',
                                style: AppTextStyle.labelSmallRegular.copyWith(
                                  color: AppColor.coolGrayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColor.brownAccentPrimary,
                          inactiveTrackColor: AppColor.lightGreyColor,
                          thumbColor: AppColor.brownAccentPrimary,
                          overlayColor: AppColor.brownAccentPrimary.withValues(alpha: 0.1),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          min: 0,
                          max: 20,
                          divisions: 20,
                          value: controller.experience.value,
                          onChanged: (v) => controller.experience.value = v,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Newbie',
                              style: AppTextStyle.labelSmallRegular
                                  .copyWith(color: AppColor.coolGrayText)),
                          Text('Expert',
                              style: AppTextStyle.labelSmallRegular
                                  .copyWith(color: AppColor.coolGrayText)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Weekly Availability ────────────────────────────
                _SectionCard(
                  children: [
                    _FieldLabel(label: 'Weekly Availability'),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        return Obx(
                          () => GestureDetector(
                            onTap: () => controller.toggleDay(i),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: controller.availability[i].value
                                    ? AppColor.brownAccentPrimary
                                    : const Color(0xFFF6F6F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: controller.availability[i].value
                                      ? AppColor.brownAccentPrimary
                                      : AppColor.lightGreyColor,
                                ),
                              ),
                              child: Center(
                                child: controller.availability[i].value
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : Text(
                                        controller.dayLabels[i],
                                        style: AppTextStyle.bodySmallMedium.copyWith(
                                          color: AppColor.coolGrayText,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            color: AppColor.coolGrayText, size: 16),
                        const SizedBox(width: 8),
                        Obx(
                          () => Text(
                            '${controller.workStart.value} — ${controller.workEnd.value}',
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Edit',
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    _FieldLabel(label: 'Logistics'),
                    const SizedBox(height: 10),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.pedal_bike_outlined,
                                      color: AppColor.brownAccentPrimary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Own Vehicle: Yes (${controller.vehicleType.value})',
                                      style: AppTextStyle.bodySmallMedium.copyWith(
                                        color: AppColor.blackShade1,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle,
                                      color: AppColor.brownAccentPrimary, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.handyman_outlined,
                              color: AppColor.brownAccentPrimary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Own Tools: Yes',
                              style: AppTextStyle.bodySmallMedium.copyWith(
                                color: AppColor.blackShade1,
                              ),
                            ),
                          ),
                          const Icon(Icons.check_circle,
                              color: AppColor.brownAccentPrimary, size: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _FieldLabel(label: 'Languages'),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.languages.value,
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.blackShade1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Professional Bio ─────────────────────────────────
                _SectionCard(
                  children: [
                    Row(
                      children: [
                        _FieldLabel(label: 'Professional Bio'),
                        const Spacer(),
                        Text(
                          'Optional',
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: AppColor.coolGrayText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.bioController,
                      maxLines: 5,
                      maxLength: 500,
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.blackShade1,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColor.lightGreyColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColor.lightGreyColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColor.brownAccentPrimary),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${controller.bioLength.value} / 500 characters',
                          style: AppTextStyle.labelSmallRegular.copyWith(
                            color: AppColor.coolGrayText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ─── Certificates & Licenses ─────────────────────────
                _SectionCard(
                  children: [
                    _FieldLabel(label: 'Certificates & Licenses'),
                    const SizedBox(height: 14),
                    ...controller.certificates.map(
                      (cert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F6F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_outlined,
                                  color: AppColor.coolGrayText, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cert['title']!,
                                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                                      color: AppColor.blackShade1,
                                    ),
                                  ),
                                  Text(
                                    cert['subtitle']!,
                                    style: AppTextStyle.bodySmallRegular.copyWith(
                                      color: AppColor.coolGrayText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.upload_outlined,
                                    color: AppColor.brownAccentPrimary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Upload',
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.brownAccentPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ─── Save Profile button (sticky) ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            color: const Color(0xffF6F6F6),
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.onSave,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Save Profile',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Changes are saved automatically as you type.',
                  style: AppTextStyle.labelSmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

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
        border: Border.all(color: AppColor.lightGreyColor),
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
      style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Color(0xFFEEEEEE), shape: BoxShape.circle),
        child: const Icon(Icons.chevron_left, color: AppColor.blackShade1, size: 24),
      ),
    );
  }
}
