import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/live_tracking_screen/live_tracking_controller.dart';

class LiveTrackingScreen extends GetView<LiveTrackingController> {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Live Tracking', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.headset_mic_outlined, color: Colors.white), onPressed: () => Get.toNamed(AppRoutes.supportScreen)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Map placeholder
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xffE8E4DC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.lightGreyColor),
              ),
              child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: const Color(0xffE8E4DC),
                    child: const Center(child: Icon(Icons.map_outlined, size: 80, color: AppColor.coolGrayText)),
                  ),
                ),
                // Route line visual
                Center(child: CustomPaint(painter: _DashedLinePainter(), size: const Size(200, 100))),
                // OTP badge
                Positioned(
                  bottom: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
                    child: Text('OTP: 1202', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Technician card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColor.lightGreyColor)),
              child: Row(children: [
                CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 30, color: AppColor.coolGrayText)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Michael Johnson', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Color(0xffFFC107)),
                    const SizedBox(width: 2),
                    Text('4.3 (124 Reviews)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                  ]),
                  Text('On the way', style: AppTextStyle.bodySmallMedium.copyWith(color: Colors.green)),
                ])),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: CommonButton(
                label: 'Call Now',
                onTap: () {},
                backgroundColor: Colors.white,
                foregroundColor: AppColor.brownAccentPrimary,
                border: Border.all(color: AppColor.brownAccentPrimary),
                boxShadow: const [],
                leadingIcon: const Icon(Icons.call_outlined, color: AppColor.brownAccentPrimary, size: 18),
              )),
              const SizedBox(width: 12),
              Expanded(child: CommonButton(
                label: 'Chat Now',
                onTap: () => Get.toNamed(AppRoutes.chatSupportScreen),
                backgroundColor: Colors.white,
                foregroundColor: AppColor.brownAccentPrimary,
                border: Border.all(color: AppColor.brownAccentPrimary),
                boxShadow: const [],
                leadingIcon: const Icon(Icons.chat_bubble_outline, color: AppColor.brownAccentPrimary, size: 18),
              )),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColor.lightGreyColor)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Estimated Arrival', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                  Text('15 Minutes', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1)),
                ])),
                const Icon(Icons.access_time_rounded, color: AppColor.brownAccentPrimary, size: 28),
              ]),
            ),
            const SizedBox(height: 16),
            CommonButton(
              label: 'Check Status',
              onTap: controller.checkStatus,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.brownAccentPrimary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
