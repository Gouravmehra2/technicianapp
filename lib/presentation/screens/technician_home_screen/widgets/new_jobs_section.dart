import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import '../technician_home_controller.dart';

class NewJobsSection extends StatelessWidget {
  final TechnicianHomeController controller;

  const NewJobsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Jobs',
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAllNewJobs,
                child: Text(
                  'View All',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            if (controller.newJobs.isEmpty) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No new jobs available right now.',
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: AppColor.coolGrayText,
                      ),
                    ),
                  ),
                ),
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < controller.newJobs.length; i++) ...[
                    _NewJobCard(
                      job: controller.newJobs[i],
                      controller: controller,
                    ),
                    if (i < controller.newJobs.length - 1)
                      const SizedBox(width: 12),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _NewJobCard extends StatelessWidget {
  final Jobs job;
  final TechnicianHomeController controller;

  const _NewJobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5B0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row with NEW badge ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.brownAccentPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title ?? 'Untitled Job',
                  style: AppTextStyle.titleMediumSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Service type + pay type chips ───────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if ((job.serviceType?.name ?? '').isNotEmpty)
                _HomeMetaChip(
                  label: job.serviceType!.name!,
                  bgColor: const Color(0xFFFFF3E0),
                  textColor: AppColor.brownAccentPrimary,
                  icon: Icons.build_outlined,
                ),
              _HomeMetaChip(
                label: controller.jobController.payTypeLabel(job),
                bgColor: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF2E7D32),
                icon: Icons.payment_outlined,
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Location & category ─────────────────────────────────
          InfoRow(
            icon: Icons.location_on_outlined,
            text: '${job.location ?? 'No location'}',
          ),
          const SizedBox(height: 4),

          // ── Schedule time ────────────────────────────────────────
          InfoRow(
            icon: Icons.access_time_outlined,
            text: controller.jobController.scheduleTimeLabel(job),
          ),
          const SizedBox(height: 4),

          // ── Est. Pay amount ──────────────────────────────────────
          InfoRow(
            icon: Icons.credit_card_outlined,
            text: controller.jobController.estPayLabel(job),
            bold: true,
          ),

          // // ── Description ─────────────────────────────────────────
          // if (description.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   const Divider(height: 1, color: Color(0xFFF0E6D0)),
          //   const SizedBox(height: 10),
          //   Text(
          //     'Description',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Text(
          //     description,
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.blackShade1,
          //     ),
          //     maxLines: 3,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          // ],
          //
          // // ── Requirements ────────────────────────────────────────
          // if (requirements.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   Text(
          //     'Requirements',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Wrap(
          //     spacing: 6,
          //     runSpacing: 4,
          //     children: requirements.map((r) => _Chip(label: r)).toList(),
          //   ),
          // ],
          //
          // // ── Preferred Skills ────────────────────────────────────
          // if (preferredSkills.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   Text(
          //     'Preferred Skills',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Wrap(
          //     spacing: 6,
          //     runSpacing: 4,
          //     children: preferredSkills
          //         .map((s) => _Chip(label: s, accent: true))
          //         .toList(),
          //   ),
          // ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0E6D0)),
          const SizedBox(height: 12),

          // ── Navigate button ─────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => controller.onNavigateJobTapped(job),
            icon: const Icon(Icons.navigation_outlined, size: 16),
            label: const Text('NAVIGATE'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.blackShade1,
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 42),
              textStyle: AppTextStyle.labelSmallMedium.copyWith(
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Action buttons ──────────────────────────────────────
          Obx(() {
            final isRequesting = controller.requestingJobIds.contains(
              job.sId ?? '',
            );
            return Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isRequesting
                        ? null
                        : () => controller.onRequestJob(job),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.brownAccentPrimary),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isRequesting
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.brownAccentPrimary,
                                ),
                              )
                            : Text(
                                'Request job',
                                key: const ValueKey('label'),
                                style: AppTextStyle.buttonSmall.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.onCounterOffer(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.brownAccentPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      'Counter Offer',
                      style: AppTextStyle.buttonSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.onViewNewJobDetails(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.brownAccentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
              ),
              child: Text(
                'View Full Details',
                style: AppTextStyle.buttonSmall.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const InfoRow({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppColor.brownAccentPrimary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.bodySmallMedium.copyWith(
              color: AppColor.blackShade1,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool accent;

  const _Chip({required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent
            ? AppColor.brownAccentPrimary.withValues(alpha: 0.10)
            : const Color(0xFFF5EDD8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent
              ? AppColor.brownAccentPrimary.withValues(alpha: 0.30)
              : const Color(0xFFE8D5B0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: accent ? AppColor.brownAccentPrimary : AppColor.blackShade1,
        ),
      ),
    );
  }
}

// ─── Home Meta Chip ───────────────────────────────────────────────────────────

class _HomeMetaChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  const _HomeMetaChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
