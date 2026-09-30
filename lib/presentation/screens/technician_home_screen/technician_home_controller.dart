import 'dart:async';

import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/core/services/firebase_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/earnings_screen/your_earnings_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/service_type_model.dart';

class TechnicianHomeController extends GetxController {
  final ApiRepo apiRepo = Get.find<ApiRepo>();

  final dashboardController = Get.put(DashboardController());
  final jobController = Get.put(JobController());

  // ── Reactive state ───────────────────────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxString totalEarnings = '\$0'.obs;
  final RxInt newRequestsCount = 0.obs;
  final RxInt activeJobsCount = 0.obs;
  final RxInt todayScheduleCount = 0.obs;
  final RxDouble rating = 0.0.obs;
  final RxBool isLoading = false.obs;

  // Metrics (from GET /api/technician/metrics)
  final RxInt activeJob = 0.obs;
  final RxInt todayJobCount = 0.obs;
  final RxInt requestCount = 0.obs;

  // Using the actual model classes directly
  final RxList<Requests> todaySchedule = <Requests>[].obs;
  final RxList<Jobs> newJobs = <Jobs>[].obs;
  final RxList<ServiceType> serviceTypes = <ServiceType>[].obs;
  final RxSet<String> selectedServiceTypeIds = <String>{}.obs;
  final RxBool recommendedSelected = false.obs;
  final RxnInt selectedDistanceMiles = RxnInt();
  final RxBool isServiceTypesLoading = false.obs;

  String get selectedServiceTypeLabel {
    final selectedNames = serviceTypes
        .where((type) => selectedServiceTypeIds.contains(type.id))
        .map((type) => type.name)
        .toList();
    if (selectedNames.isEmpty) return 'All Job Types';
    if (selectedNames.length <= 2) return selectedNames.join(', ');
    return '${selectedNames.take(2).join(', ')} +${selectedNames.length - 2}';
  }

  /// Today's scheduled jobs fetched directly from GET /api/technician/jobs?filter=today
  final RxList<Jobs> todayScheduledJobs = <Jobs>[].obs;
  final RxBool isScheduleLoading = false.obs;

  final RxString selectedPeriod = 'This Week'.obs;

  DashboardModel? dashboardData;
  NewJobsModel? jobsData;

  @override
  void onInit() {
    super.onInit();
    _requestNotificationPermission();
    hitDashboardApi();
    hitJobsApi();
    hitServiceTypesApi();
    hitMetricsApi();
    hitTodayScheduleApi();
    _listenToSocket();
  }

  void _requestNotificationPermission() {
    if (!Get.isRegistered<FirebaseService>()) return;
    unawaited(FirebaseService.to.requestNotificationPermission());
  }

  /// Subscribe to real-time job/request socket events.
  void _listenToSocket() {
    final socket = SocketService.instance;
    final technicianId = AuthService.to.user.value?.user?.id ?? '';
    socket.connectAndJoin(
      technicianId: technicianId.isNotEmpty ? technicianId : null,
    );

    socket.on('job:new', (data) {
      print('[Home] job:new → refreshing jobs');
      hitJobsApi();
    });

    socket.on('job:updated', (data) {
      print('[Home] job:updated → refreshing dashboard & jobs');
      hitDashboardApi();
      hitJobsApi();
      hitTodayScheduleApi();
    });

    socket.on('job:deleted', (data) {
      print('[Home] job:deleted → refreshing jobs');
      hitJobsApi();
    });

    socket.on('request:updated', (data) {
      print('[Home] request:updated → refreshing dashboard');
      hitDashboardApi();
    });

    socket.on('request:status', (data) {
      print('[Home] request:status → refreshing dashboard');
      hitDashboardApi();
    });
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  RxString get currentLocation => LocationService.to.confirmedAddress;

  String _formatDate(dynamic raw) {
    if (raw == null) return 'TBD';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $period';
    } catch (_) {
      return raw.toString();
    }
  }

  // ── Earnings ─────────────────────────────────────────────────────────────────
  void onEarningsTapped() => Get.to(() => const YourEarningsScreen());

  // ── Location ──────────────────────────────────────────────────────────────────
  void onLocationTapped() => Get.toNamed(AppRoutes.selectLocationScreen);

  // ── Notifications ─────────────────────────────────────────────────────────────
  void onNotificationTapped() => Get.toNamed(AppRoutes.notificationScreen);

  // ── Today's Schedule ──────────────────────────────────────────────────────────
  void onViewAllSchedule() => _switchDashboardTab(2);

