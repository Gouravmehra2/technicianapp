import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/booking_status_screen/booking_status_controller.dart';

class BookingStatusScreen extends GetView<BookingStatusController> {
  const BookingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Booking Status', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.headset_mic_outlined, color: Colors.white), onPressed: () => Get.toNamed(AppRoutes.supportScreen)),
        ],
      ),
      body: Obx(() {
        final step = controller.currentStep.value;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ServiceCard(controller: controller),
                    const SizedBox(height: 20),
                    _StatusTimeline(controller: controller),
                    const SizedBox(height: 16),
                    _BottomInfoCard(controller: controller),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: step == BookingStep.completed
                  ? CommonButton(
                      label: 'Completed',
                      onTap: () => Get.toNamed(AppRoutes.serviceReviewScreen, arguments: controller.service),
                      backgroundColor: AppColor.brownAccentPrimary,
                      foregroundColor: Colors.white,
                    )
                  : CommonButton(
                      label: 'Back to Home',
                      onTap: () => Get.until((r) => r.settings.name == AppRoutes.dashboardScreen),
                      backgroundColor: AppColor.brownAccentPrimary,
                      foregroundColor: Colors.white,
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final BookingStatusController controller;
  const _ServiceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            controller.service.image,
            width: 80,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 70,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(controller.service.name, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star, size: 12, color: Color(0xffFFC107)),
              const SizedBox(width: 2),
              Text('${controller.service.rating} (${controller.service.reviews} Reviews)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text('\$10 ', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText, decoration: TextDecoration.lineThrough)),
              Text('\$7', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final BookingStatusController controller;
  const _StatusTimeline({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;

      // Step 1: Booking Confirmed — always done
      // Step 2: Finding Technician (current) / Technician Assigned (done)
      // Step 3: Technician on the way (pending/current) / Technician Arrived (done)
      // Step 4: Service not yet started (pending) / Service in progress (current) / Completed (done)

      final step2Done = step.index >= BookingStep.technicinaAssigned.index;
      final step3Done = step.index >= BookingStep.technicianOnWay.index;
      final step4Done = step == BookingStep.completed;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.lightGreyColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Booking Confirmed
            _TimelineItem(
              isDone: true,
              title: 'Booking Confirmed',
              subtitle: '5 June, 2026, 16:16',
            ),
            _DashedLine(isDone: step2Done),

            // Step 2: Finding Technician / Technician Assigned
            _TimelineItem(
              isDone: step2Done,
              isCurrent: step == BookingStep.findingTechnician,
              title: step2Done ? 'Technician Assigned' : 'Technician Assigned',
              subtitle: step2Done ? 'Technician: Michael Johnson' : '',
              currentLabel: 'Finding Technician',
              currentSubtitle: 'We are finding the best technician for you',
            ),
            _DashedLine(isDone: step3Done),

            // Step 3: Technician on the way / Technician Arrived
            _TimelineItem(
              isDone: step3Done,
              isCurrent: step == BookingStep.technicinaAssigned,
              icon: Icons.handyman_outlined,
              title: step3Done ? 'Technician Arrived' : 'Technician on the way',
              subtitle: '',
              currentLabel: 'Technician Michael Johnson is on the way',
              showTrackButton: step == BookingStep.technicinaAssigned,
              onTrack: controller.trackNow,
              otpBadge: step3Done ? 'OTP: 1202' : null,
            ),
            _DashedLine(isDone: step4Done),

            // Step 4: Service not yet started / In progress / Completed
            _TimelineItem(
              isDone: step4Done,
              isCurrent: step == BookingStep.serviceInProgress,
              icon: Icons.handyman_outlined,
              title: step4Done ? 'Completed' : 'Service not yet started',
              subtitle: '',
              currentLabel: 'Service is in progress',
              currentSubtitle: 'We are hoping everything is going smooth.',
            ),
          ],
        ),
      );
    });
  }
}

class _DashedLine extends StatelessWidget {
  final bool isDone;
  const _DashedLine({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
      child: CustomPaint(
        size: const Size(2, 28),
        painter: _DashedLinePainter(color: isDone ? Colors.green : AppColor.lightGreyColor),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, math.min(startY + dashHeight, size.height)), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _TimelineItem extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? currentLabel;
  final String? currentSubtitle;
  final bool showTrackButton;
  final VoidCallback? onTrack;
  final String? otpBadge;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.isCurrent = false,
    this.icon = Icons.handyman_outlined,
    this.currentLabel,
    this.currentSubtitle,
    this.showTrackButton = false,
    this.onTrack,
    this.otpBadge,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = isCurrent && currentLabel != null;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: isHighlighted ? const EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: isHighlighted
          ? BoxDecoration(
              color: AppColor.brownAccentPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xffFFF8EC))
            )
          : null,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Icon/indicator
        if (isDone)
          const Icon(Icons.check_circle, color: Colors.green, size: 26)
        else if (isCurrent)
          _DashedCircle()
        else
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.lightGreyColor, width: 1.5),
            ),
            child: Icon(icon, size: 14, color: AppColor.coolGrayText),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isHighlighted ? currentLabel! : title,
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: isHighlighted
                        ? AppColor.brownAccentPrimary
                        : isDone
                            ? AppColor.blackShade1
                            : AppColor.coolGrayText,
                  ),
                ),
                if ((isHighlighted && currentSubtitle != null) || subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    isHighlighted && currentSubtitle != null ? currentSubtitle! : subtitle,
                    style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                  ),
                ],
              ]),
            ),
            if (showTrackButton)
              GestureDetector(
                onTap: onTrack,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Track Now', style: AppTextStyle.labelSmallMedium.copyWith(color: Colors.white)),
                ),
              ),
            if (otpBadge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.brownAccentPrimary),
                ),
                child: Text(otpBadge!, style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.brownAccentPrimary, fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _DashedCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _DashedCirclePainter()),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.brownAccentPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    const dashCount = 10;
    const gapRatio = 0.4;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 2.5) / 2;
    final totalAngle = 2 * math.pi;
    final dashAngle = totalAngle / dashCount * (1 - gapRatio);
    final gapAngle = totalAngle / dashCount * gapRatio;
    double start = -math.pi / 2;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        start,
        dashAngle,
        false,
        paint,
      );
      start += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter _) => false;
}

class _BottomInfoCard extends StatelessWidget {
  final BookingStatusController controller;
  const _BottomInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;

      String title;
      String value;
      String description;
      IconData illustrationIcon;

      if (step == BookingStep.completed) {
        title = 'We are Done!';
        value = 'Service\nCompleted!';
        description = 'Thank you for choosing us!\nRate our technicians!';
        illustrationIcon = Icons.engineering;
      } else if (step == BookingStep.serviceInProgress || step == BookingStep.technicianOnWay) {
        title = step == BookingStep.serviceInProgress ? 'Servicing...' : 'Technician on the way';
        value = 'OTP: 1202';
        description = 'Technician is arrived,\nShare the otp and get the service star.';
        illustrationIcon = Icons.engineering;
      } else {
        title = 'Estimated Time';
        value = '25 - 30 mins';
        description = 'We will notify you once\na technician is assigned';
        illustrationIcon = Icons.search;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xffFAF7F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color:Color(0xffA5732F).withValues(alpha: 0.30)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.coolGrayText)),
              Text(value, style: AppTextStyle.headlineSmallSemiBold.copyWith(color: AppColor.blackShade1)),
              const SizedBox(height: 4),
              Text(description, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
            ]),
          ),
          Icon(illustrationIcon, size: 80, color: AppColor.brownAccentPrimary),
        ]),
      );
    });
  }
}
