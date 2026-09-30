import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/dio_exception_handler/dio_exception_handler.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/service_type_model.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum JobTabType {
  newJobs,
  activeJobs,
  completedJobs,
  checkoutJobs,
  requestedJob,
}

// ─── Controller ───────────────────────────────────────────────────────────────

class JobController extends GetxController {
  final api = Get.find<ApiRepo>();

  final selectedTab = JobTabType.newJobs.obs;
  final Map<JobTabType, RxString> searchQueries = {
    for (final tab in JobTabType.values) tab: ''.obs,
  };
  final Map<JobTabType, TextEditingController> searchControllers = {
    for (final tab in JobTabType.values) tab: TextEditingController(),
  };
  final isLoading = false.obs;

  final recommendedSelected = false.obs;
  final selectedDistanceMiles = RxnInt();
  final serviceTypes = <ServiceType>[].obs;
  final selectedServiceTypeIds = <String>{}.obs;
  final isServiceTypesLoading = false.obs;

  String get selectedServiceTypeLabel {
    final names = serviceTypes
        .where((type) => selectedServiceTypeIds.contains(type.id))
        .map((type) => type.name)
        .toList();
    if (names.isEmpty) return 'All Job Types';
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }

  bool get hasAppliedJobFilters =>
      recommendedSelected.value ||
      selectedDistanceMiles.value != null ||
      selectedServiceTypeIds.isNotEmpty;

  final newJobs = <Jobs>[].obs;
  final activeJobs = <Jobs>[].obs;
  final completedJobs = <Jobs>[].obs;
  final checkoutJobs = <Jobs>[].obs;
  final requestedJobs = <Jobs>[].obs;

  // Tracks which job IDs are currently being requested (shows per-card loading)
  final requestingJobIds = <String>{}.obs;

  // ── Tab the current tab is "Requested" ────────────────────────────────────
  bool get isRequestedTab => selectedTab.value == JobTabType.requestedJob;

  TextEditingController get currentSearchController =>
      searchControllers[selectedTab.value]!;

  @override
  void onInit() {
    super.onInit();
    loadTab(selectedTab.value);
    loadServiceTypes();
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  Future<void> _showError(Object e) async {
    String message;
    if (e is DioException) {
      final apiEx = await DioExceptionHandler.handle(e);
      message = apiEx.message;
    } else {
      message = e.toString();
    }
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
    );
  }

  // ── Load all tabs ─────────────────────────────────────────────────────────

  Future<void> loadJobs() => loadTab(selectedTab.value);

