import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'coupon_controller.dart';

class CouponScreen extends GetView<CouponController> {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Coupons',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Search bar row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffDDDDDD)),
                  ),
                  child: TextField(
                    controller: controller.couponCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: AppTextStyle.bodyMediumRegular
                          .copyWith(color: AppColor.coolGrayText),
                      prefixIcon: const Icon(Icons.label_outline,
                          color: AppColor.coolGrayText, size: 20),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.brownAccentDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('Apply',
                      style: AppTextStyle.titleSmallSemiBold
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Available Coupons label
          Text(
            'Available Coupons',
            style: AppTextStyle.titleMediumSemiBold
                .copyWith(color: AppColor.blackShade1),
          ),

          const SizedBox(height: 12),

          // Coupon cards
          ...List.generate(controller.coupons.length, (i) {
            final c = controller.coupons[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CouponCard(coupon: c),
            );
          }),

          const SizedBox(height: 6),

          // View Used Coupons
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffE8E8E8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Used Coupons',
                  style: AppTextStyle.bodyMediumRegular
                      .copyWith(color: AppColor.blackShade1),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColor.coolGrayText, size: 22),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // How it works
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffFAF5EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffEEE2CC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffEDE5D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monetization_on_outlined,
                      color: AppColor.brownAccentPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How it works?',
                        style: AppTextStyle.titleSmallSemiBold
                            .copyWith(color: AppColor.blackShade1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apply a coupon code at checkout to get instant discount on your service booking.',
                        style: AppTextStyle.bodySmallRegular
                            .copyWith(color: AppColor.coolGrayText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Promo code card with dashed brown border
          CustomPaint(
            painter: _DashedRectPainter(
              color: AppColor.brownAccentPrimary,
              radius: 12,
              dashLength: 8,
              gapLength: 5,
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xffEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.confirmation_num_outlined,
                        color: Color(0xff999999), size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Have a Promo Code?',
                    style: AppTextStyle.headlineLargeBold
                        .copyWith(color: AppColor.blackShade1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your manual code below to\nadd it to your wallet.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMediumRegular
                        .copyWith(color: AppColor.coolGrayText),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.redeemCodeController,
                          decoration: InputDecoration(
                            hintText: 'Enter code here',
                            hintStyle: AppTextStyle.bodyMediumRegular
                                .copyWith(color: AppColor.coolGrayText),
                            filled: true,
                            fillColor: const Color(0xffF2F2F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.redeemCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.brownAccentDark,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Redeem',
                            style: AppTextStyle.titleSmallSemiBold
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Coupon card with notch ────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffE4E4E4)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['code'],
                            style: AppTextStyle.titleLargeBold
                                .copyWith(color: AppColor.blackShade1),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.lightGreen1Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                    radius: 4,
                                    backgroundColor: AppColor.green2Color),
                                const SizedBox(width: 5),
                                Text(
                                  'Valid',
                                  style: AppTextStyle.bodySmallRegular
                                      .copyWith(color: AppColor.green2Color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon['discount'],
                            style: AppTextStyle.titleLargeBold
                                .copyWith(color: AppColor.brownColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coupon['desc'],
                            style: AppTextStyle.bodySmallRegular
                                .copyWith(color: AppColor.coolGrayText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  color: const Color(0xffEEEEEE), height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      coupon['validTill'],
                      style: AppTextStyle.bodySmallRegular
                          .copyWith(color: AppColor.coolGrayText),
                    ),
                    Text(
                      'T&C Apply',
                      style: AppTextStyle.bodySmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.coolGrayText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Notch circle at the bottom center
        Positioned(
          bottom: -10,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xffF6F6F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xffE4E4E4)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  const _DashedRectPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = min(dist + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
