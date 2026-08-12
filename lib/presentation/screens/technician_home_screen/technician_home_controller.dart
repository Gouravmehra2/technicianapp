import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/earnings_screen/your_earnings_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJob {
  final String time;
  final String duration;
  final String title;
  final String jobId;
  final String distance;
  final String status; // 'IN PROGRESS' | 'UPCOMING'

  const ScheduleJob({
    required this.time,
    required this.duration,
    required this.title,
    required this.jobId,
    required this.distance,
    required this.status,
  });

  /// Convert to [ScheduledJobModel] for schedule screens that expect it.
  ScheduledJobModel toScheduledJobModel() {
    return ScheduledJobModel(
      time: time,
      duration: duration,
      title: title,
      jobId: jobId,
      distance: distance,
      status: status == 'IN PROGRESS' ? JobStatus.inProgress : JobStatus.upcoming,
    );
  }
}

class NewJob {
  final String title;
  final String distance;
  final String sector;
  final String requestedFor;
  final String estimatedPay;

  const NewJob({
    required this.title,
    required this.distance,
    required this.sector,
    required this.requestedFor,
    required this.estimatedPay,
  });
}

class TechnicianHomeController extends GetxController {
  final String userName = 'Gourav Mehra';
  final String totalEarnings = '\$2,450';
  final int newRequestsCount = 12;
  final int activeJobsCount = 5;
  final int todayScheduleCount = 8;
  final double rating = 4.8;

  final RxString selectedPeriod = 'This Week'.obs;

  final List<ScheduleJob> todaySchedule = const [
    ScheduleJob(
      time: '10:30 AM',
      duration: '1.5 hrs',
      title: 'TV Wall Mounting',
      jobId: '#1024',
      distance: '1.8 km',
      status: 'IN PROGRESS',
    ),
    ScheduleJob(
      time: '4:30 PM',
      duration: '12.5 hrs',
      title: 'AC Installation',
      jobId: '#1029',
      distance: '4.8 km',
      status: 'UPCOMING',
    ),
  ];

  final List<NewJob> newJobs = const [
    NewJob(
      title: 'AC Installation',
      distance: '2.6 km away',
      sector: 'Sector 14',
      requestedFor: 'Today, 2:00 PM',
      estimatedPay: '\$850',
    ),
    NewJob(
      title: 'TV Mounting',
      distance: '1.2 km away',
      sector: 'Sector 7',
      requestedFor: 'Today, 5:00 PM',
      estimatedPay: '\$450',
    ),
  ];

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  /// Reactive address from LocationService — updates header automatically.
  RxString get currentLocation => LocationService.to.confirmedAddress;

  // ── Earnings ────────────────────────────────────────────────────────────────

  void onEarningsTapped() {
    Get.to(() => const YourEarningsScreen());
  }

  // ── Location ─────────────────────────────────────────────────────────────────

  void onLocationTapped() {
    Get.toNamed(AppRoutes.selectLocationScreen);
  }

  // ── Notifications ────────────────────────────────────────────────────────────

  void onNotificationTapped() {
    Get.toNamed(AppRoutes.notificationScreen);
  }

  // ── Today's Schedule ─────────────────────────────────────────────────────────

  /// "View All" → switch to the Bookings tab (index 2) in the dashboard.
  void onViewAllSchedule() {
    _switchDashboardTab(2);
  }

  /// Navigate button on a schedule card → navigation screen for that job.
  void onNavigateTapped(ScheduleJob job) {
    Get.toNamed(
      AppRoutes.scheduleJobNavigationScreen,
      arguments: job.toScheduledJobModel(),
    );
  }

  /// Contact Support button on a schedule card → support screen.
  void onContactSupportTapped(ScheduleJob job) {
    Get.toNamed(AppRoutes.supportScreen);
  }

  /// "Click to view Details" on a schedule card → job detail screen.
  void onViewDetailsTapped(ScheduleJob job) {
    Get.toNamed(
      AppRoutes.scheduleJobDetailScreen,
      arguments: job.toScheduledJobModel(),
    );
  }

  // ── New Jobs ─────────────────────────────────────────────────────────────────

  /// "View details" header link on new jobs section → Bookings tab.
  void onViewAllNewJobs() {
    _switchDashboardTab(2);
  }

  /// Accept a new job — switch to Bookings tab to manage it.
  void onAcceptJob(NewJob job) {
    _switchDashboardTab(2);
  }

  /// Decline a new job (no navigation needed, just a placeholder).
  void onDeclineJob(NewJob job) {}

  /// "Click to view Details" on a new job card → job detail screen.
  void onViewNewJobDetails(NewJob job) {
    // Map new job data into a ScheduledJobModel for the detail screen.
    final model = ScheduledJobModel(
      time: job.requestedFor,
      duration: 'TBD',
      title: job.title,
      jobId: 'NEW',
      distance: job.distance,
      status: JobStatus.upcoming,
    );
    Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: model);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Switch the bottom-nav tab in the parent [DashboardController].
  void _switchDashboardTab(int index) {
    final dashController = Get.find<DashboardController>();
    dashController.changeIndex(index: index);
  }
}
