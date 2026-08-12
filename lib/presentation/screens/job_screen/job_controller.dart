import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum JobTabType { newJobs, activeJobs, completedJobs }

enum JobBadgeType { newBadge, installation, security, cleaning, active, updated, underProcessing }

enum JobPriceType { fixed, estimated, customQuote }

// ─── Models ───────────────────────────────────────────────────────────────────

class JobModel {
  final String id;
  final String title;
  final String category;
  final String distance;
  final String location;
  final String requestedTime;
  final JobPriceType priceType;
  final String priceLabel;
  final String? additionalNote;
  final JobBadgeType badge;
  final bool showDeclineAccept;
  final bool isCustomQuote;
  final String? quotedAmount;
  final String? revisedAmount;
  final bool showCancelRequest;
  final bool showRequestPayment;

  const JobModel({
    required this.id,
    required this.title,
    required this.category,
    required this.distance,
    required this.location,
    required this.requestedTime,
    required this.priceType,
    required this.priceLabel,
    this.additionalNote,
    required this.badge,
    this.showDeclineAccept = false,
    this.isCustomQuote = false,
    this.quotedAmount,
    this.revisedAmount,
    this.showCancelRequest = false,
    this.showRequestPayment = false,
  });
}

// ─── Controller ───────────────────────────────────────────────────────────────

class JobController extends GetxController {
  final selectedTab = JobTabType.newJobs.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ── New Jobs ──────────────────────────────────────────────────────────────
  final newJobs = <JobModel>[
    const JobModel(
      id: 'j1',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.fixed,
      priceLabel: 'Fixed: \$850',
      badge: JobBadgeType.newBadge,
      showDeclineAccept: true,
    ),
    const JobModel(
      id: 'j2',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.installation,
      showDeclineAccept: true,
    ),
    const JobModel(
      id: 'j3',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      additionalNote: '(Additional Gas Fueling \$100)',
      badge: JobBadgeType.security,
      showDeclineAccept: true,
    ),
    const JobModel(
      id: 'j4',
      title: 'Cleaning Room',
      category: 'Cleaning',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.customQuote,
      priceLabel: 'Custom Quote',
      badge: JobBadgeType.cleaning,
      showDeclineAccept: true,
      isCustomQuote: true,
    ),
  ].obs;

  // ── Active Jobs ───────────────────────────────────────────────────────────
  final activeJobs = <JobModel>[
    const JobModel(
      id: 'a1',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'a2',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'a3',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'a4',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Quoted: \$600 | Revised: \$560',
      badge: JobBadgeType.updated,
      showDeclineAccept: true,
    ),
    const JobModel(
      id: 'a5',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Quoted: \$600 | Revised: \$560',
      badge: JobBadgeType.updated,
      showDeclineAccept: true,
    ),
    const JobModel(
      id: 'a6',
      title: 'Gas Filling',
      category: 'Gas',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      additionalNote: '(Additional Gas Fueling \$100)',
      badge: JobBadgeType.underProcessing,
      showCancelRequest: true,
    ),
  ].obs;

  // ── Completed Jobs ────────────────────────────────────────────────────────
  final completedJobs = <JobModel>[
    const JobModel(
      id: 'c1',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: '9 Aug,2026 | 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'c2',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: '1 Aug,2026 | 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'c3',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: '24 July,2026 | 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
    ),
    const JobModel(
      id: 'c4',
      title: 'AC Installation',
      category: 'AC',
      distance: '2.6 km away',
      location: 'Sector 14',
      requestedTime: 'Today, 2:00 PM',
      priceType: JobPriceType.estimated,
      priceLabel: 'Est. \$850 - \$950',
      badge: JobBadgeType.active,
      showRequestPayment: true,
    ),
  ].obs;

  List<JobModel> get currentJobs {
    final q = searchQuery.value.toLowerCase();
    List<JobModel> list;
    switch (selectedTab.value) {
      case JobTabType.newJobs:
        list = newJobs;
        break;
      case JobTabType.activeJobs:
        list = activeJobs;
        break;
      case JobTabType.completedJobs:
        list = completedJobs;
        break;
    }
    if (q.isEmpty) return list;
    return list.where((j) => j.title.toLowerCase().contains(q) || j.category.toLowerCase().contains(q)).toList();
  }

  void selectTab(JobTabType tab) => selectedTab.value = tab;

  void onSearch(String q) => searchQuery.value = q;

  void openFilterScreen() => Get.toNamed(AppRoutes.jobFilterScreen);

  void declineJob(JobModel job) {
    // Remove from new jobs (demo logic)
    newJobs.removeWhere((j) => j.id == job.id);
  }

  void acceptJob(JobModel job) {
    if (job.isCustomQuote) {
      Get.toNamed(AppRoutes.jobSendQuoteScreen, arguments: job);
    } else {
      Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
    }
  }

  void viewJobDetails(JobModel job) {
    Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
  }

  void cancelRequest(JobModel job) {
    activeJobs.removeWhere((j) => j.id == job.id);
  }

  void acceptAtSame(JobModel job) {
    Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
  }

  void requestPayment(JobModel job) {
    // Navigate to payment screen
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
