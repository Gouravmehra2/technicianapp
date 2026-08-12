import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/booking_safety_screen/booking_safety_controller.dart';

class BookingSafetyScreen extends GetView<BookingSafetyController> {
  const BookingSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Booking Safety Guide',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ── Hero card ──────────────────────────────────────────────────
          _Card(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColor.brownAccentPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Protecting You Every Step of the Way',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.titleLargeBold.copyWith(
                    color: AppColor.brownAccentPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'All services booked through 1App are monitored and supported to ensure a safe, transparent, and reliable experience. Follow these simple steps for a smooth service journey.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Steps ──────────────────────────────────────────────────────
          ...controller.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StepCard(step: step),
            ),
          ),

          // ── Report Safety Concerns ─────────────────────────────────────
          _ReportCard(controller: controller),
        ],
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final BookingSafetyStep step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: step number + vertical line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${step.number}',
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 2,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Right: content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.brownAccentPrimary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        step.icon,
                        size: 20,
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: AppColor.blackShade1,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            step.subtitle,
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Body text
                Text(
                  step.body,
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),

                // Tip chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColor.brownAccentPrimary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          step.tip,
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: AppColor.brownAccentPrimary,
                            height: 1.5,
                          ),
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
    );
  }
}

// ── Report safety concerns card ───────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final BookingSafetyController controller;

  const _ReportCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Report Safety Concerns',
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bullet list
          ...controller.safetyReportItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: AppColor.coolGrayText),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.blackShade1,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            'Please report it immediately through the app.',
            style: AppTextStyle.bodyMediumRegular.copyWith(
              color: AppColor.coolGrayText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  label: 'Report an Issue',
                  onTap: controller.onReportIssue,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  border: Border.all(color: Colors.redAccent),
                  height: 46,
                  paddingHorizontal: 6,
                  textStyle: AppTextStyle.buttonSmall,
                  boxShadow: const [],
                  leadingIcon: const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 16),
                  leadingSpacing: 4,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  label: 'Contact Support',
                  onTap: controller.onContactSupport,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColor.brownAccentPrimary,
                  border: Border.all(color: AppColor.brownAccentPrimary),
                  height: 46,
                  paddingHorizontal: 6,
                  textStyle: AppTextStyle.buttonSmall,
                  boxShadow: const [],
                  leadingIcon: const Icon(Icons.phone_outlined,
                      color: AppColor.brownAccentPrimary, size: 16),
                  leadingSpacing: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared card ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: child,
    );
  }
}
