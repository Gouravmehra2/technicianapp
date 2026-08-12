import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  const CategoryItem({required this.label, required this.icon});
}

class HeroBanner {
  final String title;
  final String titleHighlight;
  final String subtitle;
  final String imagePath;
  const HeroBanner({
    required this.title,
    this.titleHighlight = '',
    required this.subtitle,
    required this.imagePath,
  });
}

class HomeServicesController extends GetxController {
  final selectedTabIndex = 0.obs;
  final showAllCategories = false.obs;

  final tabs = ['All', 'Home Services', 'Business Services'];

  final heroBanners =  [
    HeroBanner(
      title: 'Professional\nCleaning for a\nHealthier Home',
      titleHighlight: 'Cleaning',
      subtitle: 'Book trusted experts\nat your doorstep.',
      imagePath: AppAssets.onboardingImage1,
    ),
    HeroBanner(
      title: 'Home Services',
      subtitle: 'Trusted professionals for all your home maintenance and repair needs.',
      imagePath: AppAssets.onboardingImage2,
    ),
    HeroBanner(
      title: 'Business Services',
      subtitle: 'Professional solutions for your business needs.',
      imagePath: AppAssets.onboardingImage1,
    ),
  ];

  final allServiceCategories = const [
    CategoryItem(label: 'Home\nServices', icon: Icons.home_repair_service_outlined),
    CategoryItem(label: 'Business\nServices', icon: Icons.business_center_outlined),
    CategoryItem(label: 'IT &\nTechnology', icon: Icons.computer_outlined),
    CategoryItem(label: 'Marketing &\nBranding', icon: Icons.campaign_outlined),
    CategoryItem(label: 'Professional\nServices', icon: Icons.build_outlined),
    CategoryItem(label: 'Health &\nWellness', icon: Icons.favorite_border),
    CategoryItem(label: 'Beauty &\nPersonal Care', icon: Icons.content_cut_outlined),
    CategoryItem(label: 'Transportation\nServices', icon: Icons.directions_car_outlined),
  ];

  final homeServiceCategories = const [
    CategoryItem(label: 'AC & Appliance', icon: Icons.ac_unit_outlined),
    CategoryItem(label: 'Carpentry', icon: Icons.carpenter),
    CategoryItem(label: 'Cleaning', icon: Icons.cleaning_services_outlined),
    CategoryItem(label: 'Diagnostic', icon: Icons.home_outlined),
    CategoryItem(label: 'Electrical', icon: Icons.lightbulb_outline),
    CategoryItem(label: 'Gardening', icon: Icons.yard_outlined),
    CategoryItem(label: 'Handyman', icon: Icons.handyman_outlined),
    CategoryItem(label: 'Home Theater', icon: Icons.tv_outlined),
    CategoryItem(label: 'Painting', icon: Icons.format_paint_outlined),
    CategoryItem(label: 'Pest Control', icon: Icons.pest_control_outlined),
    CategoryItem(label: 'Plumbing', icon: Icons.plumbing_outlined),
    CategoryItem(label: 'Smart Home', icon: Icons.home_outlined),
    CategoryItem(label: 'TV Mounting', icon: Icons.tv_outlined),
  ];

  final popularServices = [
    ServiceModel(name: 'Smart Lock - Video Doorbell Setup', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
    ServiceModel(name: 'Thermostats Installation', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
    ServiceModel(name: 'TV Mounting', price: '\$10', rating: 4.3, reviews: 124, image: AppAssets.dummyServiceImage),
  ];

  List<CategoryItem> get baseCategories =>
      selectedTabIndex.value == 1 ? homeServiceCategories : allServiceCategories;

  List<CategoryItem> get visibleCategories {
    final cats = baseCategories;
    if (selectedTabIndex.value == 1) {
      if (showAllCategories.value) {
        return cats;
      }
      return cats.take(7).toList();
    }
    return cats;
  }

  bool get canToggle => selectedTabIndex.value == 1;

  HeroBanner get currentBanner => heroBanners[selectedTabIndex.value];

  String get appBarTitle {
    if (selectedTabIndex.value == 1) return 'Home Services';
    if (selectedTabIndex.value == 2) return 'Business Services';
    return 'All Services';
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    showAllCategories.value = false;
  }

  void toggleCategories() => showAllCategories.value = !showAllCategories.value;
}
