import 'package:flutter/material.dart';

/// Central place for all text styles in the app.
/// Font family: Inter (Regular 400, Medium 500, SemiBold 600, Bold 700)
class AppTextStyle {
  AppTextStyle._();

  static const String _fontFamily = 'Inter';

  // ─── Display ────────────────────────────────────────────────────────────────

  /// Hero display style — Inter ExtraBold 800, 60px, line-height 56px
  static const TextStyle displayHeroExtraBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 60,
    height: 0.933, // 56px / 60px
  );

  static const TextStyle displayLargeBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.25,
  );

  static const TextStyle displayMediumBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.25,
  );

  // ─── Headline ────────────────────────────────────────────────────────────────

  static const TextStyle headlineLargeBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.3,
  );

  static const TextStyle headlineMediumSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.3,
  );

  static const TextStyle headlineSmallSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.3,
  );

  // ─── Title ───────────────────────────────────────────────────────────────────

  static const TextStyle titleLargeBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.4,
  );

  static const TextStyle titleLargeSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.4,
  );

  static const TextStyle titleMediumSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
  );

  static const TextStyle titleMediumMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.4,
  );

  static const TextStyle titleSmallSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle titleSmallMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
  );

  // ─── Body ────────────────────────────────────────────────────────────────────

  static const TextStyle bodyLargeRegular = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle bodyMediumRegular = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle bodyMediumMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle bodySmallRegular = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
  );

  static const TextStyle bodySmallMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.5,
  );

  // ─── Label / Caption ─────────────────────────────────────────────────────────

  static const TextStyle labelMediumSemiBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.4,
  );

  static const TextStyle labelSmallRegular = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1.4,
  );

  static const TextStyle labelSmallMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    height: 1.4,
  );

  // ─── Button ──────────────────────────────────────────────────────────────────

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.25,
    letterSpacing: 0.25,
  );
}
