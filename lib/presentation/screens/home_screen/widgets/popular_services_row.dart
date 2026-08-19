import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

/// A carousel of popular-service cards that auto-scrolls every 3 seconds.
class PopularServicesCarousel extends StatefulWidget {
  final List<PopularService> services;
  final void Function(PopularService) onBook;

  const PopularServicesCarousel({
    super.key,
    required this.services,
    required this.onBook,
  });

  @override
  State<PopularServicesCarousel> createState() =>
      _PopularServicesCarouselState();
}

class _PopularServicesCarouselState extends State<PopularServicesCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.services.length,
          options: CarouselOptions(
            height: 210,
            viewportFraction: 0.55,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final service = widget.services[index];
            return _ServiceCard(
              service: service,
              onBook: () => widget.onBook(service),
            );
          },
        ),

        const SizedBox(height: 10),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.services.length, (index) {
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

/// Single card — kept private, used only by the carousel above.
class _ServiceCard extends StatelessWidget {
  final PopularService service;
  final VoidCallback onBook;

  const _ServiceCard({required this.service, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowGrey.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              service.imagePath,
              fit: BoxFit.cover,
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Favourite icon
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Bottom content
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleMediumMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '123 Reviews',
                    style: AppTextStyle.titleMediumMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: onBook,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.brownAccentPrimary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        service.buttonLabel,
                        style: AppTextStyle.buttonMedium.copyWith(
                          color: AppColor.neutral2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
