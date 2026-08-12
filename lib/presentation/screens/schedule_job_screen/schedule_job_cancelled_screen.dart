import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobCancelledScreen extends GetView<ScheduleJobController> {
  const ScheduleJobCancelledScreen({super.key});

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
        title: const Text('Canceling Job',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [
          IconButton(
              icon: const Icon(Icons.support_agent_outlined, color: Colors.black87),
              onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            const _GreenBadgeCheck(),
            const SizedBox(height: 28),
            const Text('Job is Canceled',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Job ID: #1024',
                  style: TextStyle(
                      color: Color(0xFFA5732F),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
            ),
            const Spacer(),
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

/// Green starburst / badge shape with a white check icon
class _GreenBadgeCheck extends StatelessWidget {
  const _GreenBadgeCheck();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _StarBadgePainter(color: const Color(0xFF34C759), sides: 10),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 42),
        ),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  final Color color;
  final int sides;
  const _StarBadgePainter({required this.color, this.sides = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
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
