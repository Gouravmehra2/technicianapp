import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/map_launch_helper.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

class ScheduleJobScreen extends GetView<ScheduleJobController> {
  ScheduleJobScreen({super.key});

  var controller = Get.put(ScheduleJobController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Schedules',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text('Working Hours: 8.5 hrs',
                //     style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter')),
                // const SizedBox(height: 6),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(4),
                //   child: LinearProgressIndicator(
                //     value: 2 / 6,
                //     minHeight: 8,
                //     backgroundColor: Colors.grey.shade200,
                //     valueColor: const AlwaysStoppedAnimation(Color(0xFFA5732F)),
                //   ),
                // ),
                // const SizedBox(height: 6),
                // Center(
                //   child: Text('2 / 6 Jobs Completed',
                //       style: AppTextStyle.titleSmallSemiBold
                //           .copyWith(color: AppColor.brownAccentPrimary, fontSize: 15)),
                // ),
                // const SizedBox(height: 14),
                _TabSelector(controller: controller),
              ],
            ),
          ),
          // ── Week date-range panel ──────────────────────────────────────
          Obx(() {
            if (controller.selectedTab.value != 2)
              return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: _WeekDateRangePanel(controller: controller),
            );
          }),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFA5732F)),
                );
              }
              if (controller.jobs.isEmpty) {
                return const Center(
                  child: Text(
                    'No jobs scheduled',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: controller.jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) =>
                    _JobCard(job: controller.jobs[i], controller: controller),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Selector ────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  final ScheduleJobController controller;

  const _TabSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    const tabs = ['Today', 'Tomorrow', 'Week'];
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF0E6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = controller.selectedTab.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = i,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.brownAccentPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Job Card ────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final ScheduledJobModel job;
  final ScheduleJobController controller;

  const _JobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isCompleted = job.status == JobStatus.completed;
    final isInProgress = job.status == JobStatus.inProgress;
    final isOnTheWay = job.status == JobStatus.onTheWay;

    // ── Colour tokens ──────────────────────────────────────────────────────
    const brown = Color(0xFFA5732F);
    final cardBg = isCompleted
        ? const Color(0xFF1A1A1A)
        : isOnTheWay
        ? const Color(0xFFEEF5FF)
        : isInProgress
        ? const Color(0xFFFFF8EE)
        : Colors.white;
    final borderColor = isCompleted
        ? const Color(0xFF333333)
        : isOnTheWay
        ? const Color(0xFF1565C0).withValues(alpha: 0.4)
        : isInProgress
        ? brown.withValues(alpha: 0.5)
        : const Color(0xFFE8D5B0);
    final primaryText = isCompleted ? Colors.white : Colors.black;
    final secondaryText = isCompleted
        ? Colors.white60
        : const Color(0xFF666666);
    final iconColor = isCompleted
        ? Colors.white54
        : isOnTheWay
        ? const Color(0xFF1565C0)
        : brown;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip: time block + status badge ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white.withValues(alpha: 0.06)
                  : isOnTheWay
                  ? const Color(0xFF1565C0).withValues(alpha: 0.08)
                  : isInProgress
                  ? brown.withValues(alpha: 0.08)
                  : const Color(0xFFFFF8EE),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Time icon accent
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white.withValues(alpha: 0.1)
                        : brown.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: isCompleted ? Colors.white60 : brown,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.time,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: primaryText,
                          height: 1.1,
                        ),
                      ),
                      if (job.duration.isNotEmpty)
                        Text(
                          job.duration,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: job.status),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Job title ────────────────────────────────────────────
                Text(
                  job.title.capitalizeFirst ?? job.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: primaryText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Job ID row ───────────────────────────────────────────
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      color: secondaryText,
                    ),
                    children: [
                      TextSpan(
                        text: 'JOB ID  ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.white70 : Colors.black87,
                          letterSpacing: 0.4,
                        ),
                      ),
                      TextSpan(
                        text: job.jobId,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: secondaryText,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // ── Location row ─────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        job.distance.isNotEmpty ? job.distance : 'No location',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── rawJob details (service type, pay, schedule) ─────────
                if (job.rawJob != null) ...[
                  const SizedBox(height: 12),
                  const _Divider(),
                  const SizedBox(height: 12),

                  // Service type + pay type chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if ((job.rawJob!.serviceType?.name ?? '').isNotEmpty)
                        _ScheduleMetaChip(
                          label: job.rawJob!.serviceType!.name!,
                          bgColor: isCompleted
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFFFF3E0),
                          textColor: isCompleted ? Colors.white70 : brown,
                          icon: Icons.miscellaneous_services_outlined,
                        ),
                      _ScheduleMetaChip(
                        label: _payTypeLabel(job.rawJob!.pay?.type),
                        bgColor: isCompleted
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE8F5E9),
                        textColor: isCompleted
                            ? Colors.white70
                            : const Color(0xFF2E7D32),
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Schedule time
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    iconColor: iconColor,
                    label: 'Schedule',
                    value: _scheduleLabel(job.rawJob!),
                    valueColor: secondaryText,
                    isCompleted: isCompleted,
                  ),
                  const SizedBox(height: 6),

                  // Pay detail
                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: iconColor,
                    label: 'Budget',
                    value: _payDetailLabel(job.rawJob!),
                    valueColor: primaryText,
                    bold: true,
                    isCompleted: isCompleted,
                  ),
                ],

                // ── Action buttons ────────────────────────────────────────
                // inprogress → skip navigate button (go to detail)
                // on_the_way → navigate resumes live navigation
                // others     → navigate opens route preview
                if (!isCompleted && !isInProgress) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineBtn(
                          label: 'NAVIGATE',
                          icon: Icons.near_me_outlined,
                          onTap: () => Get.toNamed(
                            AppRoutes.scheduleJobNavigationScreen,
                            arguments: job,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OutlineBtn(
                          label: 'SUPPORT',
                          icon: Icons.headset_mic_outlined,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // ── Primary CTA ───────────────────────────────────────────
                // inprogress → View Details (checklist screen)
                // on_the_way → Resume Navigation (live map)
                // upcoming   → View Details
                // completed  → View Details
                GestureDetector(
                  onTap: () {
                    if (job.status == JobStatus.onTheWay) {
                      Get.toNamed(
                        AppRoutes.scheduleJobNavigationScreen,
                        arguments: job,
                      );
                    } else if (job.status == JobStatus.inProgress) {
                      Get.toNamed(
                        AppRoutes.scheduleJobDetailScreen,
                        arguments: job,
                      );
                    } else {
                      controller.navigateToJobDetails(job);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.white.withValues(alpha: 0.12)
                          : job.status == JobStatus.onTheWay
                          ? const Color(0xFF1565C0)
                          : brown,
                      borderRadius: BorderRadius.circular(30),
                      border: isCompleted
                          ? Border.all(color: Colors.white24)
                          : null,
                    ),
                    child: Text(
                      job.status == JobStatus.onTheWay
                          ? '▶  Resume Navigation'
                          : job.status == JobStatus.inProgress
                          ? 'View Job Progress'
                          : 'View Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isCompleted ? Colors.white70 : Colors.white,
                        letterSpacing: 0.3,
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

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;
  final bool isCompleted;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isCompleted ? Colors.white38 : const Color(0xFF999999);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 6),
        Text(
          '$label  ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.2,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Thin divider ─────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFEEE8DE));
  }
}

// ─── Schedule card helpers ────────────────────────────────────────────────────

String _payTypeLabel(String? type) {
  switch ((type ?? '').toLowerCase()) {
    case 'hourly':
      return 'Hourly';
    case 'blended':
      return 'Blended';
    case 'perdevice':
    case 'per_device':
    case 'per-device':
      return 'Per Device';
    case 'fixed':
      return 'Fixed';
    default:
      return type?.isNotEmpty == true ? type! : 'Fixed';
  }
}

String _payDetailLabel(Jobs job) {
  final pay = job.pay;
  if (pay == null) return '\$${job.budget ?? job.finalPrice ?? 0}';
  switch ((pay.type ?? '').toLowerCase()) {
    case 'hourly':
      final rate = pay.hourlyRate ?? 0;
      final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
      final max = pay.maxHours ?? 0;
      final hours = approx > 0 ? approx : max.toDouble();
      if (hours > 0 && rate > 0) {
        final total = (rate * hours).toStringAsFixed(0);
        return 'Est. \$$total  (\$$rate/hr × ${hours.toStringAsFixed(hours == hours.truncateToDouble() ? 0 : 1)}h)';
      }
      if (max > 0) return '\$$rate/hr • Max ${max}h';
      if ((pay.approxHours ?? '').isNotEmpty) return '\$$rate/hr • ~${pay.approxHours}h';
      return '\$$rate/hr';
    case 'perdevice':
    case 'per_device':
    case 'per-device':
      final rate = pay.perDeviceRate ?? 0;
      final max = pay.maxDevices ?? 0;
      if (max > 0 && rate > 0) return 'Est. \$${rate * max}  (\$$rate × $max devices)';
      return max > 0 ? '\$$rate/device • Max $max devices' : '\$$rate/device';
    case 'blended':
      final fixed = pay.blendedFixedAmount ?? 0;
      final fixedHrs = pay.blendedFixedHours ?? 0;
      final addlRate = pay.blendedHourlyRate ?? 0;
      final maxAddl = pay.blendedMaxAddlHours ?? 0;
      if (addlRate > 0 && maxAddl > 0) {
        return 'Est. \$${fixed + addlRate * maxAddl}  (\$$fixed + \$$addlRate/hr × ${maxAddl}h)';
      }
      final sb = StringBuffer('\$$fixed for ${fixedHrs}h');
      if (addlRate > 0) sb.write(' + \$$addlRate/hr');
      return sb.toString();
    case 'fixed':
    default:
      final amount = pay.fixedAmount ?? 0;
      return amount > 0
          ? '\$$amount fixed'
          : '\$${job.budget ?? job.finalPrice ?? 0}';
  }
}

String _scheduleLabel(Jobs job) {
  // 1️⃣ jobDate.from / to (primary source from API)
  final from = job.jobDate?.from ?? '';
  final to = job.jobDate?.to ?? '';
  if (from.isNotEmpty && to.isNotEmpty) {
    return '${_fmtIso(from)} – ${_fmtTimeOnly(to)}';
  }
  if (from.isNotEmpty) return _fmtIso(from);

  // 2️⃣ legacy schedule object
  final s = job.schedule;
  if (s == null) return _fallbackDate(job);
  switch ((s.type ?? '').toLowerCase()) {
    case 'hardstart':
    case 'hard_start':
    case 'hard-start':
      final t = s.hardStartTime ?? '';
      return t.isNotEmpty ? 'Start: ${_fmtT(t)}' : _fallbackDate(job);
    case 'betweenhours':
    case 'between_hours':
    case 'between-hours':
      final f = s.betweenTimeFrom ?? '';
      final t = s.betweenTimeTo ?? '';
      final datePart = _fmtDateRange(s.betweenDateFrom, s.betweenDateTo);
      if (f.isNotEmpty && t.isNotEmpty)
        return '$datePart • ${_fmtT(f)} – ${_fmtT(t)}';
      return datePart.isNotEmpty ? datePart : _fallbackDate(job);
    case 'arriveby':
    case 'arrive_by':
    case 'arrive-by':
      final t = s.arriveBeforeTime ?? '';
      return t.isNotEmpty ? 'Arrive by: ${_fmtT(t)}' : _fallbackDate(job);
    case 'arriveafter':
    case 'arrive_after':
    case 'arrive-after':
      final t = s.arriveAfterTime ?? '';
      return t.isNotEmpty ? 'Arrive after: ${_fmtT(t)}' : _fallbackDate(job);
    default:
      return _fallbackDate(job);
  }
}

String _fallbackDate(Jobs job) {
  // prefer jobDate.from / to
  final from = job.jobDate?.from ?? '';
  final to   = job.jobDate?.to   ?? '';
  if (from.isNotEmpty && to.isNotEmpty) {
    return '${_fmtIso(from)} – ${_fmtTimeOnly(to)}';
  }
  if (from.isNotEmpty) return _fmtIso(from);

  // scalar fallbacks
  final raw = job.scheduledDate ?? job.serviceDate ?? job.jobStartedAt;
  if (raw == null) return '';
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}  $h:$m $p';
  } catch (_) {
    return raw.toString();
  }
}

/// Formats an ISO datetime string → "MMM d, h:mm AM/PM" (e.g. "Sep 10, 1:53 PM").
String _fmtIso(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $h:$m $p';
  } catch (_) {
    return iso;
  }
}

/// Formats an ISO datetime string to time only → "h:mm AM/PM".
String _fmtTimeOnly(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  } catch (_) {
    return iso;
  }
}

