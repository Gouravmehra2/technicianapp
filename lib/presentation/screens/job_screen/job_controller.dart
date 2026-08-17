import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

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
  final _api = Get.find<ApiRepo>();

  final selectedTab = JobTabType.newJobs.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final isLoading = false.obs;

  final newJobs = <JobModel>[].obs;
  final activeJobs = <JobModel>[].obs;
  final completedJobs = <JobModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadJobs();
  }

  Future<void> loadJobs() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _api.getTechnicianJobsApi(),
        _api.getTechnicianDashboardApi(),
      ]);

      // ── Open jobs → New Jobs tab ──────────────────────────────────────────
      final jobsModel = results[0] as NewJobsModel;
      if (jobsModel.success == true) {
        newJobs.value = (jobsModel.data?.jobs ?? [])
            .map((job) => _mapJobFromModel(job, showDeclineAccept: true))
            .toList();
      }

      // ── Dashboard requests → Active / Completed tabs ──────────────────────
      final dashboard = results[1] as DashboardModel;
      if (dashboard.success == true) {
        final requests = dashboard.data?.requests ?? [];
        final active = <JobModel>[];
        final completed = <JobModel>[];
        for (final r in requests) {
          final job = r.job;
          if (job == null) continue;
          final model = _mapJobFromDashboard(
            job,
            showRequestPayment: job.jobCompletedAt != null && job.status != 'completed',
          );
          if (job.status == 'completed') {
            completed.add(model);
          } else if (r.status == 'accepted') {
            active.add(model);
          }
        }
        activeJobs.value = active;
        completedJobs.value = completed;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  JobModel _mapJobFromModel(Jobs job, {bool showDeclineAccept = false}) {
    return JobModel(
      id: job.sId ?? '',
      title: job.title ?? '',
      category: job.category ?? '',
      distance: job.location ?? '',
      location: job.location ?? '',
      requestedTime: _formatDate(job.scheduledDate ?? job.serviceDate ?? job.deadline),
      priceType: JobPriceType.fixed,
      priceLabel: '\$${job.budget ?? 0}',
      badge: job.status == 'in-progress' ? JobBadgeType.active : JobBadgeType.newBadge,
      showDeclineAccept: showDeclineAccept,
    );
  }

  JobModel _mapJobFromDashboard(Job job, {bool showRequestPayment = false}) {
    return JobModel(
      id: job.sId ?? '',
      title: job.title ?? '',
      category: job.category ?? '',
      distance: job.location ?? '',
      location: job.location ?? '',
      requestedTime: _formatDate(job.scheduledDate ?? job.serviceDate ?? job.deadline),
      priceType: JobPriceType.fixed,
      priceLabel: '\$${job.budget ?? 0}',
      badge: job.status == 'in-progress' ? JobBadgeType.active : JobBadgeType.newBadge,
      showRequestPayment: showRequestPayment,
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return 'TBD';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month} $hour:$min $period';
    } catch (_) {
      return raw.toString();
    }
  }

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
