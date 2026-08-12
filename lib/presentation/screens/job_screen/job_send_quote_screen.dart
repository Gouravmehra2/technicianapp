import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'job_send_quote_controller.dart';

class JobSendQuoteScreen extends GetView<JobSendQuoteController> {
  JobSendQuoteScreen({super.key});

  @override
  final controller = Get.put(JobSendQuoteController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient backdrop
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.brownAccentPrimary.withValues(alpha: 0.5),
                  const Color(0xFFFFF3E0),
                ],
                stops: const [0.0, 0.35],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ───────────────────────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Send Custom Quote',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: const Icon(Icons.close, color: AppColor.coolGrayText, size: 22),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // ── Job Preview Card ─────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'TV Wall Mounting',
                                          style: AppTextStyle.titleSmallSemiBold.copyWith(
                                            color: AppColor.blackShade1,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 11, color: AppColor.brownAccentPrimary),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Northside',
                                                style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.brownAccentPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Req #892-A',
                                      style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.brownAccentPrimary),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '"Looking to get an 85-inch Samsung mounted on a brick fireplace. Need all cables concealed. I do not have a bracket yet."',
                                      style: AppTextStyle.bodySmallRegular.copyWith(
                                        color: AppColor.coolGrayText,
                                        fontStyle: FontStyle.italic,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // ── Base Quote ───────────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Your Base Quote',
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.6)),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(color: AppColor.lightGreyColor),
                                        ),
                                      ),
                                      child: Text(
                                        '\$',
                                        style: AppTextStyle.titleMediumSemiBold.copyWith(
                                          color: AppColor.brownAccentPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.baseQuoteController,
                                        keyboardType: TextInputType.number,
                                        style: AppTextStyle.titleMediumSemiBold.copyWith(color: AppColor.blackShade1),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0.00',
                                          hintStyle: AppTextStyle.titleMediumSemiBold.copyWith(color: AppColor.lightGreyColor),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // ── Additional Charges ───────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Additional Charges',
                                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                                      color: AppColor.blackShade1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Optional',
                                    style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.brownAccentPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(() => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: controller.additionalCharges.map((charge) {
                                  final enabled = controller.enabledCharges.contains(charge.key);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _AdditionalChargeRow(
                                      label: charge.key,
                                      controller: charge.value,
                                      enabled: enabled,
                                      onToggle: () => controller.toggleCharge(charge.key),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )),
                            const SizedBox(height: 16),
                            // ── Estimated Completion ─────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Estimated Completion',
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.lightGreyColor),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 14),
                                      child: Icon(Icons.access_time_outlined, size: 18, color: AppColor.coolGrayText),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.estimatedCompletionController,
                                        style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'e.g. 1-2 hours',
                                          hintStyle: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.lightGreyColor),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // ── Quote Note ───────────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Quote Note',
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.lightGreyColor),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextField(
                                  controller: controller.noteController,
                                  maxLines: 4,
                                  style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Explain your quote, parts included, or any specific requirements...',
                                    hintStyle: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.lightGreyColor),
                                    contentPadding: const EdgeInsets.all(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // ── Send Quote Button ─────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GestureDetector(
                                onTap: controller.sendQuote,
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
                                      const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Send Quote',
                                        style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
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

// ─── Additional Charge Row ────────────────────────────────────────────────────

class _AdditionalChargeRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onToggle;
  const _AdditionalChargeRow({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Checkbox
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: enabled ? AppColor.brownAccentPrimary : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: enabled ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                width: 1.5,
              ),
            ),
            child: enabled
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        // Label
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: AppTextStyle.bodyMediumRegular.copyWith(
              color: enabled ? AppColor.blackShade1 : AppColor.coolGrayText,
            ),
          ),
        ),
        // Amount field
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: enabled ? AppColor.brownAccentPrimary.withValues(alpha: 0.5) : AppColor.lightGreyColor),
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFFFFF8EE),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '\$',
                    style: AppTextStyle.bodySmallMedium.copyWith(
                      color: enabled ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.lightGreyColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      isDense: true,
                    ),
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
