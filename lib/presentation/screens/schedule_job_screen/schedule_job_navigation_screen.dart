import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobNavigationScreen extends GetView<ScheduleJobController> {
  const ScheduleJobNavigationScreen({super.key});

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
        title: const Text('Navigation',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: controller.pauseJob,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary, borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.pause, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Job\nPause',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter')),
              ]),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Turn instruction banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)
                    ]),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFAF0E6),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.turn_right_outlined,
                        color: Color(0xFFA5732F), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('IN 200M',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFA5732F),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    Text('Turn right onto Sector 14',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  ]),
                ]),
              ),
            ),
            // Map placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5732F).withValues(alpha: 0.4)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(children: [
                    // Map grid + route
                    CustomPaint(
                      size: const Size(double.infinity, 280),
                      painter: _MapPainter(),
                    ),
                    // Live traffic badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Live Traffic',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Inter')),
                          Text('Light', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ]),
                      ),
                    ),
                    // Re-center button
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [
                          Icon(Icons.send_outlined, size: 14, color: Color(0xFFA5732F)),
                          SizedBox(width: 4),
                          Text('Re-center',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ]),
                      ),
                    ),
                    // Zoom controls
                    Positioned(
                      right: 12,
                      bottom: 40,
                      child: Column(children: [
                        _MapBtn(icon: Icons.my_location),
                        const SizedBox(height: 4),
                        _MapBtn(icon: Icons.add),
                        const SizedBox(height: 4),
                        _MapBtn(icon: Icons.remove),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
            // Drag handle
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            // Job info sheet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                // Job header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [
                    Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFAF0E6),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.tv_outlined, color: Color(0xFFA5732F), size: 24)),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('TV Mounting',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                      SizedBox(height: 4),
                      _NavBadge(text: 'Job ID: #1024'),
                      SizedBox(height: 4),
                      _NavBadge(text: 'IN PROGRESS'),
                    ])),
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)),
                        child: const Icon(Icons.phone_outlined,
                            color: Color(0xFFA5732F), size: 18)),
                  ]),
                ),
                const SizedBox(height: 10),
                // Stats grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: _NavStatItem(
                              icon: Icons.access_time_outlined,
                              value: '10:30 AM',
                              label: 'ETA')),
                      Container(width: 1, height: 50, color: Colors.grey.shade200),
                      Expanded(
                          child: _NavStatItem(
                              icon: Icons.timer_outlined,
                              value: '1.5 hrs',
                              label: 'Duration',
                              iconColor: const Color(0xFFA5732F))),
                    ]),
                    Divider(color: Colors.grey.shade200),
                    Row(children: [
                      Expanded(
                          child: _NavStatItem(
                              icon: Icons.location_on_outlined,
                              value: '1.8 km',
                              label: 'Distance')),
                      Container(width: 1, height: 50, color: Colors.grey.shade200),
                      Expanded(
                          child: _NavStatItem(
                              icon: Icons.currency_rupee,
                              value: '\$650',
                              label: 'Est. Amount',
                              iconColor: const Color(0xFFA5732F))),
                    ]),
                  ]),
                ),
                const SizedBox(height: 10),
                // Destination
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [
                    const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('DESTINATION',
                          style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1)),
                      Text('House No. 123, Sector 14',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                      Text('Near City Mall, Sector 14',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA5732F))),
                      child: const Text('View Details',
                          style: TextStyle(color: Color(0xFFA5732F), fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                // Arrival + distance row
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.access_time_outlined, size: 14, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('Arrival', style: TextStyle(color: Colors.black54))
                      ]),
                      RichText(
                          text: const TextSpan(style: TextStyle(fontFamily: 'Inter'), children: [
                        TextSpan(
                            text: '10:45 AM ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                        TextSpan(
                            text: '(8 min)',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA5732F),
                                fontWeight: FontWeight.w600)),
                      ])),
                    ])),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.route_outlined, size: 14, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('Distance', style: TextStyle(color: Colors.black54))
                      ]),
                      const Text('4.2 km left',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                    ])),
                  ]),
                ),
                const SizedBox(height: 14),
                _BrownButton(label: '👤  Reached', onTap: () {}),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _GreyButton(label: '📞  Call Support', onTap: () {})),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _RedButton(label: '✕  Cancel Route', onTap: controller.cancelJob)),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final IconData icon;
  const _MapBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18));
  }
}

class _NavBadge extends StatelessWidget {
  final String text;
  const _NavBadge({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFFA5732F),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              fontFamily: 'Inter')),
    );
  }
}

class _NavStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  const _NavStatItem(
      {required this.icon, required this.value, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 16, color: iconColor ?? Colors.grey),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }
}

// ─── Map Painter ──────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFE8D5B7).withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Route
    final routePaint = Paint()
      ..color = const Color(0xFFA5732F)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.55, 20)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.3, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * 0.9);
    canvas.drawPath(path, routePaint);

    // Start dot
    canvas.drawCircle(Offset(size.width * 0.55, 20), 8,
        Paint()..color = const Color(0xFFA5732F));

    // End location circle (compass-style)
    const cx = 0.5;
    const cy = 0.9;
    final endX = size.width * cx;
    final endY = size.height * cy;
    canvas.drawCircle(
        Offset(endX, endY), 20, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(endX, endY),
        20,
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Arrow on end circle
    final arrowPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Draw a simple arrow pointing up-right
    final arrowPath = Path()
      ..moveTo(endX - 6, endY + 4)
      ..lineTo(endX + 6, endY - 4)
      ..moveTo(endX + 6, endY - 4)
      ..lineTo(endX + 2, endY - 4)
      ..moveTo(endX + 6, endY - 4)
      ..lineTo(endX + 6, endY);
    canvas.drawPath(arrowPath, arrowPaint);

    // Map labels
    _drawMapLabel(canvas, size, 'Green Park', 0.15, 0.45, Colors.green);
    _drawMapLabel(canvas, size, 'City Hospital', 0.68, 0.38, Colors.red);
    _drawMapLabel(canvas, size, 'SECTOR 15', 0.55, 0.1, Colors.grey.shade600);
    _drawMapLabel(canvas, size, 'SECTOR 14', 0.55, 0.45, Colors.grey.shade600);
    _drawMapLabel(canvas, size, 'SECTOR 12', 0.22, 0.78, Colors.grey.shade600);

    // Shopping centre
    _drawMapMarker(canvas, size, 0.75, 0.72, Colors.blue, 'Shopping\nCentre');
  }

  void _drawMapLabel(Canvas canvas, Size size, String text, double rx, double ry, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * rx, size.height * ry));
  }

  void _drawMapMarker(
      Canvas canvas, Size size, double rx, double ry, Color color, String label) {
    final cx = size.width * rx;
    final cy = size.height * ry;
    canvas.drawCircle(Offset(cx, cy), 14, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawCircle(
        Offset(cx, cy),
        14,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    _drawMapLabel(canvas, size, label, rx - 0.04, ry + 0.06, color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Buttons ──────────────────────────────────────────────────────────────────

class _BrownButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BrownButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration:
            BoxDecoration(color: const Color(0xFFA5732F), borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
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
            color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
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
            color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
      ),
    );
  }
}

// ─── Star Badge (used by map screen too) ─────────────────────────────────────

class StarBadgePainter extends CustomPainter {
  final Color color;
  final int sides;
  const StarBadgePainter({required this.color, this.sides = 10});

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
  bool shouldRepaint(covariant StarBadgePainter old) => old.color != color;
}