  Future<void> loadTab(JobTabType type) async {
    isLoading.value = true;
    try {
      final result = switch (type) {
        JobTabType.newJobs => await api.getRecommendedJobsApi(
          recommended: recommendedSelected.value,
          distanceMiles: selectedDistanceMiles.value,
          latitude: _hasLocation ? LocationService.to.latitude.value : null,
          longitude: _hasLocation ? LocationService.to.longitude.value : null,
          serviceTypeIds: selectedServiceTypeIds.toList(),
        ),
        JobTabType.activeJobs => await api.getActiveJobsApi(
          distanceMiles: selectedDistanceMiles.value,
          latitude: _hasLocation ? LocationService.to.latitude.value : null,
          longitude: _hasLocation ? LocationService.to.longitude.value : null,
          serviceTypeIds: selectedServiceTypeIds.toList(),
        ),
        JobTabType.completedJobs => await api.getCompletedJobsApi(),
        JobTabType.checkoutJobs => await api.getCheckoutJobsApi(),
        JobTabType.requestedJob => await api.getRequestedJobsApi(),
      };

      if (result.success != true) return;
      final jobs = result.data?.jobs ?? [];
      switch (type) {
        case JobTabType.newJobs:
          newJobs.value = jobs;
          break;
        case JobTabType.activeJobs:
          activeJobs.value = jobs;
          break;
        case JobTabType.completedJobs:
          completedJobs.value = jobs;
          break;
        case JobTabType.checkoutJobs:
          checkoutJobs.value = jobs;
          break;
        case JobTabType.requestedJob:
          requestedJobs.value = jobs;
          break;
      }
    } catch (e) {
      await _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  bool get _hasLocation {
    final location = LocationService.to;
    return location.latitude.value != 0.0 && location.longitude.value != 0.0;
  }

  Future<void> loadServiceTypes() async {
    try {
      isServiceTypesLoading.value = true;
      final result = await api.getServiceTypesApi();
      if (result.success) {
        serviceTypes.value = result.serviceTypes
            .where((type) => type.isActive)
            .toList();
      }
    } catch (_) {
      // The job list remains usable when optional filter data is unavailable.
    } finally {
      isServiceTypesLoading.value = false;
    }
  }

  Future<void> toggleRecommended() async {
    recommendedSelected.toggle();
    await loadTab(selectedTab.value);
  }

  Future<void> setDistanceMiles(int miles) async {
    selectedDistanceMiles.value = miles;
    await loadTab(selectedTab.value);
  }

  Future<void> resetDistanceMiles() async {
    selectedDistanceMiles.value = null;
    await loadTab(selectedTab.value);
  }

  Future<void> toggleServiceType(String id) async {
    if (selectedServiceTypeIds.contains(id)) {
      selectedServiceTypeIds.remove(id);
    } else {
      selectedServiceTypeIds.add(id);
    }
    selectedServiceTypeIds.refresh();
    await loadTab(selectedTab.value);
  }

  Future<void> clearServiceTypes() async {
    if (selectedServiceTypeIds.isEmpty) return;
    selectedServiceTypeIds.clear();
    selectedServiceTypeIds.refresh();
    await loadTab(selectedTab.value);
  }

  // ── Computed list for current tab ─────────────────────────────────────────

  List<Jobs> get currentJobs {
    final q = searchQueries[selectedTab.value]!.value.toLowerCase();
    final List<Jobs> list = switch (selectedTab.value) {
      JobTabType.newJobs => newJobs,
      JobTabType.activeJobs => activeJobs,
      JobTabType.completedJobs => completedJobs,
      JobTabType.checkoutJobs => checkoutJobs,
      JobTabType.requestedJob => requestedJobs,
    };
    if (q.isEmpty) return list;
    return list
        .where(
          (j) =>
              (j.title ?? '').toLowerCase().contains(q) ||
              (j.serviceType?.name ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Tab switching ─────────────────────────────────────────────────────────

  Future<void> changeTab(JobTabType type, {bool reload = false}) async {
    if (selectedTab.value == type && !reload) return;
    selectedTab.value = type;
    await loadTab(type);
  }

  // ── Helpers: derive display values from Jobs ──────────────────────────────

  String priceLabel(Jobs job) {
    final price = (job.finalPrice != null && (job.finalPrice ?? 0) > 0)
        ? job.finalPrice
        : job.budget;
    return '\$${price ?? 0}';
  }

  String formattedDate(Jobs job) {
    // 1️⃣ jobDate range takes priority
    final from = job.jobDate?.from ?? '';
    final to = job.jobDate?.to ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      return '${_fmtIso(from)} – ${_fmtTimeOnly(to)}';
    }
    if (from.isNotEmpty) return _fmtIso(from);

    // 2️⃣ fall back to scalar date fields
    final raw = job.scheduledDate ?? job.serviceDate ?? job.jobStartedAt ?? '';
    if (raw.isEmpty) return '';
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

  /// True when job is complete but payment hasn't been requested yet.
  bool showRequestPayment(Jobs job) =>
      job.jobCompletedAt != null && (job.status ?? '') != 'completed';

  // ── Pay helpers ───────────────────────────────────────────────────────────

  /// Human-readable pay type label (e.g. "Hourly", "Blended", "Per Device").
  String payTypeLabel(Jobs job) {
    switch ((job.pay?.type ?? '').toLowerCase()) {
      case 'hourly':
        return 'Hourly';
      case 'blended':
        return 'Blended';
      case 'perdevice':
      case 'per_device':
      case 'per-device':
        return 'Per Device';
      case 'fixed':
        return 'Fixed';
      default:
        return job.pay?.type?.isNotEmpty == true ? job.pay!.type! : 'Fixed';
    }
  }

  /// Detailed budget string driven by pay type.
  /// e.g. "$75/hr • Max 4 hrs", "$50 fixed", "$20/device • Max 5 devices",
  /// "$100 + $30/hr (2 fixed hrs, max 3 addl)"
  String payDetailLabel(Jobs job) {
    final pay = job.pay;
    if (pay == null) return priceLabel(job);

    switch ((pay.type ?? '').toLowerCase()) {
      case 'hourly':
        final rate = pay.hourlyRate ?? 0;
        final max = pay.maxHours ?? 0;
        final approx = pay.approxHours ?? '';
        if (max > 0) {
          return '\$$rate/hr • Max ${max}h';
        } else if (approx.isNotEmpty) {
          return '\$$rate/hr • ~$approx';
        }
        return '\$$rate/hr';

      case 'perdevice':
      case 'per_device':
      case 'per-device':
        final rate = pay.perDeviceRate ?? 0;
        final max = pay.maxDevices ?? 0;
        if (max > 0) return '\$$rate/device • Max $max devices';
        return '\$$rate/device';

      case 'blended':
        final fixed = pay.blendedFixedAmount ?? 0;
        final fixedHrs = pay.blendedFixedHours ?? 0;
        final addlRate = pay.blendedHourlyRate ?? 0;
        final maxAddl = pay.blendedMaxAddlHours ?? 0;
        final sb = StringBuffer('\$$fixed for ${fixedHrs}h');
        if (addlRate > 0) {
          sb.write(' + \$$addlRate/hr');
          if (maxAddl > 0) sb.write(' (max ${maxAddl}h addl)');
        }
        return sb.toString();

      case 'fixed':
      default:
        final amount = pay.fixedAmount ?? 0;
        if (amount > 0) return '\$$amount fixed';
        return priceLabel(job);
    }
  }

  // ── Schedule helpers ──────────────────────────────────────────────────────

  /// Formats jobDate { from, to } as "Sep 10, 1:53 PM – 3:53 PM".
  /// Returns null when jobDate is absent or both fields are empty.
  String? jobDateTimeLabel(Jobs job) {
    final from = job.jobDate?.from ?? '';
    final to = job.jobDate?.to ?? '';
    if (from.isEmpty && to.isEmpty) return null;
    if (from.isNotEmpty && to.isNotEmpty) {
      return '${_fmtIso(from)} – ${_fmtTimeOnly(to)}';
    }
    return from.isNotEmpty ? _fmtIso(from) : _fmtIso(to);
  }

  /// Estimated total pay based on pay type:
  ///   hourly   → rate × approxHours (or maxHours), e.g. "Est. \$200"
  ///   fixed    → "\$<fixedAmount>"
  ///   blended  → "\$<blendedFixedAmount> + extras"
  ///   perdevice→ "\$<rate> × <maxDevices>"
  String estPayLabel(Jobs job) {
    final pay = job.pay;
    if (pay == null) return priceLabel(job);

    switch ((pay.type ?? '').toLowerCase()) {
      case 'hourly':
        final rate = pay.hourlyRate ?? 0;
        final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
        final max = pay.maxHours ?? 0;
        final hours = approx > 0 ? approx : max.toDouble();
        if (hours > 0 && rate > 0) {
          final total = (rate * hours).toStringAsFixed(0);
          return 'Est. \$$total';
        }
        return '\$$rate/hr';

      case 'perdevice':
      case 'per_device':
      case 'per-device':
        final rate = pay.perDeviceRate ?? 0;
        final devices = pay.maxDevices ?? 0;
        if (devices > 0 && rate > 0) return 'Est. \$${rate * devices}';
        return '\$$rate/device';

      case 'blended':
        final fixed = pay.blendedFixedAmount ?? 0;
        final addlRate = pay.blendedHourlyRate ?? 0;
        final maxAddl = pay.blendedMaxAddlHours ?? 0;
        if (addlRate > 0 && maxAddl > 0) {
          return 'Est. \$${fixed + addlRate * maxAddl}';
        }
        return '\$$fixed';

      case 'fixed':
      default:
        final amount = pay.fixedAmount ?? 0;
        return amount > 0 ? '\$$amount' : priceLabel(job);
    }
  }

  /// Human-readable schedule label. Prefers jobDate.from/to, then falls
  /// back to schedule type, then scheduledDate.
  String scheduleTimeLabel(Jobs job) {
    // 1️⃣ jobDate from/to (primary source from API)
    final jobDateLabel = jobDateTimeLabel(job);
    if (jobDateLabel != null) return jobDateLabel;

    // 2️⃣ legacy schedule object
    final s = job.schedule;
    if (s == null) return formattedDate(job);

    switch ((s.type ?? '').toLowerCase()) {
      case 'hardstart':
      case 'hard_start':
      case 'hard-start':
        final t = s.hardStartTime ?? '';
        return t.isNotEmpty ? 'Start: ${_fmtTime(t)}' : formattedDate(job);

      case 'betweenhours':
      case 'between_hours':
      case 'between-hours':
        final from = s.betweenTimeFrom ?? '';
        final to = s.betweenTimeTo ?? '';
        final dateFrom = s.betweenDateFrom;
        final dateTo = s.betweenDateTo;
        final datePart = _formatDateRange(dateFrom, dateTo);
        if (from.isNotEmpty && to.isNotEmpty) {
          return '$datePart • ${_fmtTime(from)} – ${_fmtTime(to)}';
        }
        return datePart.isNotEmpty ? datePart : formattedDate(job);

      case 'arriveby':
      case 'arrive_by':
      case 'arrive-by':
        final before = s.arriveBeforeTime ?? '';
        return before.isNotEmpty
            ? 'Arrive by: ${_fmtTime(before)}'
            : formattedDate(job);

      case 'arriveafter':
      case 'arrive_after':
      case 'arrive-after':
        final after = s.arriveAfterTime ?? '';
        return after.isNotEmpty
            ? 'Arrive after: ${_fmtTime(after)}'
            : formattedDate(job);

      default:
        return formattedDate(job);
    }
  }

  /// Formats an ISO datetime string → "MMM d, h:mm AM/PM" (e.g. "Sep 10, 1:53 PM").
  String _fmtIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
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
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '${months[dt.month - 1]} ${dt.day}, $h:$m $p';
    } catch (_) {
      return iso;
    }
  }

  /// Formats an ISO datetime string to time only → "h:mm AM/PM" (for the "to" part of a range).
  String _fmtTimeOnly(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $p';
    } catch (_) {
      return iso;
    }
  }

  /// Formats "HH:mm" → "h:mm AM/PM".
  String _fmtTime(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts.length > 1 ? parts[1] : '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '$h12:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return hhmm;
    }
  }

  /// Formats an ISO date range to "Sep 8 – Sep 10".
  String _formatDateRange(String? from, String? to) {
    if (from == null && to == null) return '';
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
    String fmtIso(String iso) {
      try {
        final dt = DateTime.parse(iso).toLocal();
        return '${months[dt.month - 1]} ${dt.day}';
      } catch (_) {
        return iso;
      }
    }

    if (from != null && to != null) return '${fmtIso(from)} – ${fmtIso(to)}';
    if (from != null) return fmtIso(from);
    return fmtIso(to!);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void onSearch(String q) => searchQueries[selectedTab.value]!.value = q;

  void openFilterScreen() => Get.toNamed(AppRoutes.jobFilterScreen);

  /// POST /api/technician/jobs/:id/request — then switches to Requested tab.
  Future<void> requestJob(Jobs job) async {
    final jobId = job.sId ?? '';
    if (jobId.isEmpty || requestingJobIds.contains(jobId)) return;
    requestingJobIds.add(jobId);
    try {
      await api.requestJobApi(jobId: jobId);
      newJobs.removeWhere((j) => j.sId == jobId);
      navigateToRequestedJobs();
    } catch (e) {
      await _showError(e);
    } finally {
      requestingJobIds.remove(jobId);
    }
  }

  /// Switch the bottom nav to the Jobs screen and animate to "Requested Jobs".
  void navigateToRequestedJobs() {
    Get.find<DashboardController>().changeIndex(index: 1);
    changeTab(JobTabType.requestedJob);
  }

  /// "Counter Offer" button — navigates to the counter offer screen.
  /// Always passes the Jobs object directly; CounterOfferController reads
  /// assignedRequest from it to load the existing conversation.
  void counterOffer(Jobs job) {
    Get.toNamed(AppRoutes.counterOfferScreen, arguments: {'job': job});
  }

  void viewJobDetails(Jobs job) {
    final status = (job.status ?? '').toLowerCase();
    if (status == 'ontheway') {
      final from = job.jobDate?.from ?? '';
      final to = job.jobDate?.to ?? '';
      final time = from.isNotEmpty && to.isNotEmpty
          ? '${_fmtIso(from)} – ${_fmtTimeOnly(to)}'
          : from.isNotEmpty
          ? _fmtIso(from)
          : formattedDate(job);
      Get.toNamed(
        AppRoutes.scheduleJobNavigationScreen,
        arguments: ScheduledJobModel(
          time: time,
          duration: job.estimatedTime ?? '',
          title: job.title ?? '',
          jobId: job.sId ?? '',
          distance: job.location ?? '',
          rawJobId: job.sId,
          lat: job.coordinates?.lat,
          lng: job.coordinates?.lng,
          rawJob: job,
          status: JobStatus.onTheWay,
        ),
      );
      return;
    } else if (status == 'inprogress') {
      final model = _buildScheduledJobModel(job);
      Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: model);
    } else {
      Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
    }
  }

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

  /// Opens Google Maps navigation to the job location.
  // void navigateToJob(Jobs job) {
  //   final lat = job.coordinates?.lat;
  //   final lng = job.coordinates?.lng;
  //   if (lat != null && lng != null) {
  //     MapLaunchHelper.navigateTo(lat: lat, lng: lng);
  //   } else {
  //     Get.snackbar(
  //       'Navigation',
  //       'No location coordinates available for this job.',
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   }
  // }

