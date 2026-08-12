import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class CommonWormIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;
  final Color? activeColor;
  final Color? unActiveColor;

  const CommonWormIndicator({
    super.key,
    required this.currentIndex,
    required this.count,
    this.activeColor,
    this.unActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: currentIndex == index
                ? activeColor ?? AppColor.brownAccentPrimary
                : unActiveColor ??  AppColor.darkGray,
          ),
        ),
      ),
    );
  }
}