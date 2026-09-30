import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

class ScheduleJobCompletedScreen extends StatelessWidget {
  const ScheduleJobCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments passed from JobDetailController.completeJob()
    final args = Get.arguments as Map<String, dynamic>?;
    final ScheduledJobModel? jobModel =
        args?['job'] as ScheduledJobModel?;
    final Jobs? rawJob = args?['fetchedJob'] as Jobs?;

    final title =
        jobModel?.title.capitalizeFirst ?? rawJob?.title?.capitalizeFirst ?? 'Job';
    final jobId = jobModel?.jobId ?? rawJob?.sId ?? '--';
    final serviceType = rawJob?.serviceType?.name ??
        rawJob?.workType?.name ??
        'Service';
    final estPay = _payLabel(rawJob?.pay);
    final tasksDone = rawJob?.tasks?.where((t) => t.isDone == true).toList() ??
        <Tasks>[];

    return MyScaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24),
            // ── Success badge ───────────────────────────────────────────
            const _GreenBadgeCheck(),
            const SizedBox(height: 24),
            const Text(
              'Job Completed\nSuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Great work! You have successfully completed\nthis job. Keep up the excellent service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Job ID chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Job ID: $jobId',
                style: const TextStyle(
                  color: Color(0xFFA5732F),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Summary card ──────────────────────────────────────────
            _SummaryCard(
              title: title,
              serviceType: serviceType,
              estPay: estPay,
              tasksCount: rawJob?.tasks?.length ?? 0,
              tasksDoneCount: tasksDone.length,
            ),
            const SizedBox(height: 14),

            // ── Tasks completed list ──────────────────────────────────
            if (tasksDone.isNotEmpty) ...[
              _TasksCompletedCard(tasks: tasksDone),
              const SizedBox(height: 14),
            ],

            // ── What happens next banner ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A73E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Our support team will confirm the completion with the customer. Payment will be processed to your account within 24–48 hours.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Inter',
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Back to Home button ───────────────────────────────────
            GestureDetector(
              onTap: _goHome,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5732F),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '🏠  Back to Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _viewAllJobs,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'View All Jobs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _goHome() {
    // Pop back to dashboard / home — clear the navigation stack
    Get.until((r) => r.settings.name == AppRoutes.dashboardScreen);
  }

  void _viewAllJobs() {
    Get.until((r) => r.settings.name == AppRoutes.dashboardScreen);
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final String serviceType;
  final String estPay;
  final int tasksCount;
  final int tasksDoneCount;

  const _SummaryCard({
    required this.title,
    required this.serviceType,
    required this.estPay,
    required this.tasksCount,
    required this.tasksDoneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _Row(label: 'Job Title', value: title),
          _divider(),
          _Row(label: 'Service Type', value: serviceType),
          if (estPay.isNotEmpty) ...[
            _divider(),
            _Row(
              label: 'Estimated Pay',
              value: estPay,
              valueStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA5732F),
                fontFamily: 'Inter',
              ),
            ),
          ],
          _divider(),
          _Row(
            label: 'Tasks Completed',
            value: '$tasksDoneCount / $tasksCount',
            valueStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey.shade200, height: 20);
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _Row({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ??
                const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
          ),
        ),
      ],
    );
  }
}

// ── Tasks completed list card ─────────────────────────────────────────────────

class _TasksCompletedCard extends StatelessWidget {
  final List<Tasks> tasks;
  const _TasksCompletedCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completed Tasks',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.title ?? 'Task',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if ((t.group ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF0E6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          t.group!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFA5732F),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _payLabel(Pay? pay) {
  if (pay == null) return '';
  switch ((pay.type ?? '').toLowerCase()) {
    case 'hourly':
      final rate = pay.hourlyRate ?? 0;
      final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
      final max = pay.maxHours ?? 0;
      final hours = approx > 0 ? approx : max.toDouble();
      return hours > 0 && rate > 0
          ? 'Est. \$${(rate * hours).toStringAsFixed(0)}'
          : rate > 0
          ? '\$$rate/hr'
          : '';
    case 'perdevice':
    case 'per_device':
    case 'per-device':
      final rate = pay.perDeviceRate ?? 0;
      final devices = pay.maxDevices ?? 0;
      return devices > 0 && rate > 0
          ? 'Est. \$${rate * devices}'
          : rate > 0
          ? '\$$rate/device'
          : '';
    case 'blended':
      final fixed = pay.blendedFixedAmount ?? 0;
      final addl = pay.blendedHourlyRate ?? 0;
      final maxH = pay.blendedMaxAddlHours ?? 0;
      return addl > 0 && maxH > 0
          ? 'Est. \$${fixed + addl * maxH}'
          : '\$$fixed';
    default:
      final amt = pay.fixedAmount ?? 0;
      return amt > 0 ? '\$$amt fixed' : '';
  }
}

// ── Green starburst badge ─────────────────────────────────────────────────────

class _GreenBadgeCheck extends StatelessWidget {
  const _GreenBadgeCheck();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _StarBadgePainter(color: const Color(0xFF34C759)),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 42),
        ),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  final Color color;
  const _StarBadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const sides = 10;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.82;
    final path = Path();
    for (int i = 0; i < sides * 2; i++) {
      final angle = (i * math.pi / sides) - (math.pi / 2);
      final r = i.isEven ? outerR : innerR;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarBadgePainter old) => old.color != color;
}
