import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/map_launch_helper.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/earnings_screen/your_earnings_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

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

  /// Today's scheduled jobs fetched directly from GET /api/technician/jobs?filter=today
  final RxList<Jobs> todayScheduledJobs = <Jobs>[].obs;
  final RxBool isScheduleLoading = false.obs;

  final RxString selectedPeriod = 'This Week'.obs;

  DashboardModel? dashboardData;
  NewJobsModel? jobsData;

  @override
  void onInit() {
    super.onInit();
    hitDashboardApi();
    hitJobsApi();
    hitMetricsApi();
    hitTodayScheduleApi();
    _listenToSocket();
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
  void onNavigateJobTapped(Jobs job) {
    final lat = job.coordinates?.lat;
    final lng = job.coordinates?.lng;
    if (lat != null && lng != null) {
      MapLaunchHelper.navigateTo(lat: lat, lng: lng);
    } else {
      Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: job);
    }
  }

  /// Contact support for a [Jobs] item.
  void onContactSupportJobTapped(Jobs job) =>
      Get.toNamed(AppRoutes.supportScreen);

  /// View details for a [Jobs] item (from today-schedule API).
  void onViewDetailsJobTapped(Jobs job) =>
      Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);

  // ── New Jobs ──────────────────────────────────────────────────────────────────
  void onViewAllNewJobs() => _switchDashboardTab(1); // Jobs screen

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

  void onDeclineJob(Jobs job) {}

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

  void hitJobsApi() async {
    try {
      final value = await apiRepo.getTechnicianJobsApi();
      jobsData = value;

      if (value.success != true || value.data == null) return;

      final jobs = value.data!.jobs ?? [];

      // Store the actual Jobs objects directly
      newJobs.value = jobs;
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
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
