import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class SpecialOfferCarousel extends StatelessWidget {
  final HomeController controller;

  const SpecialOfferCarousel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.88),
            onPageChanged: controller.onOfferPageChanged,
            itemCount: controller.specialOffers.length,
            itemBuilder: (context, index) {
              final offer = controller.specialOffers[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 6,
                  right: index == controller.specialOffers.length - 1 ? 16 : 6,
                ),
                child: GestureDetector(
                  onTap: () => controller.onSpecialOfferBookNow(offer),
                  child: Container(
                    decoration: BoxDecoration(
                      color: offer.bgColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowGrey.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background decorative circle
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: -30,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),

                        // Service person image on right side
                        Positioned(
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            child: Image.asset(
                              AppAssets.onboardingImage1,
                              width: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 140, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  offer.tag,
                                  style: AppTextStyle.labelSmallMedium.copyWith(
                                    color: AppColor.brownAccentDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),

                              // Title
                              Text(
                                offer.title,
                                style: AppTextStyle.titleMediumSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                  height: 1.2,
                                ),
                              ),

                              // Book Now button
                              GestureDetector(
                                onTap: () =>
                                    controller.onSpecialOfferBookNow(offer),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.blackColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    offer.buttonLabel,
                                    style: AppTextStyle.buttonSmall.copyWith(
                                      color: Colors.white,
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
                ),
              );
            },
          ),
        ),

        // ── Page indicator dots ────────────────────────────────────────────
        const SizedBox(height: 10),
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.specialOffers.length, (i) {
              final isActive = controller.offerBannerIndex.value == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColor.brownAccentPrimary
                      : AppColor.lightGreyColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