  void onNavigateTapped(Requests request) {
    Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: request.job);
  }

  void onContactSupportTapped(Requests request) =>
      Get.toNamed(AppRoutes.supportScreen);

  void onViewDetailsTapped(Requests request) {
    Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: request.job);
  }

  /// Navigate button for a [Jobs] item — opens Google Maps if coordinates exist,
  /// otherwise falls back to the in-app navigation screen.
  // void onNavigateJobTapped(Jobs job) {
  //   final lat = job.coordinates?.lat;
  //   final lng = job.coordinates?.lng;
  //   if (lat != null && lng != null) {
  //     MapLaunchHelper.navigateTo(lat: lat, lng: lng);
  //   } else {
  //     Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: job);
  //   }
  // }

  /// Contact support for a [Jobs] item.
  void onContactSupportJobTapped(Jobs job) =>
      Get.toNamed(AppRoutes.supportScreen);

  /// View details for a [Jobs] item (from today-schedule API).
  /// • ontheway  → resume live navigation on ScheduleJobNavigationScreen
  /// • inprogress → open ScheduleJobDetailScreen (checklist)
  /// • everything else (assigned, upcoming, etc.) → open generic JobDetailScreen
  void onViewDetailsJobTapped(Jobs job) {
    final status = (job.status ?? '').toLowerCase();
    if (status == 'ontheway') {
      final model = _buildScheduledJobModel(job);
      Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: model);
    } else if (status == 'inprogress') {
      final model = _buildScheduledJobModel(job);
      Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: model);
    } else {
      Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
    }
  }

  /// Converts a raw [Jobs] API object into a [ScheduledJobModel] suitable for
  /// the schedule-job screens (navigation, detail, etc.).
  ScheduledJobModel _buildScheduledJobModel(Jobs job) {
    final from = job.jobDate?.from ?? '';
    final to = job.jobDate?.to ?? '';
    final time = () {
      if (from.isNotEmpty && to.isNotEmpty) {
        return '${_formatDate(from)} – ${_formatDate(to)}';
      }
      if (from.isNotEmpty) return _formatDate(from);
      return _formatDate(job.scheduledDate ?? job.serviceDate);
    }();
    return ScheduledJobModel(
      time: time,
      duration: job.estimatedTime ?? '',
      title: job.title ?? '',
      jobId: job.sId ?? '',
      distance: job.location ?? '',
      rawJobId: (job.sId ?? '').isNotEmpty ? job.sId : null,
      lat: job.coordinates?.lat,
      lng: job.coordinates?.lng,
      rawJob: job,
      status: (job.status ?? '').toLowerCase() == 'inprogress'
          ? JobStatus.inProgress
          : (job.status ?? '').toLowerCase() == 'ontheway'
          ? JobStatus.onTheWay
          : (job.status ?? '').toLowerCase() == 'completed'
          ? JobStatus.completed
          : JobStatus.upcoming,
    );
  }

  // ── New Jobs ──────────────────────────────────────────────────────────────────
  void onViewAllNewJobs() => _switchDashboardTab(1); // Jobs screen

  Future<void> openJobsTab(JobTabType tab) async {
    _switchDashboardTab(1);
    await jobController.changeTab(tab, reload: true);
  }

  void openScheduleTab() {
    _switchDashboardTab(2);
    final scheduleController = Get.isRegistered<ScheduleJobController>()
        ? Get.find<ScheduleJobController>()
        : Get.put(ScheduleJobController());
    scheduleController.selectedTab.value = 0;
  }

  /// Tracks which job IDs are currently being requested from the home screen.
  final requestingJobIds = <String>{}.obs;

  /// Called when the user taps "Request job" on a home-screen new-job card.
  ///
  /// Hits POST /api/technician/jobs/:id/request, then navigates to the Jobs
  /// screen on the "Requested Jobs" tab via [JobController].
  Future<void> onRequestJob(Jobs job) async {
    final jobId = job.sId ?? '';
    if (jobId.isEmpty || requestingJobIds.contains(jobId)) return;
    requestingJobIds.add(jobId);
    try {
      await jobController.requestJob(job);
      // Remove from home list after success
      newJobs.removeWhere((j) => j.sId == job.sId);
    } finally {
      requestingJobIds.remove(jobId);
    }
  }

  void onAcceptJob(Jobs job) => onRequestJob(job);

  void onCounterOffer(Jobs job) {
    final matchingRequest = dashboardData?.data?.requests?.firstWhereOrNull(
      (r) => (r.job?.sId ?? '') == job.sId,
    );
    Get.toNamed(
      AppRoutes.counterOfferScreen,
      arguments: {'job': job, 'request': matchingRequest},
    );
  }

  void onDeclineJob(Jobs job) {
    newJobs.removeWhere((item) => item.sId == job.sId);
  }

  void onViewNewJobDetails(Jobs job) {
    Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
  }

  void _switchDashboardTab(int index) {
    final dashController = Get.find<DashboardController>();
    dashController.changeIndex(index: index);
  }

  // ── API CALLING ──────────────────────────────────────────────────────────────
  Future<void> refreshData() async {
    hitDashboardApi();
    hitJobsApi();
    hitMetricsApi();
    hitTodayScheduleApi();
  }

  void hitDashboardApi() async {
    try {
      isLoading.value = true;
      final value = await apiRepo.getTechnicianDashboardApi();
      dashboardData = value;

      if (value.success != true || value.data == null) return;

      final tech = value.data!.technician;
      userName.value = tech?.name ?? '';
      totalEarnings.value = '\$${tech?.totalEarnings ?? 0}';

      final requests = value.data!.requests ?? [];

      // Count pending requests
      final pendingRequests = requests
          .where((r) => r.status == 'pending')
          .length;
      newRequestsCount.value = pendingRequests;

      // Count accepted requests with jobs
      final acceptedRequests = requests
          .where((r) => r.status == 'accepted' && r.job != null)
          .toList();
      activeJobsCount.value = acceptedRequests.length;
      todayScheduleCount.value = acceptedRequests.length;

      // Store the actual Requests objects directly
      todaySchedule.value = acceptedRequests;
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hitJobsApi() async {
    try {
      final location = LocationService.to;
      final hasLocation =
          location.latitude.value != 0.0 && location.longitude.value != 0.0;
      final value = await apiRepo.getRecommendedJobsApi(
        recommended: recommendedSelected.value,
        distanceMiles: selectedDistanceMiles.value,
        latitude: hasLocation ? location.latitude.value : null,
        longitude: hasLocation ? location.longitude.value : null,
        serviceTypeIds: selectedServiceTypeIds.toList(),
      );
      jobsData = value;

      if (value.success != true || value.data == null) return;

      final jobs = value.data!.jobs ?? [];

      // Store the actual Jobs objects directly
      newJobs.value = jobs;
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  Future<void> hitServiceTypesApi() async {
    try {
      isServiceTypesLoading.value = true;
      final value = await apiRepo.getServiceTypesApi();
      if (value.success) {
        serviceTypes.value = value.serviceTypes
            .where((type) => type.isActive)
            .toList();
      }
    } catch (_) {
      // Filters remain usable even when the optional list cannot be loaded.
    } finally {
      isServiceTypesLoading.value = false;
    }
  }

  Future<void> setDistanceMiles(int miles) async {
    if (selectedDistanceMiles.value == miles) return;
    selectedDistanceMiles.value = miles;
    await hitJobsApi();
  }

  Future<void> resetDistanceMiles() async {
    if (selectedDistanceMiles.value == null) return;
    selectedDistanceMiles.value = null;
    await hitJobsApi();
  }

  Future<void> toggleRecommended() async {
    recommendedSelected.toggle();
    await hitJobsApi();
  }

  Future<void> toggleServiceType(String id) async {
    if (selectedServiceTypeIds.contains(id)) {
      selectedServiceTypeIds.remove(id);
    } else {
      selectedServiceTypeIds.add(id);
    }
    selectedServiceTypeIds.refresh();
    update();
  }

  void applyJobTypeFilter() async {
    await hitJobsApi();
    Get.back();
    Get.back();
  }

  Future<void> clearServiceTypes() async {
    if (selectedServiceTypeIds.isEmpty) return;
    selectedServiceTypeIds.clear();
    selectedServiceTypeIds.refresh();
    update();

    await hitJobsApi();
    Get.back();
  }

  /// GET /api/technician/jobs?filter=today
  /// Fetches today's scheduled jobs and populates [todayScheduledJobs].
  Future<void> hitTodayScheduleApi() async {
    try {
      isScheduleLoading.value = true;
      final result = await apiRepo.getScheduledJobsTodayApi();
      if (result.success == true) {
        todayScheduledJobs.value = result.data?.jobs ?? [];
        todayScheduleCount.value = todayScheduledJobs.length;
      }
    } catch (_) {
      // Schedule failure is non-critical — existing dashboard data remains
    } finally {
      isScheduleLoading.value = false;
    }
  }

  /// GET /api/technician/metrics
  void hitMetricsApi() async {
    try {
      final result = await apiRepo.getMetricsApi();
      if (result.success != true || result.data == null) return;

      final m = result.data!.metrics;
      totalEarnings.value = '\$${m.totalEarnings}';
      activeJob.value = m.activeJobs;
      todayJobCount.value = m.todaySchedule;
      requestCount.value = m.totalRequests;
    } catch (e) {
      // Metrics failure is non-critical — swallow silently
    }
  }

  @override
  void onClose() {
    SocketService.instance.off('job:new');
    SocketService.instance.off('job:updated');
    SocketService.instance.off('job:deleted');
    SocketService.instance.off('request:updated');
    SocketService.instance.off('request:status');
    super.onClose();
  }
}
