import 'dart:math';
import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class CircularOrbitWidget extends StatefulWidget {
  const CircularOrbitWidget({super.key});

  @override
  State<CircularOrbitWidget> createState() => _CircularOrbitWidgetState();
}

class _CircularOrbitWidgetState extends State<CircularOrbitWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final List<IconData> outerIcons = [
    Icons.desktop_windows_outlined,
    Icons.flash_on_outlined,
    Icons.videocam_outlined,
  ];

  final List<IconData> middleIcons = [
    Icons.laptop_mac_outlined,
    Icons.center_focus_strong,
    Icons.call_split_outlined,
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget orbitItem(IconData icon, double itemSize) {
    return Container(
      width: itemSize,
      height: itemSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Icon(
          icon,
          size: itemSize * 0.44,
          color: const Color(0xff111827),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // base size drives all proportions; clamped so it looks good on tiny & large screens
    final double s = (screenWidth * 0.85).clamp(260.0, 420.0);
    final double outerR = s * 0.5;       // orbit radius (centre to icon centre)
    final double middleR = s * 0.343;    // ~120/350 ratio
    final double outerRingD = s;         // outer ring diameter
    final double middleRingD = s * 0.686;
    final double centerD = s * 0.40;
    final double logoD = centerD * 0.71;
    final double itemSize = s * 0.143;   // ~50/350

    return Center(
      child: SizedBox(
        width: screenWidth,
        height: s,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                /// OUTER CIRCLE
                Container(
                  width: outerRingD,
                  height: outerRingD,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),

                /// MIDDLE CIRCLE
                Container(
                  width: middleRingD,
                  height: middleRingD,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),

                /// CENTER LOGO
                Container(
                  width: centerD,
                  height: centerD,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.brownAccentPrimary.withValues(alpha: 0.60),
                        blurStyle: BlurStyle.outer,
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAssets.appLogoIcon,
                        width: logoD,
                        height: logoD,
                      ),
                    ),
                  ),
                ),

                /// OUTER ORBIT
                ...List.generate(outerIcons.length, (index) {
                  final angle = (2 * pi / outerIcons.length) * index +
                      controller.value * 2 * pi;
                  return Transform.translate(
                    offset: Offset(outerR * cos(angle), outerR * sin(angle)),
                    child: orbitItem(outerIcons[index], itemSize),
                  );
                }),

                /// INNER ORBIT
                ...List.generate(middleIcons.length, (index) {
                  final angle = (2 * pi / middleIcons.length) * index -
                      controller.value * 2 * pi;
                  return Transform.translate(
                    offset: Offset(middleR * cos(angle), middleR * sin(angle)),
                    child: orbitItem(middleIcons[index], itemSize),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}