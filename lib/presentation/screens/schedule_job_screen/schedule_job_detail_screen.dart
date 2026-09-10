import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/map_launch_helper.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobDetailScreen extends GetView<ScheduleJobController> {
  ScheduleJobDetailScreen({super.key});

  var controller = Get.put(ScheduleJobController());

  @override
  Widget build(BuildContext context) {
    final job = Get.arguments as ScheduledJobModel?;
    final isInProgress = job?.status == JobStatus.inProgress;

    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        actions: [
          if (isInProgress)
            GestureDetector(
              onTap: controller.pauseJob,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pause, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Job\nPause',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: isInProgress
          ? _JobInProgressBody(controller: controller)
          : _JobDetailsBody(job: job),
    );
  }
}

// ── Job Details (pre-start / upcoming) ───────────────────────────────────────

String _calcDistance(double? jobLat, double? jobLng) {
  if (jobLat == null || jobLng == null) return 'N/A';
  try {
    final loc = LocationService.to;
    if (loc.latitude.value == 0.0 && loc.longitude.value == 0.0) return 'N/A';
    final meters = Geolocator.distanceBetween(
      loc.latitude.value,
      loc.longitude.value,
      jobLat,
      jobLng,
    );
    final km = meters / 1000;
    return km >= 1
        ? '${km.toStringAsFixed(1)} km'
        : '${meters.toStringAsFixed(0)} m';
  } catch (_) {
    return 'N/A';
  }
}

class _JobDetailsBody extends StatelessWidget {
  final ScheduledJobModel? job;

  const _JobDetailsBody({this.job});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          _Card(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF0E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tv_outlined,
                    color: Color(0xFFA5732F),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TV Mounting',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 4),
                      _SmallBadge(text: 'Job ID: #1024'),
                      SizedBox(height: 4),
                      _SmallBadge(text: 'IN PROGRESS'),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFFA5732F),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats grid
          _Card(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.access_time_outlined,
                        value: '10:30 AM',
                        label: 'ETA',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.timer_outlined,
                        value: () {
                          // prefer estimatedTime, then derive from jobDate window
                          if (job?.rawJob?.estimatedTime?.isNotEmpty == true) {
                            return '${job!.rawJob!.estimatedTime} hrs';
                          }
                          final from = job?.rawJob?.jobDate?.from ?? '';
                          final to   = job?.rawJob?.jobDate?.to   ?? '';
                          if (from.isNotEmpty && to.isNotEmpty) {
                            try {
                              final diff = DateTime.parse(to)
                                  .difference(DateTime.parse(from))
                                  .inMinutes;
                              if (diff >= 60) {
                                final h = diff ~/ 60;
                                final m = diff % 60;
                                return m > 0 ? '${h}h ${m}m' : '${h}h';
                              }
                              if (diff > 0) return '${diff}m';
                            } catch (_) {}
                          }
                          if (job?.duration.isNotEmpty == true) {
                            return '${job!.duration} hrs';
                          }
                          return '';
                        }(),
                        label: 'Duration',
                        iconColor: const Color(0xFFA5732F),
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.grey.shade200),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.location_on_outlined,
                        value: _calcDistance(job?.lat, job?.lng),
                        label: 'Distance',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.currency_rupee,
                        value: () {
                          final pay = job?.rawJob?.pay;
                          if (pay == null) return '';
                          switch ((pay.type ?? '').toLowerCase()) {
                            case 'hourly':
                              final rate   = pay.hourlyRate ?? 0;
                              final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
                              final max    = pay.maxHours ?? 0;
                              final hours  = approx > 0 ? approx : max.toDouble();
                              if (hours > 0 && rate > 0) {
                                return 'Est. \$${(rate * hours).toStringAsFixed(0)}';
                              }
                              return rate > 0 ? '\$$rate/hr' : '';
                            case 'perdevice':
                            case 'per_device':
                            case 'per-device':
                              final rate    = pay.perDeviceRate ?? 0;
                              final devices = pay.maxDevices ?? 0;
                              if (devices > 0 && rate > 0) return 'Est. \$${rate * devices}';
                              return rate > 0 ? '\$$rate/device' : '';
                            case 'blended':
                              final fixed    = pay.blendedFixedAmount ?? 0;
                              final addlRate = pay.blendedHourlyRate ?? 0;
                              final maxAddl  = pay.blendedMaxAddlHours ?? 0;
                              if (addlRate > 0 && maxAddl > 0) {
                                return 'Est. \$${fixed + addlRate * maxAddl}';
                              }
                              return '\$$fixed';
                            case 'fixed':
                            default:
                              final amount = pay.fixedAmount ?? 0;
                              return amount > 0 ? '\$$amount' : '';
                          }
                        }(),
                        label: 'Est. Pay',
                        iconColor: const Color(0xFFA5732F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Destination
          _Card(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESTINATION',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          letterSpacing: 1,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'House No. 123, Sector 14',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Near City Mall, Sector 14',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (job?.lat != null && job?.lng != null) {
                      MapLaunchHelper.navigateTo(
                        lat: job!.lat!,
                        lng: job!.lng!,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA5732F)),
                    ),
                    child: const Text(
                      'Navigate',
                      style: TextStyle(
                        color: Color(0xFFA5732F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Arrival info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF0E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Arrival',
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontFamily: 'Inter'),
                          children: [
                            TextSpan(
                              text: '10:45 AM ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '(8 min)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFA5732F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 14,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Distance',
                            style: TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _calcDistance(job?.lat, job?.lng),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _BrownButton(label: '▶  Start Job', onTap: () {}),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GreyButton(label: '📞  Call Admin', onTap: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RedButton(label: '✕  Cancel Route', onTap: () {}),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Job In Progress Body ──────────────────────────────────────────────────────

class _JobInProgressBody extends StatelessWidget {
  final ScheduleJobController controller;

  const _JobInProgressBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header + timer card
                _Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF0E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tv_outlined,
                              color: Color(0xFFA5732F),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TV Mounting',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(height: 4),
                                _SmallBadge(text: 'Job ID: #1024'),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF0E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'IN PROGRESS',
                              style: TextStyle(
                                color: Color(0xFFA5732F),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: _TimerItem(
                                  icon: Icons.play_circle_outline,
                                  label: 'Started At',
                                  value: '10:55 AM',
                                ),
                              ),
                              Expanded(
                                child: _TimerItem(
                                  icon: Icons.access_time_outlined,
                                  label: 'Elapsed Time',
                                  value: controller.elapsedTime,
                                  valueColor: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _TimerItem(
                                  icon: Icons.timer_outlined,
                                  label: 'Est. Duration',
                                  value: '1.5 hrs',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Job Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Text(
                            '15%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.15,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFA5732F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Service location card (shown before reaching)
                Obx(
                  () => !controller.isStepCompleted(ChecklistStep.reachLocation)
                      ? _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF0E6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFFA5732F),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Service Location',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'House No. 123, Sector 14',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        Text(
                                          'Near City Mall, Sector 14, City',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _OutlineBtn(
                                      label: 'NAVIGATE',
                                      icon: Icons.send,
                                      onTap: () => controller.navigateJob(
                                        controller.jobs.firstWhereOrNull(
                                              (j) =>
                                                  j.status ==
                                                  JobStatus.inProgress,
                                            ) ??
                                            controller.jobs.first,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _OutlineBtn(
                                      label: 'REACHED',
                                      icon: Icons.group_outlined,
                                      onTap: () => controller.toggleStep(
                                        ChecklistStep.reachLocation,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                // Customer instructions
                _Card(
                  borderColor: const Color(0xFFA5732F),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA5732F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Instructions',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Please mount the TV on the living room wall. Cable management is required.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Checklist
                Obx(
                  () => _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Job Checklist',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              '${controller.completedCount} / 5 Completed',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _ChecklistItem(
                          step: ChecklistStep.reachLocation,
                          icon: Icons.location_on_outlined,
                          title: 'Reach at location',
                          subtitle: 'Mark when you reach the customer location',
                          controller: controller,
                        ),
                        // Confirm button
                        if (controller.isStepCompleted(
                              ChecklistStep.reachLocation,
                            ) &&
                            !controller.isStepCompleted(
                              ChecklistStep.confirmJob,
                            )) ...[
                          const SizedBox(height: 8),
                          _BrownButton(
                            label: 'Confirm with Customer',
                            onTap: controller.onActionTap,
                          ),
                        ] else if (controller.isStepCompleted(
                          ChecklistStep.confirmJob,
                        )) ...[
                          const SizedBox(height: 8),
                          _BrownButton(label: 'Confirmed', onTap: () {}),
                        ],
                        const SizedBox(height: 8),
                        _ChecklistItem(
                          step: ChecklistStep.confirmJob,
                          icon: Icons.person_outline,
                          title: 'Confirm job with customer',
                          subtitle: 'Verify details and scope of work',
                          controller: controller,
                        ),
                        const SizedBox(height: 8),
                        _ChecklistItem(
                          step: ChecklistStep.completeService,
                          icon: Icons.build_outlined,
                          title: 'Complete the service',
                          subtitle: 'Perform TV wall mounting and cable setup',
                          controller: controller,
                        ),
                        const SizedBox(height: 8),
                        _ChecklistItem(
                          step: ChecklistStep.testHandover,
                          icon: Icons.assignment_outlined,
                          title: 'Test and handover',
                          subtitle: 'Test the setup and handover to customer',
                          controller: controller,
                        ),
                        const SizedBox(height: 8),
                        _ChecklistItem(
                          step: ChecklistStep.collectPayment,
                          icon: Icons.currency_rupee,
                          title:
                              controller.isStepCompleted(
                                ChecklistStep.testHandover,
                              )
                              ? 'Collect Signature'
                              : 'Collect payment (if any)',
                          subtitle:
                              'Collect signature from the customer to confirm that service is successfully done and payment is completed.',
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Bottom action button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Obx(() {
            if (controller.allDone) {
              return Column(
                children: [
                  _BrownButton(
                    label: 'Confirmation Pending',
                    onTap: () {},
                    color: const Color(0xFFA5732F).withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Support team is confirming from customer. Kindly Wait\nfor 5 - 10 minute.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA5732F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              );
            }
            return _BrownButton(
              label: controller.currentActionLabel,
              onTap: controller.onActionTap,
            );
          }),
        ),
      ],
    );
  }
}

// ─── Shared small badge ───────────────────────────────────────────────────────

class _SmallBadge extends StatelessWidget {
  final String text;

  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFA5732F),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─── Timer Item ───────────────────────────────────────────────────────────────

class _TimerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _TimerItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

// ─── Checklist Item ───────────────────────────────────────────────────────────

class _ChecklistItem extends StatelessWidget {
  final ChecklistStep step;
  final IconData icon;
  final String title;
  final String subtitle;
  final ScheduleJobController controller;

  const _ChecklistItem({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final done = controller.isStepCompleted(step);
    final prevDone =
        step == ChecklistStep.reachLocation ||
        controller.isStepCompleted(ChecklistStep.values[step.index - 1]);
    final active = prevDone && !done;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: active ? () => controller.toggleStep(step) : null,
          child: done
              ? Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA5732F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                )
              : Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? Colors.black54 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: done ? const Color(0xFFFAF0E6) : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: done ? const Color(0xFFA5732F) : Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: done || active ? Colors.black : Colors.grey,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: done || active ? Colors.grey : Colors.grey.shade400,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _Card({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontFamily: 'Inter'),
        ),
      ],
    );
  }
}

class _BrownButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BrownButton({required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFA5732F),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

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

class _GreyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GreyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

class _RedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