  void acceptAtSame(Jobs job) {
    Get.toNamed(AppRoutes.jobDetailScreen, arguments: job);
  }

  void requestPayment(Jobs job) {
    // Navigate to payment screen
  }

  /// Shows a confirmation dialog then calls the cancel-request API.
  /// On success, refreshes the Requested Jobs tab.
  Future<void> cancelRequest(Jobs job) async {
    final requestId = job.requestId;
    if (requestId == null || requestId.isEmpty) {
      Get.snackbar(
        'Error',
        'No request ID found for this job.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: const Text(
            'Cancel Request',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this job request? This action cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.back(result: false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColor.brownAccentPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                'Keep Request',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColor.brownAccentPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      final response = await api.cancelJobRequestApi(requestId: requestId);
      final body = response.data as Map<String, dynamic>;

      if (body['success'] == true) {
        Get.snackbar(
          'Cancelled',
          body['message'] as String? ?? 'Job request cancelled successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
        // Refresh the Requested Jobs tab
        final result = await api.getRequestedJobsApi();
        if (result.success == true) {
          requestedJobs.value = result.data?.jobs ?? [];
        }
      } else {
        Get.snackbar(
          'Error',
          body['message'] as String? ?? 'Failed to cancel request.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      await _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Location sharing ──────────────────────────────────────────────────────
  // NOTE: Location is no longer started here for all active jobs.
  // It is started exclusively in NavigationController.startNavigation()
  // for the single job the technician chooses to navigate to.

  @override
  void onClose() {
    for (final searchController in searchControllers.values) {
      searchController.dispose();
    }
    super.onClose();
  }
}
