import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/earnings_screen/your_earnings_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

class TechnicianHomeController extends GetxController {
  final ApiRepo apiRepo = Get.find<ApiRepo>();

  // ── Reactive state ───────────────────────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxString totalEarnings = '\$0'.obs;
  final RxInt newRequestsCount = 0.obs;
  final RxInt activeJobsCount = 0.obs;
  final RxInt todayScheduleCount = 0.obs;
  final RxDouble rating = 0.0.obs;
  final RxBool isLoading = false.obs;

  final RxList<ScheduleJob> todaySchedule = <ScheduleJob>[].obs;
  final RxList<NewJob> newJobs = <NewJob>[].obs;

  final RxString selectedPeriod = 'This Week'.obs;

  DashboardModel? dashboardData;
  NewJobsModel? jobsData;

  @override
  void onInit() {
    super.onInit();
    hitDashboardApi();
    hitJobsApi();
    _listenToSocket();
  }

  /// Subscribe to real-time job/request socket events.
  void _listenToSocket() {
    final socket = SocketService.instance;
    socket.reconnectIfNeeded();

    // New job posted by admin → refresh jobs list
    socket.on('job:new', (data) {
      print('[Home] job:new → refreshing jobs');
      hitJobsApi();
    });

    // Job updated (status change, assignment, etc.)
    socket.on('job:updated', (data) {
      print('[Home] job:updated → refreshing dashboard & jobs');
      hitDashboardApi();
      hitJobsApi();
    });

    // Job deleted → remove from list
    socket.on('job:deleted', (data) {
      print('[Home] job:deleted → refreshing jobs');
      hitJobsApi();
    });

    // Request status changed (e.g. accepted, completed)
    socket.on('request:updated', (data) {
      print('[Home] request:updated → refreshing dashboard');
      hitDashboardApi();
    });

    // Request status pushed directly
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
      return '${dt.day}/${dt.month} $hour:$min $period';
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

  void onNavigateTapped(ScheduleJob job) {
    Get.toNamed(
      AppRoutes.scheduleJobNavigationScreen,
      arguments: job.toScheduledJobModel(),
    );
  }

  void onContactSupportTapped(ScheduleJob job) =>
      Get.toNamed(AppRoutes.supportScreen);

  void onViewDetailsTapped(ScheduleJob job) {
    Get.toNamed(
      AppRoutes.scheduleJobDetailScreen,
      arguments: job.toScheduledJobModel(),
    );
  }

  // ── New Jobs ──────────────────────────────────────────────────────────────────
  void onViewAllNewJobs() => _switchDashboardTab(2);

  void onAcceptJob(NewJob job) => _switchDashboardTab(2);

  void onCounterOffer(NewJob job) {
    final matchingRequest = dashboardData?.data?.requests?.firstWhereOrNull(
      (r) => (r.job?.sId ?? '') == job.id,
    );
    final jobWithRequest = NewJob(
      id: job.id,
      title: job.title,
      distance: job.distance,
      sector: job.sector,
      requestedFor: job.requestedFor,
      estimatedPay: job.estimatedPay,
      requestId: matchingRequest?.sId,
    );
    // Pass both the NewJob and the matching Requests object so the counter
    // offer screen can render the full conversation without an extra API call.
    Get.toNamed(
      AppRoutes.counterOfferScreen,
      arguments: {'job': jobWithRequest, 'request': matchingRequest},
    );
  }

  void onDeclineJob(NewJob job) {}

  void onViewNewJobDetails(NewJob job) {
    final model = ScheduledJobModel(
      time: job.requestedFor,
      duration: 'TBD',
      title: job.title,
      jobId: job.id,
      distance: job.distance,
      status: JobStatus.upcoming,
    );
    Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: model);
  }

  void _switchDashboardTab(int index) {
    final dashController = Get.find<DashboardController>();
    dashController.changeIndex(index: index);
  }

  //api calling
  Future<void> refreshData() async {
    hitDashboardApi();
    hitJobsApi();
  }

  void hitDashboardApi() async {
    try {
      isLoading.value = true;
      await apiRepo.getTechnicianDashboardApi().then((value) {
        dashboardData = value;
        if (value.success != true) return;
        final tech = value.data?.technician;
        userName.value = tech?.name ?? '';
        totalEarnings.value = '\$${tech?.totalEarnings ?? 0}';

        final requests = value.data?.requests ?? [];
        final accepted = requests
            .where((r) => r.status == 'accepted' && r.job != null)
            .toList();

        todaySchedule.value = accepted.map((r) {
          final job = r.job!;
          return ScheduleJob(
            time: _formatDate(job.scheduledDate ?? job.serviceDate),
            duration: job.estimatedTime ?? '',
            title: job.title ?? '',
            jobId: '#${(job.sId ?? '').substring(0, 6)}',
            distance: job.location ?? '',
            status: job.status == 'in-progress' ? 'IN PROGRESS' : 'UPCOMING',
          );
        }).toList();
        activeJobsCount.value = accepted.length;
        todayScheduleCount.value = accepted.length;
        newRequestsCount.value = requests
            .where((r) => r.status == 'pending')
            .length;
      });
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  void hitJobsApi() async {
    try {
      await apiRepo.getTechnicianJobsApi().then((value) {
        jobsData = value;
        if (value.success != true) return;
        newJobs.value = (value.data?.jobs ?? []).map((job) {
          return NewJob(
            id: job.sId ?? '',
            title: job.title ?? '',
            distance: job.location ?? '',
            sector: job.category ?? '',
            requestedFor: _formatDate(
              job.scheduledDate ?? job.serviceDate ?? job.deadline,
            ),
            estimatedPay: '\$${job.budget ?? 0}',
          );
        }).toList();      });
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
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
