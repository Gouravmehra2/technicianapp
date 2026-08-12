import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobCompletedScreen extends GetView<ScheduleJobController> {
  const ScheduleJobCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
        title: const Text('Job Details',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Green badge
            const _GreenBadgeCheck(),
            const SizedBox(height: 24),
            const Text('Job Completed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(20)),
              child: const Text('Job ID: #1024',
                  style: TextStyle(
                      color: Color(0xFFA5732F),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
            ),
            const SizedBox(height: 24),
            // Earnings card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _EarningsRow(label: 'Total Earnings', value: '\$650', valueStyle:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFA5732F), fontFamily: 'Inter')),
                  Divider(color: Colors.grey.shade200, height: 24),
                  _EarningsRow(label: 'Service Type', value: 'TV Wall Mounting'),
                  Divider(color: Colors.grey.shade200, height: 24),
                  _EarningsRow(label: 'Duration', value: '1h 15m'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Tasks completed card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tasks Completed',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter')),
                  const SizedBox(height: 12),
                  _TaskItem(label: 'Verification Done'),
                  const SizedBox(height: 8),
                  _TaskItem(label: 'Installation Complete'),
                  const SizedBox(height: 8),
                  _TaskItem(label: 'Payment Collected'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Customer feedback card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5732F).withValues(alpha: 0.3))),
              child: Column(
                children: [
                  const Text('Customer Feedback',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Inter')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (_) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(Icons.star, color: Color(0xFFA5732F), size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('"Great service, very professional!"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                          fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: controller.goToNextJob,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFA5732F),
                    borderRadius: BorderRadius.circular(30)),
                child: const Text('Go to Next Job',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: controller.goToNextJob,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300)),
                child: const Text('Back to Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _EarningsRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter', color: Colors.black87)),
        Text(value,
            style: valueStyle ??
                const TextStyle(
                    fontSize: 14, fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String label;
  const _TaskItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFFA5732F), size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontFamily: 'Inter', color: Colors.black87)),
      ],
    );
  }
}

/// Reusable green starburst badge with check
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
    final paint = Paint()..color = color..style = PaintingStyle.fill;
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
