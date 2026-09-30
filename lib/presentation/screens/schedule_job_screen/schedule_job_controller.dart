import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/map_launch_helper.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

enum JobStatus { inProgress, onTheWay, upcoming, completed }

class ScheduledJobModel {
  final String time;
  final String duration;
  final String title;
  final String jobId;
  final String distance;
  final JobStatus status;

  /// Raw MongoDB _id used for API calls (markReached, markCompleted).
  /// Optional so existing call sites that don't have it still compile.
  final String? rawJobId;
  final double? lat;
  final double? lng;

  /// Full raw Jobs object for displaying pay/schedule details on the card.
  final Jobs? rawJob;

  const ScheduledJobModel({
    required this.time,
    required this.duration,
    required this.title,
    required this.jobId,
    required this.distance,
    required this.status,
    this.rawJobId,
    this.lat,
    this.lng,
    this.rawJob,
  });

}

enum ChecklistStep {
  reachLocation,
  confirmJob,
  completeService,
  testHandover,
  collectPayment,
}

class ScheduleJobController extends GetxController {
  final _api = Get.find<ApiRepo>();
  final selectedTab = 0.obs; // 0=Today, 1=Tomorrow, 2=Week

  final jobs = <ScheduledJobModel>[].obs;
  final isLoading = false.obs;

  // ── Week date-range picker state ──────────────────────────────────────────
  final isDateRangeExpanded = true.obs;
  late final Rx<DateTime> weekStartDate;
  late final Rx<DateTime> weekEndDate;

  /// Apply the user-selected range and re-fetch.
  void applyDateRange() {
    loadSchedule();
  }

