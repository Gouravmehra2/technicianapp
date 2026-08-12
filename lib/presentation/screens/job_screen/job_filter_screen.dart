import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'job_filter_controller.dart';

class JobFilterScreen extends GetView<JobFilterController> {
  JobFilterScreen({super.key});

  @override
  final controller = Get.put(JobFilterController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
        ),
        title: const Text(
          'Filter Jobs',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: controller.resetFilters,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Reset',
                style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Service Category ────────────────────────────────────
                  _SectionHeader(title: 'Service Category', actionLabel: 'See All', onAction: () {}),
                  const SizedBox(height: 12),
                  _ServiceCategoryRow(controller: controller),
                  _Divider(),

                  // ── Distance ────────────────────────────────────────────
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
                      Obx(() => Text(
                        'Within ${controller.distanceKm.value.toInt()} km',
                        style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColor.brownAccentPrimary,
                      inactiveTrackColor: AppColor.lightGreyColor,
                      thumbColor: AppColor.brownAccentPrimary,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: controller.distanceKm.value,
                      min: 0,
                      max: 25,
                      onChanged: (v) => controller.distanceKm.value = v,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0 km', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                        Text('25 km', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                      ],
                    ),
                  ),
                  _Divider(),

                  // ── Minimum Earning ─────────────────────────────────────
                  const SizedBox(height: 16),
                  Text('Minimum Earning', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 12),
                   _EarningChips(controller: controller),
                  _Divider(),

                  // ── Job Type ────────────────────────────────────────────
                  const SizedBox(height: 16),
                  Text('Job Type', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                    children: controller.jobTypes.map((type) {
                      final checked = controller.selectedJobTypes.contains(type);
                      return _CheckboxRow(
                        label: type,
                        checked: checked,
                        onTap: () => controller.toggleJobType(type),
                      );
                    }).toList(),
                  )),
                  _Divider(),

                  // ── Date ────────────────────────────────────────────────
                  const SizedBox(height: 16),
                  Text('Date', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                    children: controller.dateOptions.map((opt) {
                      final selected = controller.selectedDate.value == opt;
                      return _RadioRow(
                        label: opt,
                        selected: selected,
                        onTap: () => controller.selectDate(opt),
                      );
                    }).toList(),
                  )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // ── Apply Button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: GestureDetector(
              onTap: controller.applyFilters,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary),
          ),
        ),
      ],
    );
  }
}

// ─── Service Category Row ────────────────────────────────────────────────────

class _ServiceCategoryRow extends StatelessWidget {
  final JobFilterController controller;
  const _ServiceCategoryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.categories.map((cat) {
          final selected = controller.selectedCategory.value == cat.label;
          return GestureDetector(
            onTap: () => controller.selectCategory(cat.label),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFFF3E0) : const Color(0xFFF4F4F4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColor.brownAccentPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      cat.icon,
                      color: selected ? AppColor.brownAccentPrimary : AppColor.coolGrayText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.label,
                    style: AppTextStyle.labelSmallMedium.copyWith(
                      color: selected ? AppColor.brownAccentPrimary : AppColor.coolGrayText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Earning Chips ────────────────────────────────────────────────────────────

class _EarningChips extends StatelessWidget {
  final JobFilterController controller;
  const _EarningChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: controller.earningOptions.map((opt) {
        final selected = controller.selectedEarning.value == opt;
        return GestureDetector(
          onTap: () => controller.selectEarning(opt),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColor.brownAccentPrimary : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
              ),
            ),
            child: Text(
              opt,
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: selected ? Colors.white : AppColor.blackShade1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Checkbox Row ────────────────────────────────────────────────────────────

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _CheckboxRow({required this.label, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? AppColor.brownAccentPrimary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1)),
          ],
        ),
      ),
    );
  }
}

// ─── Radio Row ────────────────────────────────────────────────────────────────

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColor.brownAccentPrimary : Colors.white,
                border: Border.all(
                  color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 5,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1)),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
    );
  }
}
