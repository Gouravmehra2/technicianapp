import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/language_service.dart';

/// Model for a service category tile
class ServiceCategory {
  final String icon;
  final String label;
  final bool isSvg;

  const ServiceCategory({
    required this.icon,
    required this.label,
    this.isSvg = false,
  });
}

/// Model for a special offer / banner card
class OfferBanner {
  final String tag;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color bgColor;

  const OfferBanner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.bgColor,
  });
}

/// Model for a popular service card
class PopularService {
  final String imagePath;
  final String title;
  final String buttonLabel;

  const PopularService({
    required this.imagePath,
    required this.title,
    required this.buttonLabel,
  });
}

/// Model for a summer-heat banner slide
class SummerBanner {
  final String imagePath;
  final VoidCallback? onTap;

  const SummerBanner({
    required this.imagePath,
    this.onTap,
  });
}

/// Model for a user story card – supports both image and video assets.
class UserStory {
  final String mediaPath;
  final String title;

  /// When [isVideo] is true, [mediaPath] points to an asset video file.
  /// Otherwise it is treated as an image asset.
  final bool isVideo;

  const UserStory({
    required this.mediaPath,
    required this.title,
    this.isVideo = false,
  });
}

class HomeController extends GetxController {
  // ── State ────────────────────────────────────────────────────────────────────

  final String userName = 'Jagritii';
  final String address = 'CDS Stores, Greenfall Road...';
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  /// Index of the currently visible special offer banner
  final RxInt offerBannerIndex = 0.obs;

  // ── Data ─────────────────────────────────────────────────────────────────────

  List<ServiceCategory> get serviceCategories => [
    ServiceCategory(
      icon: 'assets/images/smart.png',
      label: 'home_cat_smart_home'.tr,
    ),
    ServiceCategory(
      icon: 'assets/images/tv_mountain.png',
      label: 'home_cat_tv_mount'.tr,
    ),
    ServiceCategory(
      icon: 'assets/images/wifi_icon.png',
      label: 'home_cat_wifi'.tr,
    ),
    ServiceCategory(
      icon: 'assets/images/computer_device_support.png',
      label: 'home_cat_computer'.tr,
    ),
    ServiceCategory(
      icon: 'assets/images/security.png',
      label: 'home_cat_security'.tr,
    ),
    ServiceCategory(
      icon: 'assets/images/video.png',
      label: 'home_cat_audio_video'.tr,
    ),
  ];

  List<OfferBanner> get specialOffers => [
    OfferBanner(
      tag: 'home_offer_tag_exclusive'.tr,
      title: 'home_offer1_title'.tr,
      subtitle: '',
      buttonLabel: 'home_offer_book_now'.tr,
      bgColor: const Color(0xFFFFBB5E),
    ),
    OfferBanner(
      tag: 'home_offer_tag_limited'.tr,
      title: 'home_offer2_title'.tr,
      subtitle: '',
      buttonLabel: 'home_offer_book_now'.tr,
      bgColor: const Color(0xFFADD8E6),
    ),
  ];

  List<PopularService> get popularServices => [
    PopularService(
      imagePath: AppAssets.serviceImage,
      title: 'TV Mount AC',
      buttonLabel: 'home_popular_book_service'.tr,
    ),
    PopularService(
      imagePath: AppAssets.serviceImage,
      title: 'TV Mount AC',
      buttonLabel: 'home_popular_book_service'.tr,
    ),
    PopularService(
      imagePath: AppAssets.serviceImage,
      title: 'TV Mount AC',
      buttonLabel: 'home_popular_book_service'.tr,
    ),
  ];

  final List<SummerBanner> summerBanners = [
    SummerBanner(
      imagePath: AppAssets.bannerImage1,
    ),
    SummerBanner(
      imagePath: AppAssets.bannerImage2,
    ),
    SummerBanner(
      imagePath: AppAssets.bannerImage3,
    ),
  ];

  List<UserStory> get userStories => [
    UserStory(
      mediaPath: 'assets/images/service_video.mp4',
      title: 'home_story1_title'.tr,
      isVideo: true,
    ),
    UserStory(
      mediaPath: 'assets/images/onboarding_image_2.png',
      title: 'home_story2_title'.tr,
    ),
    UserStory(
      mediaPath: 'assets/images/onboarding_image_1.png',
      title: 'home_story3_title'.tr,
    ),
  ];

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home_greeting_morning'.tr;
    if (hour < 17) return 'home_greeting_afternoon'.tr;
    return 'home_greeting_evening'.tr;
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onOfferPageChanged(int index) {
    offerBannerIndex.value = index;
  }

  void onViewAllServicesTapped() {
    // TODO: navigate to services list
  }

  void onViewAllOffersTapped() {
    // TODO: navigate to offers list
  }

  void onViewAllPopularTapped() {
    // TODO: navigate to popular services list
  }

  void onViewAllStoriesTapped() {
    // TODO: navigate to stories list
  }

  void onServiceCategoryTapped(ServiceCategory category) {
    // TODO: navigate to service category detail
  }

  void onSpecialOfferBookNow(OfferBanner offer) {
    // TODO: navigate to booking
  }

  void onPopularServiceBook(PopularService service) {
    // TODO: navigate to booking
  }

  void onNeedHelpSosTapped() {
    // TODO: trigger SOS / help flow
  }

  void onSquadCarePlusTapped() {
    // TODO: navigate to Squad Care+ detail
  }

  void onSummerHeatBannerTapped() {
    // TODO: navigate to summer deal
  }

  void onNotificationsTapped() {
    // TODO: navigate to notifications
    Get.toNamed(AppRoutes.notificationScreen);
  }

  void onProfileTapped() {
    // TODO: navigate to profile
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
