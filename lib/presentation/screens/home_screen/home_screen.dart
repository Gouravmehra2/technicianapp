import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/custom_search_bar.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/home_header.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/home_section_header.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/popular_services_row.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/service_categories_row.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/need_help_banner.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/special_offer_carousel.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/summer_heat_banner.dart';
import 'package:technicianapp/presentation/screens/home_screen/widgets/user_stories_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Single source of truth for horizontal page padding
  static const double _hPad = 16.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return MyScaffold(
          body: Container(
            height: Get.height,
            width: Get.width,
            decoration: const BoxDecoration(
              gradient: AppColor.homeScreenBackgroundGradient,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Get.height * 0.06),

                  // ── Header ────────────────────────────────────────────
                  HomeHeader(controller: controller),
                  const SizedBox(height: 16),

                  // ── Search Bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: CustomSearchBar(
                      hintText: 'home_search_hint'.tr,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Service Categories ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: HomeSectionHeader(
                      title: 'home_section_service_categories'.tr,
                      onViewAll: (){
                        Get.toNamed(AppRoutes.homeServicesScreen);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Widget owns its own horizontal: 20 padding internally
                  ServiceCategoriesRow(controller: controller),
                  const SizedBox(height: 16),

                  // ── Need Help SOS Banner ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: NeedHelpBanner(controller: controller),
                  ),
                  const SizedBox(height: 20),

                  // ── Special Offers ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: HomeSectionHeader(
                      title: 'home_section_special_offers'.tr,
                      onViewAll: controller.onViewAllOffersTapped,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Widget handles its own left/right padding per item
                  SpecialOfferCarousel(controller: controller),
                  const SizedBox(height: 20),

                  // ── Membership Plan ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: HomeSectionHeader(
                      title: 'home_section_membership'.tr,
                      onViewAll: controller.onViewAllOffersTapped,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: Image.asset(
                      AppAssets.specialOfferImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Popular Services ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: HomeSectionHeader(
                      title: 'home_section_popular_services'.tr,
                      onViewAll: controller.onViewAllPopularTapped,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PopularServicesCarousel(
                    services: controller.popularServices,
                    onBook: controller.onPopularServiceBook,
                  ),
                  const SizedBox(height: 20),

                  // ── Summer Heat Banner ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: SummerHeatBanner(controller: controller),
                  ),
                  const SizedBox(height: 20),

                  // ── User Stories ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: HomeSectionHeader(
                      title: 'home_section_user_stories'.tr,
                      onViewAll: controller.onViewAllStoriesTapped,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Widget owns its own horizontal: 20 padding internally
                  UserStoriesRow(controller: controller),
                  const SizedBox(height: 28),

                  // ── Footer tagline ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 2,
                              color: AppColor.brownAccentPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HEY, ${controller.userName.toUpperCase()}!',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                height: 1.4,
                                color: AppColor.coolGrayText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height:15),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Love Your\n',
                                style: AppTextStyle.displayHeroExtraBold.copyWith(
                                  color: const Color(0xff2F3334),
                                  letterSpacing: -3,
                                ),
                              ),
                              TextSpan(
                                text: 'Living',
                                style: AppTextStyle.displayHeroExtraBold.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height:15),
                        Text(
                          "We do the work so you don't have too",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.4,
                            color: AppColor.coolGrayText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