String _fmtT(String hhmm) {
  try {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts.length > 1 ? parts[1] : '0');
    final p = h >= 12 ? 'PM' : 'AM';
    return '${h % 12 == 0 ? 12 : h % 12}:${m.toString().padLeft(2, '0')} $p';
  } catch (_) {
    return hhmm;
  }
}

String _fmtDateRange(String? from, String? to) {
  if (from == null && to == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String fmtIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return iso;
    }
  }

  if (from != null && to != null) return '${fmtIso(from)} – ${fmtIso(to)}';
  return from != null ? fmtIso(from) : fmtIso(to!);
}

// ─── Schedule Meta Chip ───────────────────────────────────────────────────────

class _ScheduleMetaChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  const _ScheduleMetaChip({
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
        borderRadius: BorderRadius.circular(20),
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

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final JobStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color textColor;

    switch (status) {
      case JobStatus.inProgress:
        label = 'IN PROGRESS';
        bg = const Color(0xFFFAF0E6);
        textColor = const Color(0xFFA5732F);
        break;
      case JobStatus.onTheWay:
        label = 'ON THE WAY';
        bg = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case JobStatus.upcoming:
        label = 'UPCOMING';
        bg = Colors.white;
        textColor = Colors.black87;
        break;
      case JobStatus.completed:
        label = 'COMPLETED';
        bg = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFA5732F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'Inter',
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Week Date Range Panel ───────────────────────────────────────────────────

class _WeekDateRangePanel extends StatelessWidget {
  final ScheduleJobController controller;

  const _WeekDateRangePanel({required this.controller});

  String _fmt(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isDateRangeExpanded.value;
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8D8C4), width: 1),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            GestureDetector(
              onTap: () => controller.isDateRangeExpanded.value = !expanded,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8D8C4)),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Color(0xFFA5732F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date Range',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'View jobs for a specific period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA5732F),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reset button
                    GestureDetector(
                      onTap: controller.resetDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8EE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8D8C4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: Color(0xFFA5732F),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFA5732F),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),

            // ── Body (collapsible) ───────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date pickers row ─────────────────────────────────
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => controller.pickStartDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFDDD0C0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 15,
                                        color: Color(0xFFA5732F),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _fmt(controller.weekStartDate.value),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: Colors.black87,
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

                        // Dash separator
                        const Padding(
                          padding: EdgeInsets.only(top: 20, left: 8, right: 8),
                          child: Text(
                            '—',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // End Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => controller.pickEndDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFDDD0C0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 15,
                                        color: Color(0xFFA5732F),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _fmt(controller.weekEndDate.value),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                            color: Colors.black87,
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
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Apply Date Range button ───────────────────────────
                    GestureDetector(
                      onTap: controller.applyDateRange,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA5732F),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 17,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Apply Date Range',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Divider with "or" ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Custom Date button ───────────────────────────────
                    GestureDetector(
                      onTap: () => controller.pickCustomDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFA5732F),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 17,
                              color: Color(0xFFA5732F),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Custom Date',
                              style: TextStyle(
                                color: Color(0xFFA5732F),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}
