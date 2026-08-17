import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';

enum JobStatus { inProgress, upcoming, completed }

class ScheduledJobModel {
  final String time;
  final String duration;
  final String title;
  final String jobId;
  final String distance;
  final JobStatus status;

  const ScheduledJobModel({
    required this.time,
    required this.duration,
    required this.title,
    required this.jobId,
    required this.distance,
    required this.status,
  });
}

enum ChecklistStep { reachLocation, confirmJob, completeService, testHandover, collectPayment }

class ScheduleJobController extends GetxController {
  final _api = Get.find<ApiRepo>();
  final selectedTab = 0.obs; // 0=Today, 1=Tomorrow, 2=Week

  final jobs = <ScheduledJobModel>[].obs;

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
  final pauseReasons = ['Waiting for Customer', 'Need Spare Parts', 'Lunch Break', 'Customer Requested Pause', 'Power / Water Issue', 'Safety Concern', 'Other'];
  final resumeTimes = ['30 mins', '1 hour', '2 hours', '6 hours', 'Tomorrow', 'Custom'];

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
    loadSchedule();
    _startTimer();
  }

  Future<void> loadSchedule() async {
    try {
      final dashboard = await _api.getTechnicianDashboardApi();
      if (dashboard.success == true) {
        final requests = dashboard.data?.requests ?? [];
        final accepted = requests.where((r) => r.status == 'accepted' && r.job != null);
        jobs.value = accepted.map((r) {
          final job = r.job!;
          return ScheduledJobModel(
            time: _formatDate(job.scheduledDate ?? job.serviceDate),
            duration: job.estimatedTime ?? '',
            title: job.title ?? '',
            jobId: '#${(job.sId ?? '').substring(0, 6)}',
            distance: job.location ?? '',
            status: job.status == 'in-progress'
                ? JobStatus.inProgress
                : job.status == 'completed'
                    ? JobStatus.completed
                    : JobStatus.upcoming,
          );
        }).toList();
      }
    } catch (_) {}
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value) elapsedSeconds.value++;
    });
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
    if (!completedSteps.contains(ChecklistStep.confirmJob)) return 'Confirm with Customer';
    if (!completedSteps.contains(ChecklistStep.completeService)) return 'Complete Service';
    if (!completedSteps.contains(ChecklistStep.testHandover)) return 'Testing Done';
    if (!completedSteps.contains(ChecklistStep.collectPayment)) return 'Collect Signature';
    return 'Confirmation Pending';
  }

  bool get allDone => completedSteps.length == ChecklistStep.values.length;

  void onActionTap() {
    if (!completedSteps.contains(ChecklistStep.reachLocation)) {
      toggleStep(ChecklistStep.reachLocation);
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
    toggleStep(ChecklistStep.collectPayment);
  }

  void navigateToJobDetails(ScheduledJobModel job) {
    Get.toNamed(AppRoutes.scheduleJobDetailScreen, arguments: job);
  }

  void navigateToNavigation(ScheduledJobModel job) {
    Get.toNamed(AppRoutes.scheduleJobNavigationScreen, arguments: job);
  }

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
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
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
            const Text('Verify Customer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            const Text('Please ask the customer for the\n4-digit OTP to continue.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 56, height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 3) _focusNodes[i + 1].requestFocus();
                  },
                ),
              )),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.controller.verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Verify & Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 14),
            RichText(text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Inter'),
              children: [
                const TextSpan(text: "Didn't receive an OTP? "),
                TextSpan(
                  text: 'Resend Code in ${_resendSeconds.toString().padLeft(2, '0')}:${0.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Color(0xFFA5732F), fontWeight: FontWeight.w600),
                ),
              ],
            )),
            const SizedBox(height: 6),
            const Text('OTP is VALID for next 10:00 min', style: TextStyle(color: Color(0xFFA5732F), fontSize: 13, fontWeight: FontWeight.w500)),
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
            const Text('Confirm Customer\nSignatures', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            const Text('Please ask the customer to sign below.', style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5732F)),
              ),
              child: const Center(
                child: Text('Jagriti', style: TextStyle(fontSize: 28, fontFamily: 'Cursive', color: Colors.black87)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Confirm & Complete', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