  /// Reset dates back to today → today+6 and re-fetch.
  void resetDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    weekStartDate.value = today;
    weekEndDate.value = today.add(const Duration(days: 6));
    loadSchedule();
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: weekStartDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFA5732F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      weekStartDate.value = picked;
      // Ensure end >= start
      if (weekEndDate.value.isBefore(picked)) {
        weekEndDate.value = picked.add(const Duration(days: 6));
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: weekEndDate.value,
      firstDate: weekStartDate.value,
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFA5732F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) weekEndDate.value = picked;
  }

  Future<void> pickCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: weekStartDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFA5732F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      weekStartDate.value = picked;
      weekEndDate.value = picked;
      loadSchedule();
    }
  }

  // Job in progress state
  final isPaused = false.obs;
  final elapsedSeconds = RxInt(504); // 00:08:24
  Timer? _timer;

  // Checklist
  final completedSteps = <ChecklistStep>{}.obs;

  // OTP
  final otpValues = List.generate(4, (_) => '').obs;

  // Pause
  final selectedPauseReason = Rxn<String>();
  final pauseNoteController = TextEditingController();
  final selectedResumeTime = '30 mins'.obs;
  final pauseReasons = [
    'Waiting for Customer',
    'Need Spare Parts',
    'Lunch Break',
    'Customer Requested Pause',
    'Power / Water Issue',
    'Safety Concern',
    'Other',
  ];
  final resumeTimes = [
    '30 mins',
    '1 hour',
    '2 hours',
    '6 hours',
    'Tomorrow',
    'Custom',
  ];

  // Cancel
  final selectedCancelReason = Rxn<String>();
  final cancelNoteController = TextEditingController();
  final cancelReasons = [
    'Customer not available / No response',
    'Customer requested to cancel',
    'Unable to reach location',
    'Wrong / Duplicate booking',
    'Required tools / Parts not available',
    'Safety / Security concern',
    'Other (Please specify)',
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialise week range to current Mon–Sun (or today → today+6)
    final now = DateTime.now();
    weekStartDate = DateTime(now.year, now.month, now.day).obs;
    weekEndDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 6)).obs;

    loadSchedule();
    _startTimer();
    // Re-fetch whenever the user switches tabs
    ever(selectedTab, (_) => loadSchedule());
  }

  /// Dispatches the correct API call based on the active tab:
  ///   0 = Today    → GET /jobs?filter=today
  ///   1 = Tomorrow → GET /jobs?filter=tomorrow
  ///   2 = Week     → GET /jobs?filter=custom&fromDate=<today>&toDate=<today+6>
  Future<void> loadSchedule() async {
    isLoading.value = true;
    try {
      NewJobsModel result;
      switch (selectedTab.value) {
        case 1: // Tomorrow
          result = await _api.getScheduledJobsTomorrowApi();
          break;
        case 2: // Week — use user-selected range
          result = await _api.getScheduledJobsWeekApi(
            fromDate: weekStartDate.value,
            toDate: weekEndDate.value,
          );
          break;
        default: // Today (tab 0)
          result = await _api.getScheduledJobsTodayApi();
          break;
      }

      if (result.success == true) {
        final jobList = result.data?.jobs ?? [];
        jobs.value = jobList.map((Jobs job) {
          final rawId = job.sId ?? '';
          // Use jobDate.from/to range for the time display; fall back to scheduledDate
          final time = () {
            final from = job.jobDate?.from ?? '';
            final to   = job.jobDate?.to   ?? '';
            if (from.isNotEmpty && to.isNotEmpty) {
              return '${_formatDate(from)} – ${_formatDate(to, timeOnly: true)}';
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
            rawJobId: rawId.isNotEmpty ? rawId : null,
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
        }).toList();
      }
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  String _formatDate(dynamic raw, {bool timeOnly = false}) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      if (timeOnly) return '$hour:$min $period';
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day}, $hour:$min $period';
    } catch (_) {
      return raw.toString();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value) elapsedSeconds.value++;
    });
  }

  /// Resets the elapsed timer to zero and restarts it.
  /// Called when the technician reaches the job location and the navigation
  /// screen hands off to the job detail screen.
  void resetAndStartElapsedTimer() {
    _timer?.cancel();
    elapsedSeconds.value = 0;
    isPaused.value = false;
    _startTimer();
  }

  String get elapsedTime {
    final h = elapsedSeconds.value ~/ 3600;
    final m = (elapsedSeconds.value % 3600) ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void toggleStep(ChecklistStep step) {
    if (completedSteps.contains(step)) {
      completedSteps.remove(step);
    } else {
      completedSteps.add(step);
    }
  }

  bool isStepCompleted(ChecklistStep step) => completedSteps.contains(step);

  int get completedCount => completedSteps.length;

  String get currentActionLabel {
    if (!completedSteps.contains(ChecklistStep.reachLocation)) return 'Reached';
    if (!completedSteps.contains(ChecklistStep.confirmJob))
      return 'Confirm with Customer';
    if (!completedSteps.contains(ChecklistStep.completeService))
      return 'Complete Service';
    if (!completedSteps.contains(ChecklistStep.testHandover))
      return 'Testing Done';
    if (!completedSteps.contains(ChecklistStep.collectPayment))
      return 'Collect Signature';
    return 'Confirmation Pending';
  }

  bool get allDone => completedSteps.length == ChecklistStep.values.length;

  void onActionTap() {
    if (!completedSteps.contains(ChecklistStep.reachLocation)) {
      _markReached();
    } else if (!completedSteps.contains(ChecklistStep.confirmJob)) {
      _showOtpDialog();
    } else if (!completedSteps.contains(ChecklistStep.completeService)) {
      toggleStep(ChecklistStep.completeService);
    } else if (!completedSteps.contains(ChecklistStep.testHandover)) {
      toggleStep(ChecklistStep.testHandover);
    } else if (!completedSteps.contains(ChecklistStep.collectPayment)) {
      _showSignatureDialog();
    }
  }

  // ── PATCH /api/technician/jobs/:jobId/reached ─────────────────────────────
  Future<void> _markReached() async {
    final jobId = _activeJobId;
    if (jobId == null || jobId.isEmpty) {
      toggleStep(ChecklistStep.reachLocation);
      return;
    }
    try {
      final result = await _api.markReachedApi(jobId, lat: 0, lng: 0);
      if (result.success) {
        toggleStep(ChecklistStep.reachLocation);
        AppSnackbar.success(
          result.message ?? 'Location reached recorded.',
          title: 'Reached',
        );
        await loadSchedule();
      } else {
        AppSnackbar.error(
          result.message ?? 'Failed to record location reached.',
          title: 'Error',
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ── PATCH /api/technician/jobs/:jobId/complete ────────────────────────────
  Future<void> markJobCompleted() async {
    final jobId = _activeJobId;
    if (jobId == null || jobId.isEmpty) {
      // Toggle locally and navigate — no live job available
      toggleStep(ChecklistStep.collectPayment);
      goToCompletedJob();
      return;
    }
    try {
      final result = await _api.markCompletedApi(jobId);
      if (result.success) {
        await LocationSharingService.to.stopForJob(jobId);
        toggleStep(ChecklistStep.collectPayment);
        AppSnackbar.success(
          result.message ?? 'Job marked as completed.',
          title: 'Completed',
        );
        await loadSchedule();
        goToCompletedJob();
      } else {
        AppSnackbar.error(
          result.message ?? 'Failed to mark job as completed.',
          title: 'Error',
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  /// Returns the raw job _id for the currently inprogress (or first active) job.
  String? get _activeJobId {
    final inProgress = jobs.firstWhereOrNull(
      (j) => j.status == JobStatus.inProgress,
    );
    if (inProgress != null) return inProgress.rawJobId;
    // Fall back to first upcoming job if none is inprogress yet
    return jobs.firstOrNull?.rawJobId;
  }

  void _showOtpDialog() {
    Get.dialog(_OtpDialog(controller: this), barrierDismissible: false);
  }

  void verifyOtp() {
    Get.back();
    toggleStep(ChecklistStep.confirmJob);
  }

  void _showSignatureDialog() {
    Get.dialog(_SignatureDialog(controller: this), barrierDismissible: false);
  }

  void confirmSignature() {
    Get.back();
    markJobCompleted();
  }

  void navigateToJobDetails(ScheduledJobModel job) {
    Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: job);
  }

  void navigateToNavigation(ScheduledJobModel job) {
    Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: job);
  }

  /// Opens Google Maps navigation to the job location.
  // void navigateJob(ScheduledJobModel job) {
  //   if (job.lat != null && job.lng != null) {
  //     MapLaunchHelper.navigateTo(lat: job.lat!, lng: job.lng!);
  //   } else {
  //     Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: job);
  //   }
  // }

  void pauseJob() {
    isPaused.value = true;
    Get.toNamed(AppRoutes.scheduleJobPauseScreen);
  }

  void resumeJob() {
    isPaused.value = false;
    Get.back();
  }

  void cancelJob() {
    Get.toNamed(AppRoutes.scheduleJobCancelScreen);
  }

  void submitCancellation() {
    Get.toNamed(AppRoutes.scheduleJobCancelledScreen);
  }

  void goToCompletedJob() {
    Get.toNamed(AppRoutes.scheduleJobCompletedScreen);
  }

  void goToNextJob() {
    Get.until((r) => r.settings.name == AppRoutes.dashboardScreen);
  }

  @override
  void onClose() {
    _timer?.cancel();
    pauseNoteController.dispose();
    cancelNoteController.dispose();
    super.onClose();
  }
}

// OTP Dialog
class _OtpDialog extends StatefulWidget {
  final ScheduleJobController controller;

  const _OtpDialog({required this.controller});

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _resendSeconds = 21;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Verify Customer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please ask the customer for the\n4-digit OTP to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3)
                        _focusNodes[i + 1].requestFocus();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.controller.verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Verify & Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
                children: [
                  const TextSpan(text: "Didn't receive an OTP? "),
                  TextSpan(
                    text:
                        'Resend Code in ${_resendSeconds.toString().padLeft(2, '0')}:${0.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Color(0xFFA5732F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'OTP is VALID for next 10:00 min',
              style: TextStyle(
                color: Color(0xFFA5732F),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Signature Dialog
class _SignatureDialog extends StatelessWidget {
  final ScheduleJobController controller;

  const _SignatureDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm Customer\nSignatures',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please ask the customer to sign below.',
              style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5732F)),
              ),
              child: const Center(
                child: Text(
                  'Jagriti',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Cursive',
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.confirmSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA5732F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm & Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
