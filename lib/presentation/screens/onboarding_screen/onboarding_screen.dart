import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_bottom_sheet.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_worm_effect.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/onboarding_controller.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/widget/login_bottom_sheet.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final controller = Get.put(OnboardingController());

  static const _bgColor = Color(0xffFCF1E4);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final bottomPad = mq.padding.bottom;
    final topPad = mq.padding.top;

    // Card height scales with screen — clamp between 260 and 340
    final cardHeight = (screenH * 0.36).clamp(260.0, 340.0);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      body: Obx(() {
        final currentIndex = controller.currentPage.value;
        final isLast = currentIndex == controller.onboardingStepList.length - 1;

        return Stack(
          children: [
            // ── PageView ──────────────────────────────────────────────────
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.onboardingStepList.length,
              itemBuilder: (_, index) {
                final data = controller.onboardingStepList[index];
                return _SlidePage(
                  data: data,
                  cardHeight: cardHeight,
                );
              },
            ),

            // ── Back button ───────────────────────────────────────────────
            if (currentIndex > 0)
              Positioned(
                top: topPad + 12,
                left: 16,
                child: GestureDetector(
                  onTap: controller.backPage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                ),
              ),

            // ── Bottom white card ─────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomCard(
                currentIndex: currentIndex,
                total: controller.onboardingStepList.length,
                isLast: isLast,
                bottomPad: bottomPad,
                cardHeight: cardHeight,
                onSkip: () => CommonBottomSheet.show(child: LoginBottomSheet()),
                onNext: controller.nextPage,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── One slide: image fills top (behind status bar), space reserved at bottom ──

class _SlidePage extends StatelessWidget {
  final OnboardingStepModel data;
  final double cardHeight;

  const _SlidePage({required this.data, required this.cardHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image stretches from very top (behind status bar) to above the card
        Positioned(
          top: Get.height*0.05,
          left: 0,
          right: 0,
          bottom: cardHeight,
          child: Image.asset(
            data.imagePath ?? '',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

// ── Bottom white card ─────────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool isLast;
  final double bottomPad;
  final double cardHeight;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _BottomCard({
    required this.currentIndex,
    required this.total,
    required this.isLast,
    required this.bottomPad,
    required this.cardHeight,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    // Scale font/spacing proportionally on wider screens
    final titleSize = (screenW * 0.082).clamp(26.0, 36.0);
    final descSize = (screenW * 0.042).clamp(13.0, 17.0);
    final hPad = (screenW * 0.064).clamp(20.0, 32.0);

    return Container(
      height: cardHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Two-tone title ───────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _TwoToneTitle(
              key: ValueKey(currentIndex),
              line1: _title1(currentIndex),
              line2: _title2(currentIndex),
              fontSize: titleSize,
            ),
          ),

          const SizedBox(height: 10),

          // ── Description ──────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _desc(currentIndex),
              key: ValueKey('d$currentIndex'),
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyLargeRegular.copyWith(
                fontSize: descSize,
                color: AppColor.blackShade1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Spacer(),

          // ── Controls ─────────────────────────────────────────────────────
          if (isLast)
            CommonButton(
              label: 'onboarding_get_started'.tr,
              onTap: onNext,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'onboarding_skip'.tr,
                      style: AppTextStyle.titleMediumMedium.copyWith(
                        color: AppColor.coolGrayText,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: CommonWormIndicator(
                      count: total,
                      currentIndex: currentIndex,
                      activeColor: AppColor.brownAccentPrimary,
                      unActiveColor: const Color(0xFFD4C4B0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'onboarding_next'.tr,
                      style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _title1(int i) => [
        'onboarding_slide1_title',
        'onboarding_slide2_title',
        'onboarding_slide3_title',
        'onboarding_slide4_title',
      ][i].tr;

  String _title2(int i) => [
        'onboarding_slide1_title2',
        'onboarding_slide2_title2',
        'onboarding_slide3_title2',
        'onboarding_slide4_title2',
      ][i].tr;

  String _desc(int i) => [
        'onboarding_slide1_desc',
        'onboarding_slide2_desc',
        'onboarding_slide3_desc',
        'onboarding_slide4_desc',
      ][i].tr;
}

// ── Two-tone title ────────────────────────────────────────────────────────────

class _TwoToneTitle extends StatelessWidget {
  final String line1;
  final String line2;
  final double fontSize;

  const _TwoToneTitle({
    super.key,
    required this.line1,
    required this.line2,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle.displayMediumBold.copyWith(
      fontSize: fontSize,
      height: 1.2,
    );
    return Column(
      children: [
        Text(
          line1,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: style.copyWith(color: AppColor.blackShade1),
        ),
        Text(
          line2,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: style.copyWith(color: AppColor.brownAccentPrimary),
        ),
      ],
    );
  }
}
