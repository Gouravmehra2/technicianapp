import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/service_type_model.dart';
import 'job_controller.dart';

// ─── Service Category Model ──────────────────────────────────────────────────

class ServiceCategory {
  final String label;
  final IconData icon;
  const ServiceCategory({required this.label, required this.icon});
}

// ─── Filter Controller ────────────────────────────────────────────────────────

class JobFilterController extends GetxController {
  late final JobController jobController;

  final recommendedSelected = false.obs;

  // Distance is stored in miles because that is what the API expects.
  final distanceMiles = 0.0.obs;

  // Earning options
  final earningOptions = ['Any', '\$500+', '\$1,000+', '\$2,000+'];
  final selectedEarning = 'Any'.obs;

  final selectedServiceTypeIds = <String>{}.obs;

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
    const ServiceCategory(
      label: 'Electrical',
      icon: Icons.electrical_services_outlined,
    ),
  ];
  final selectedCategory = 'TV & Audio'.obs;

  List<ServiceType> get serviceTypes => jobController.serviceTypes;

  @override
  void onInit() {
    super.onInit();
    jobController = Get.find<JobController>();
    recommendedSelected.value = jobController.recommendedSelected.value;
    distanceMiles.value =
        jobController.selectedDistanceMiles.value?.toDouble() ?? 0;
    selectedServiceTypeIds.assignAll(jobController.selectedServiceTypeIds);
    if (jobController.serviceTypes.isEmpty) jobController.loadServiceTypes();
  }

  void selectCategory(String cat) => selectedCategory.value = cat;

  void selectEarning(String opt) => selectedEarning.value = opt;

  void toggleServiceType(String id) {
    if (selectedServiceTypeIds.contains(id)) {
      selectedServiceTypeIds.remove(id);
    } else {
      selectedServiceTypeIds.add(id);
    }
    selectedServiceTypeIds.refresh();
  }

  void selectDate(String date) => selectedDate.value = date;

  void resetFilters() {
    distanceMiles.value = 0;
    selectedEarning.value = 'Any';
    selectedServiceTypeIds.clear();
    selectedServiceTypeIds.refresh();
    selectedDate.value = 'Today';
    selectedCategory.value = 'TV & Audio';
  }

  Future<void> applyFilters() async {
    jobController.recommendedSelected.value = recommendedSelected.value;
    jobController.selectedDistanceMiles.value = distanceMiles.value == 0
        ? null
        : distanceMiles.value.round();
    jobController.selectedServiceTypeIds
      ..clear()
      ..addAll(selectedServiceTypeIds);
    jobController.selectedServiceTypeIds.refresh();
    await jobController.loadTab(jobController.selectedTab.value);
    Get.back();
  }

  Future<void> clearFiltersAndBack() async {
    recommendedSelected.value = false;
    distanceMiles.value = 0;
    selectedEarning.value = 'Any';
    selectedServiceTypeIds.clear();
    selectedServiceTypeIds.refresh();
    selectedDate.value = 'Today';
    selectedCategory.value = 'TV & Audio';
    jobController.recommendedSelected.value = false;
    jobController.selectedDistanceMiles.value = null;
    jobController.selectedServiceTypeIds.clear();
    jobController.selectedServiceTypeIds.refresh();
    await jobController.loadTab(jobController.selectedTab.value);
    Get.back();
  }
}
