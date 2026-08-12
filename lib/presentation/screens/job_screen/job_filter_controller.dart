import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Service Category Model ──────────────────────────────────────────────────

class ServiceCategory {
  final String label;
  final IconData icon;
  const ServiceCategory({required this.label, required this.icon});
}

// ─── Filter Controller ────────────────────────────────────────────────────────

class JobFilterController extends GetxController {
  // Distance
  final distanceKm = 10.0.obs;

  // Earning options
  final earningOptions = ['Any', '\$500+', '\$1,000+', '\$2,000+'];
  final selectedEarning = 'Any'.obs;

  // Job types
  final jobTypes = ['Fixed Price', 'Custom Quote', 'Emergency'];
  final selectedJobTypes = <String>{'Fixed Price', 'Custom Quote'}.obs;

  // Date options
  final dateOptions = ['Today', 'Tomorrow', 'This Week', 'Custom'];
  final selectedDate = 'Today'.obs;

  // Service categories
  final categories = <ServiceCategory>[
    const ServiceCategory(label: 'TV & Audio', icon: Icons.tv_outlined),
    const ServiceCategory(label: 'Smart Home', icon: Icons.home_outlined),
    const ServiceCategory(label: 'Networking', icon: Icons.device_hub_outlined),
    const ServiceCategory(label: 'CCTV', icon: Icons.videocam_outlined),
    const ServiceCategory(label: 'Computer', icon: Icons.computer_outlined),
    const ServiceCategory(label: 'Electrical', icon: Icons.electrical_services_outlined),
  ];
  final selectedCategory = 'TV & Audio'.obs;

  void selectCategory(String cat) => selectedCategory.value = cat;

  void selectEarning(String opt) => selectedEarning.value = opt;

  void toggleJobType(String type) {
    if (selectedJobTypes.contains(type)) {
      selectedJobTypes.remove(type);
    } else {
      selectedJobTypes.add(type);
    }
  }

  void selectDate(String date) => selectedDate.value = date;

  void resetFilters() {
    distanceKm.value = 10.0;
    selectedEarning.value = 'Any';
    selectedJobTypes.assignAll({'Fixed Price', 'Custom Quote'});
    selectedDate.value = 'Today';
    selectedCategory.value = 'TV & Audio';
  }

  void applyFilters() {
    Get.back();
  }
}
