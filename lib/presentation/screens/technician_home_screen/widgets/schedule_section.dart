import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/app_shimmer.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import '../technician_home_controller.dart';
import 'new_jobs_section.dart';

class ScheduleSection extends StatelessWidget {
  final TechnicianHomeController controller;

  const ScheduleSection({super.key, required this.controller});

  String _formatTime(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $period';
    } catch (_) {
      return '';
    }
  }

  String _getStatusDisplay(String? status) {
    if (status == null) return 'UPCOMING';
    if (status.toLowerCase() == 'in-progress') return 'IN PROGRESS';
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isScheduleLoading.value;
      final jobs = controller.todayScheduledJobs;

      // Show shimmer while loading on first fetch
      if (isLoading && jobs.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppShimmer(
                child: const ShimmerBox(width: 140, height: 20),
              ),
            ),
            const SizedBox(height: 12),
            const ScheduleJobCardShimmer(),
          ],
        );
      }

      // Nothing to show
      if (jobs.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Schedule",
                  style: AppTextStyle.titleLargeBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                GestureDetector(
                  onTap: controller.onViewAllSchedule,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: AppColor.brownAccentPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColor.brownAccentPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Cards ─────────────────────────────────────────────────────
          Column(
            children: jobs
                .map(
                  (job) => _ScheduleJobCard(
                    job: job,
                    controller: controller,
                    formatTime: _formatTime,
                    getStatusDisplay: _getStatusDisplay,
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────

class _ScheduleJobCard extends StatelessWidget {
  final Jobs job;
  final TechnicianHomeController controller;
  final String Function(String?) formatTime;
  final String Function(String?) getStatusDisplay;

  const _ScheduleJobCard({
    required this.job,
    required this.controller,
    required this.formatTime,
    required this.getStatusDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInProgress = job.status?.toLowerCase() == 'in-progress';
    // Prefer jobDate.from/to range; fall back to scheduledDate / serviceDate
    final String from = job.jobDate?.from ?? '';
    final String to   = job.jobDate?.to   ?? '';
    final String time = () {
      if (from.isNotEmpty && to.isNotEmpty) {
        return '${formatTime(from)} – ${formatTime(to)}';
      }
      if (from.isNotEmpty) return formatTime(from);
      return formatTime(job.scheduledDate ?? job.serviceDate);
    }();

    // Date label — "Sep 10, 2026" or "Sep 10 – Sep 12, 2026" if multi-day
    final String dateLabel = () {
      final rawFrom = from.isNotEmpty
          ? from
          : (job.scheduledDate ?? job.serviceDate ?? '');
      if (rawFrom.isEmpty) return '';
      try {
        const months = [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec',
        ];
        final dtFrom = DateTime.parse(rawFrom).toLocal();
        final fromStr = '${months[dtFrom.month - 1]} ${dtFrom.day}';

        if (to.isNotEmpty) {
          final dtTo = DateTime.parse(to).toLocal();
          // Same day → show once, e.g. "Sep 10, 2026"
          if (dtFrom.year == dtTo.year &&
              dtFrom.month == dtTo.month &&
              dtFrom.day == dtTo.day) {
            return '$fromStr, ${dtFrom.year}';
          }
          // Different days → show range, e.g. "Sep 10 – Sep 12, 2026"
          final toStr = '${months[dtTo.month - 1]} ${dtTo.day}';
          return '$fromStr – $toStr, ${dtTo.year}';
        }

        return '$fromStr, ${dtFrom.year}';
      } catch (_) {
        return '';
      }
    }();
    final String duration = job.estimatedTime != null
        ? '${job.estimatedTime} hrs'
        : '';
    final String status = getStatusDisplay(job.status);
    final String rawId = job.sId ?? '';
    final String jobId = job.sId ?? '';
    // final String location = job.location ?? job.distance ?? 'No location';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5B0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Time + status ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: AppColor.blackShade1,
                        fontSize: 22,
                      ),
                    ),
                    if (dateLabel.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColor.brownAccentPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateLabel,
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (duration.isNotEmpty)
                      Text(
                        duration,
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isInProgress ? const Color(0xFFF5EDD8) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isInProgress
                        ? AppColor.brownAccentPrimary
                        : AppColor.coolGrayText,
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: isInProgress
                        ? AppColor.brownAccentPrimary
                        : AppColor.coolGrayText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isInProgress)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: CircleAvatar(backgroundColor: Colors.green, radius: 5),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Pay type + service type chips ──────────────────────────────
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
          const SizedBox(height: 6),
          // ── Title ──────────────────────────────────────────────────────
          Text(
            job.title?.capitalizeFirst.toString() ?? 'Untitled Job',
            style: AppTextStyle.titleMediumSemiBold.copyWith(
              color: AppColor.blackShade1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          // ── Job ID + location ──────────────────────────────────────────
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'JOB ID: ',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: jobId.toString() ?? '',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.grey1Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          InfoRow(
            icon: Icons.location_on_outlined,
            text: '${job.location ?? 'No location'}',
          ),
          const SizedBox(height: 6),
          // ── Schedule time ──────────────────────────────────────────────
          InfoRow(
            icon: Icons.access_time_outlined,
            text: controller.jobController.scheduleTimeLabel(job),
          ),
          const SizedBox(height: 4),
          // ── Pay detail ─────────────────────────────────────────────────
          InfoRow(
            icon: Icons.credit_card_outlined,
            text: controller.jobController.estPayLabel(job),
            bold: true,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.onNavigateJobTapped(job),
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text('NAVIGATE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.blackShade1,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTextStyle.labelSmallMedium.copyWith(
                      letterSpacing: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.onContactSupportJobTapped(job),
                  icon: const Icon(Icons.headset_mic_outlined, size: 16),
                  label: const Text('CONTACT SUPPORT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.blackShade1,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTextStyle.labelSmallMedium.copyWith(
                      letterSpacing: 0.5,
                      fontSize: 9,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── View Details button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.onViewDetailsJobTapped(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.brownAccentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: Text(
                'Click to view Details',
                style: AppTextStyle.buttonMedium.copyWith(
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
