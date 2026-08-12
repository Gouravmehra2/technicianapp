import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget? child;

  const GradientBackground({super.key, this.child});

  static const RadialGradient gradient = RadialGradient(
    center: Alignment(0.0, -0.35),
    radius: 1.2,
    colors: [
      Color(0xFFD1A66C),
      Color(0xFFC18D4C),
      Color(0xFFA5732F),
      Color(0xFFF5EDD8),
      Color(0xFFFAFAFA),
    ],
    stops: [0.0, 0.35, 0.60, 0.78, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
