import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

// ─── Per-task UI state ────────────────────────────────────────────────────────

class TaskUiState {
  final isSubmitting = false.obs;
  final isDone = false.obs;
  final noteController = TextEditingController();
  XFile? pickedImage;
  final hasImage = false.obs;
  final signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final hasSigned = false.obs;

  void dispose() {
    noteController.dispose();
    signatureController.dispose();
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ScheduleJobDetailController extends GetxController {
  final _api = Get.find<ApiRepo>();

  // Passed in via Get.arguments
  late final ScheduledJobModel jobModel;

  // Full job fetched from API
  final job = Rxn<Jobs>();
  final isLoading = true.obs;
  final isCompletingJob = false.obs;

  // Per-task state map  key = task._id
  final taskStates = <String, TaskUiState>{};

  // Elapsed timer (mirrors ScheduleJobController)
  final elapsedSeconds = 0.obs;
  Timer? _timer;

  // ── Computed helpers ─────────────────────────────────────────────────────

  List<Tasks> get tasks => job.value?.tasks ?? [];

  int get completedCount => tasks.where((t) => t.isDone == true).length;
  int get totalCount => tasks.length;

  bool get allTasksDone =>
      totalCount > 0 && tasks.every((t) => t.isDone == true);

  /// Index of the first incomplete task (linear order).
  int get activeTaskIndex {
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].isDone != true) return i;
    }
    return tasks.length; // all done
  }

  bool isTaskUnlocked(int index) => index <= activeTaskIndex;

  TaskUiState stateFor(String taskId) {
    return taskStates.putIfAbsent(taskId, () {
      final s = TaskUiState();
      s.signatureController.addListener(() {
        if (s.signatureController.isNotEmpty) s.hasSigned.value = true;
      });
      return s;
    });
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    jobModel = Get.arguments as ScheduledJobModel;
    _startTimer();
    fetchJobDetail();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  String get elapsedTime {
    final h = elapsedSeconds.value ~/ 3600;
    final m = (elapsedSeconds.value % 3600) ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Fetch job detail ──────────────────────────────────────────────────────

  Future<void> fetchJobDetail() async {
    final jobId = jobModel.rawJobId ?? jobModel.jobId;
    if (jobId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final fetched = await _api.getJobDetailApi(jobId);
      job.value = fetched;
      // Pre-populate isDone from API
      for (final t in fetched.tasks ?? <Tasks>[]) {
        if (t.sId != null) {
          final s = stateFor(t.sId!);
          s.isDone.value = t.isDone == true;
        }
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Load Error');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pick image ────────────────────────────────────────────────────────────

  Future<void> pickImage(String taskId) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      final s = stateFor(taskId);
      s.pickedImage = file;
      s.hasImage.value = true;
    }
  }

  Future<void> captureImage(String taskId) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) {
      final s = stateFor(taskId);
      s.pickedImage = file;
      s.hasImage.value = true;
    }
  }

  // ── Complete a single task ────────────────────────────────────────────────

  Future<void> completeTask(Tasks task) async {
    final taskId = task.sId;
    if (taskId == null || taskId.isEmpty) return;
    final jobId = jobModel.rawJobId ?? jobModel.jobId;
    if (jobId.isEmpty) return;

    // The API uses the task's order/index in the URL, not its _id.
    // Use task.order first; fall back to its position in the tasks list.
    final taskIndex = task.order ?? tasks.indexOf(task);

    final s = stateFor(taskId);
    if (s.isSubmitting.value) return;

    // Validate required fields before hitting the API
    if (task.requiresNote == true && s.noteController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter a note before completing this task.',
          title: 'Note Required');
      return;
    }
    if (task.requiresImage == true && !s.hasImage.value) {
      AppSnackbar.error('Please upload an image before completing this task.',
          title: 'Image Required');
      return;
    }
    if (task.requiresSignature == true && !s.hasSigned.value) {
      AppSnackbar.error(
          'Please collect a signature before completing this task.',
          title: 'Signature Required');
      return;
    }

    s.isSubmitting.value = true;
    try {
      // Get current GPS position for the payload
      double? lat, lng;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        final live = LocationSharingService.to.position.value;
        if (live != null &&
            LocationSharingService.isUsable(live, DateTime.now())) {
          lat = live.latitude;
          lng = live.longitude;
        }
      }

      // Export signature as binary PNG bytes (not base64)
      Uint8List? sigBytes;
      if (task.requiresSignature == true && s.hasSigned.value) {
        sigBytes =
            await s.signatureController.toPngBytes(height: 200, width: 600);
      }

      await _api.completeTaskApi(
        jobId: jobId,
        taskIndex: taskIndex,
        completionNote: task.requiresNote == true
            ? s.noteController.text.trim()
            : null,
        imagePath: (task.requiresImage == true && s.pickedImage != null)
            ? s.pickedImage!.path
            : null,
        signatureBytes: sigBytes,
        lat: lat,
        lng: lng,
      );

      // Optimistically mark done in local state
      s.isDone.value = true;
      task.isDone = true;
      job.refresh();

      AppSnackbar.success('Task completed!', title: 'Done');
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Task Error');
    } finally {
      s.isSubmitting.value = false;
    }
  }

  // ── Complete the whole job (slide button) ─────────────────────────────────

  Future<void> completeJob() async {
    final jobId = jobModel.rawJobId ?? jobModel.jobId;
    if (jobId.isEmpty) return;
    if (isCompletingJob.value) return;

    isCompletingJob.value = true;
    try {
      // Get current location
      double lat = 0, lng = 0;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // Use last known location from sharing service
        final live = LocationSharingService.to.position.value;
        if (live != null &&
            LocationSharingService.isUsable(live, DateTime.now())) {
          lat = live.latitude;
          lng = live.longitude;
        }
      }

      final result = await _api.completeJobApi(jobId, lat: lat, lng: lng);

      if (result.success) {
        // Stop location sharing for this job
        try {
          await LocationSharingService.to.stopForJob(jobId);
        } catch (_) {}

        AppSnackbar.success(
          result.message ?? 'Job completed successfully!',
          title: 'Completed',
        );

        // Navigate to completed screen, replacing history so back goes to home
        Get.offNamed(
          AppRoutes.scheduleJobCompletedScreen,
          arguments: {'job': jobModel, 'fetchedJob': job.value},
        );
      } else {
        AppSnackbar.error(
          result.message ?? 'Failed to complete job.',
          title: 'Error',
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isCompletingJob.value = false;
    }
  }

  // ── Pause ─────────────────────────────────────────────────────────────────

  void pauseJob() {
    try {
      Get.find<ScheduleJobController>().pauseJob();
    } catch (_) {
      Get.toNamed(AppRoutes.scheduleJobPauseScreen);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final s in taskStates.values) {
      s.dispose();
    }
    super.onClose();
  }
}
