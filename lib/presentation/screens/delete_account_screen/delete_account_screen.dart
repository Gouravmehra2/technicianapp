import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── Brown patterned background ──────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColor.brownAccentPrimary,
            child: CustomPaint(
              painter: _ServiceIconPatternPainter(),
            ),
          ),

          // ─── Back button + title ──────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Account',
                      style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Bottom confirmation sheet ────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Delete Account',
                    style: AppTextStyle.titleLargeBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This action cannot be undone. All\nyour data will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMediumRegular.copyWith(
                      color: AppColor.coolGrayText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Delete button
                  GestureDetector(
                    onTap: () {
                      Get.offAllNamed(AppRoutes.loginScreen);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Delete Account',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cancel button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColor.blackShade1,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceIconPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final icons = [
      Icons.build_outlined,
      Icons.ac_unit_outlined,
      Icons.car_repair,
      Icons.electrical_services_outlined,
      Icons.plumbing_outlined,
      Icons.cleaning_services_outlined,
      Icons.settings_outlined,
      Icons.work_outline,
      Icons.monitor_heart_outlined,
      Icons.home_repair_service_outlined,
    ];

    final positions = [
      Offset(size.width * 0.1, size.height * 0.08),
      Offset(size.width * 0.7, size.height * 0.05),
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.20),
      Offset(size.width * 0.05, size.height * 0.30),
      Offset(size.width * 0.6, size.height * 0.28),
      Offset(size.width * 0.25, size.height * 0.42),
      Offset(size.width * 0.75, size.height * 0.38),
      Offset(size.width * 0.15, size.height * 0.52),
      Offset(size.width * 0.55, size.height * 0.10),
    ];

    const iconSize = 52.0;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < positions.length; i++) {
      textPainter.text = TextSpan(
        text: String.fromCharCode(icons[i % icons.length].codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icons[i % icons.length].fontFamily,
          package: icons[i % icons.length].fontPackage,
          color: Colors.white.withValues(alpha: 0.14),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        positions[i] - const Offset(iconSize / 2, iconSize / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
