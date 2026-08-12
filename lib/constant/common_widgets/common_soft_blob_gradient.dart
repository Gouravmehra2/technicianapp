import 'dart:ui';
import 'package:flutter/material.dart';

class CommonSoftBlobGradient extends StatelessWidget {
  final Color color;
  final double? width;
  final double? height;
  final double? opacity;
  final BoxShape? boxShape;

  const CommonSoftBlobGradient({
    super.key,
    required this.color,
    this.width = 100,
    this.height = 100,
    this.opacity = 0.20,
    this.boxShape
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: boxShape ?? BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}
