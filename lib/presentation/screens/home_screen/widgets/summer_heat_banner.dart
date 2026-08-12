import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

/// Auto-scrolling carousel of summer/seasonal promotion banners.
class SummerHeatBanner extends StatefulWidget {
  final HomeController controller;

  const SummerHeatBanner({super.key, required this.controller});

  @override
  State<SummerHeatBanner> createState() => _SummerHeatBannerState();
}

class _SummerHeatBannerState extends State<SummerHeatBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final banners = widget.controller.summerBanners;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            // height: ,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: false,
            onPageChanged: (index, _) =>
                setState(() => _currentIndex = index),
          ),
          itemBuilder: (context, index, _) {
            final banner = banners[index];
            return _BannerSlide(
              banner: banner,
              onTap: banner.onTap ?? widget.controller.onSummerHeatBannerTapped,
            );
          },
        ),

        const SizedBox(height: 10),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final bool isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColor.brownAccentPrimary
                    : AppColor.brownAccentPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final SummerBanner banner;
  final VoidCallback onTap;

  const _BannerSlide({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          banner.imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
