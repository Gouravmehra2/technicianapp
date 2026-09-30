import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/technician_home_controller.dart';

class JobDetailController extends GetxController {
  final _api = Get.find<ApiRepo>();

  /// The Jobs object passed as navigation argument.
  Jobs? get _passedJob => Get.arguments as Jobs?;

  final isLoading = true.obs;
  final Rxn<Jobs> _job = Rxn();
  final RxString distanceKm = 'N/A'.obs;

  Jobs? get job => _job.value;
  var technicianId;
  bool isRequestedByMe = false;
  Worker? _positionWorker;

  @override
  void onInit() {
    technicianId = AuthService.to.user.value?.user?.id;
    super.onInit();
    _positionWorker = ever(LocationSharingService.to.position, (_) {
      _calculateDistance(_job.value?.coordinates);
    });
    fetchJobDetail();
  }

  Future<void> fetchJobDetail() async {
    final jobId = _passedJob?.sId ?? '';
    if (jobId.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      final result = await _api.getJobDetailApi(jobId);

      isRequestedByMe =
          result.requestedBy?.any((element) => element == technicianId) ??
          false;

      // Map the API response into a Jobs object so the screen stays model-agnostic.
      _job.value = result;
      _calculateDistance(_job.value?.coordinates);
    } catch (e) {
      // Fall back to the argument passed when navigating.
      _job.value = _passedJob;
      _calculateDistance(_job.value?.coordinates);
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateDistance(Coordinates? coordinate) {
    if (coordinate?.lat == null || coordinate?.lng == null) return;
    try {
      final loc = LocationService.to;
      final live = LocationSharingService.to.position.value;
      final fresh =
          live != null && LocationSharingService.isUsable(live, DateTime.now());
      if (!fresh && loc.latitude.value == 0.0 && loc.longitude.value == 0.0)
        return;
      final meters = Geolocator.distanceBetween(
        fresh ? live.latitude : loc.latitude.value,
        fresh ? live.longitude : loc.longitude.value,
        coordinate!.lat!,
        coordinate.lng!,
      );
      print('-=-=-=>> ${meters}');

      final km = meters / 1000;
      distanceKm.value = km >= 1
          ? '${km.toStringAsFixed(1)} km'
          : '${meters.toStringAsFixed(0)} m';
    } catch (_) {}
  }

  @override
  void onClose() {
    _positionWorker?.dispose();
    super.onClose();
  }

  String formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$min $period';
    } catch (_) {
      return raw;
    }
  }

  /// Formats a date-time string to "MMM d, h:mm AM/PM".
  /// Falls back to the raw string if parsing fails.
  String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[dt.month - 1];
      final day = dt.day;
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$month $day, $hour:$min $period';
    } catch (_) {
      return raw;
    }
  }

  void startJob() {
    Get.toNamed(
      AppRoutes.scheduleJobNavigationScreen,
      arguments: ScheduledJobModel(
        title: job?.title ?? '',
        distance: '',
        duration: '',
        jobId: job?.sId ?? '',
        status: JobStatus.inProgress,
        time: '',
        lat: job?.coordinates?.lat ?? 0.0,
        lng: job?.coordinates?.lng ?? 0.0,
        rawJob: job,
        rawJobId: job?.sId ?? '',
      ),
    );
  }

  void quoteOwnPrice() {
    Get.toNamed(AppRoutes.counterOfferScreen, arguments: {'job': _passedJob});
  }

  void callSupport() {
    Get.toNamed(AppRoutes.supportScreen);
  }

  void rejectJob() => Get.back();

  Future<void> onRequestJob() async {
    var technicianHomeController = Get.put(TechnicianHomeController());
    await technicianHomeController.onRequestJob(_passedJob ?? Jobs());
    // Pop all screens until the root (dashboard) and switch to Jobs → Requested tab
    Get.until((route) => route.isFirst);
    Get.find<DashboardController>().changeIndex(index: 1);
    Get.find<JobController>().changeTab(JobTabType.requestedJob);
  }
}
