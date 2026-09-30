import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/job_detail_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleJobDetailScreen extends StatelessWidget {
  ScheduleJobDetailScreen({super.key});

  final ScheduleJobDetailController controller = Get.put(ScheduleJobDetailController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: controller.pauseJob,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.brownAccentPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.pause, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Pause',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFA5732F)),
          );
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(controller: controller),
                    const SizedBox(height: 12),
                    _StatsCard(controller: controller),
                    const SizedBox(height: 12),
                    _ChecklistCard(controller: controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // ── Bottom slide / complete button ────────────────────────────
            Obx(() {
              if (!controller.allTasksDone) return const SizedBox.shrink();
              return _SlideToCompleteButton(
                isLoading: controller.isCompletingJob.value,
                onSlide: controller.completeJob,
              );
            }),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header card
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final ScheduleJobDetailController controller;
  const _HeaderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final job = controller.jobModel;
    final rawJob = job.rawJob;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.build_outlined,
                  color: Color(0xFFA5732F),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title.capitalizeFirst ?? job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    _SmallBadge(text: 'Job ID: ${job.jobId}'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IN PROGRESS',
                  style: TextStyle(
                    color: Color(0xFFA5732F),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timer row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _TimerChip(
                      icon: Icons.access_time_outlined,
                      label: 'Elapsed',
                      value: controller.elapsedTime,
                      valueColor: Colors.green,
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.shade200),
                  Expanded(
                    child: _TimerChip(
                      icon: Icons.timer_outlined,
                      label: 'Est. Duration',
                      value: rawJob?.estimatedTime != null
                          ? '${rawJob!.estimatedTime} hrs'
                          : '--',
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.shade200),
                  Expanded(
                    child: _TimerChip(
                      icon: Icons.location_on_outlined,
                      label: 'Distance',
                      value: _calcDistance(job.lat, job.lng),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          Obx(() {
            final done = controller.completedCount;
            final total = controller.totalCount;
            final pct = total > 0 ? done / total : 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Job Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$done / $total tasks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFFA5732F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFA5732F)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final ScheduleJobDetailController controller;
  const _StatsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final raw = controller.jobModel.rawJob;
    final pay = raw?.pay;

    String payLabel = '--';
    if (pay != null) {
      switch ((pay.type ?? '').toLowerCase()) {
        case 'hourly':
          final rate = pay.hourlyRate ?? 0;
          final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
          final max = pay.maxHours ?? 0;
          final hours = approx > 0 ? approx : max.toDouble();
          payLabel = hours > 0 && rate > 0
              ? 'Est. \$${(rate * hours).toStringAsFixed(0)}'
              : '\$$rate/hr';
          break;
        case 'perdevice':
        case 'per_device':
        case 'per-device':
          final rate = pay.perDeviceRate ?? 0;
          final devices = pay.maxDevices ?? 0;
          payLabel = devices > 0 && rate > 0
              ? 'Est. \$${rate * devices}'
              : '\$$rate/device';
          break;
        case 'blended':
          final fixed = pay.blendedFixedAmount ?? 0;
          payLabel = '\$$fixed+';
          break;
        default:
          final amt = pay.fixedAmount ?? 0;
          payLabel = amt > 0 ? '\$$amt fixed' : '--';
      }
    }

    return _Card(
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: raw?.location ?? 'N/A',
              iconColor: const Color(0xFFA5732F),
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          Expanded(
            child: _StatItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Est. Pay',
              value: payLabel,
              iconColor: const Color(0xFFA5732F),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checklist card  (dynamic, from API tasks)
// ─────────────────────────────────────────────────────────────────────────────

class _ChecklistCard extends StatelessWidget {
  final ScheduleJobDetailController controller;
  const _ChecklistCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = controller.tasks;
      if (tasks.isEmpty && !controller.isLoading.value) {
        return _Card(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No checklist tasks for this job.',
                style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
              ),
            ),
          ),
        );
      }

      // Group tasks by their group label
      final groups = <String, List<Tasks>>{};
      for (final t in tasks) {
        final g = t.group ?? 'General';
        groups.putIfAbsent(g, () => []).add(t);
      }

      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Job Checklist',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.completedCount} / ${controller.totalCount} Done',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            ...groups.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group label
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E8DC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: Color(0xFFA5732F),
                      ),
                    ),
                  ),
                  ...entry.value.map((task) {
                    final idx = tasks.indexOf(task);
                    return _TaskRow(
                      task: task,
                      taskIndex: idx,
                      controller: controller,
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single task row + expandable requirement inputs
// ─────────────────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final Tasks task;
  final int taskIndex;
  final ScheduleJobDetailController controller;

  const _TaskRow({
    required this.task,
    required this.taskIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final taskId = task.sId ?? '';
    final state = controller.stateFor(taskId);
    final unlocked = controller.isTaskUnlocked(taskIndex);
    final done = task.isDone == true;

    return Obx(() {
      final isDoneObs = state.isDone.value || done;
      final isActive = unlocked && !isDoneObs;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDoneObs
              ? const Color(0xFFF0FFF4)
              : isActive
              ? Colors.white
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDoneObs
                ? const Color(0xFF81C784)
                : isActive
                ? const Color(0xFFE8D5B0)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Task header row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step circle
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDoneObs
                          ? const Color(0xFF4CAF50)
                          : isActive
                          ? const Color(0xFFA5732F)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: isDoneObs
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Center(
                            child: Text(
                              '${taskIndex + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title ?? 'Task ${taskIndex + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: isDoneObs || isActive
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        if (!unlocked && !isDoneObs)
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'Complete previous task first',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        if ((task.requirementReason ?? '').isNotEmpty &&
                            isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Required: ${task.requirementReason}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFA5732F),
                                fontFamily: 'Inter',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isDoneObs)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 20),
                  if (!unlocked && !isDoneObs)
                    const Icon(Icons.lock_outline,
                        color: Colors.grey, size: 18),
                ],
              ),
            ),

            // ── Requirement inputs (only when active) ───────────────────
            if (isActive) ...[
              // Note input
              if (task.requiresNote == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _RequirementLabel(
                          icon: Icons.notes_outlined, label: 'Note'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: state.noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your note here…',
                          hintStyle: const TextStyle(
                              fontFamily: 'Inter', fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFA5732F)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // Image upload
              if (task.requiresImage == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _RequirementLabel(
                          icon: Icons.image_outlined,
                          label: 'Upload Image'),
                      const SizedBox(height: 6),
                      Obx(() => state.hasImage.value
                          ? Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF81C784)),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF4CAF50), size: 32),
                                    SizedBox(height: 4),
                                    Text(
                                      'Image selected',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _OutlineBtn(
                                    label: 'Camera',
                                    icon: Icons.camera_alt_outlined,
                                    onTap: () => controller
                                        .captureImage(taskId),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _OutlineBtn(
                                    label: 'Gallery',
                                    icon: Icons.photo_library_outlined,
                                    onTap: () =>
                                        controller.pickImage(taskId),
                                  ),
                                ),
                              ],
                            )),
                    ],
                  ),
                ),

              // Signature pad
              if (task.requiresSignature == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _RequirementLabel(
                              icon: Icons.draw_outlined,
                              label: 'Customer Signature'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              state.signatureController.clear();
                              state.hasSigned.value = false;
                            },
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFA5732F),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 150,
                          child: Signature(
                            controller: state.signatureController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      Obx(() => state.hasSigned.value
                          ? const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '✓ Signature captured',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Ask customer to sign above',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )),
                    ],
                  ),
                ),

              // Submit / Complete button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                child: Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting.value
                            ? null
                            : () => controller.completeTask(task),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5732F),
                          disabledBackgroundColor:
                              const Color(0xFFA5732F).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: state.isSubmitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '✓  Mark as Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                              ),
                      ),
                    )),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide-to-complete button
// ─────────────────────────────────────────────────────────────────────────────

class _SlideToCompleteButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSlide;

  const _SlideToCompleteButton({
    required this.isLoading,
    required this.onSlide,
  });

  @override
  State<_SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<_SlideToCompleteButton> {
  double _dragX = 0;
  static const double _trackWidth = double.infinity;
  static const double _thumbSize = 52.0;
  static const double _padding = 4.0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width - 32; // margin 16*2
    final maxDrag = screenW - _thumbSize - _padding * 2;
    final progress = (_dragX / maxDrag).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(30),
      ),
      child: widget.isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
            )
          : Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Fill indicator
                AnimatedContainer(
                  duration: Duration.zero,
                  width: _thumbSize + _padding * 2 + _dragX,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // Label
                Center(
                  child: Opacity(
                    opacity: (1 - progress).clamp(0.3, 1.0),
                    child: const Text(
                      '← Slide to Complete Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Draggable thumb
                Positioned(
                  left: _padding + _dragX,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (d) {
                      setState(() {
                        _dragX = (_dragX + d.delta.dx)
                            .clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_dragX >= maxDrag * 0.85) {
                        widget.onSlide();
                      }
                      setState(() => _dragX = 0);
                    },
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF1B5E20),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _Card({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0E6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFA5732F),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _TimerChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, color: Colors.grey, fontFamily: 'Inter'),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
              color: Colors.grey, fontFamily: 'Inter', fontSize: 11),
        ),
      ],
    );
  }
}

class _RequirementLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RequirementLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFA5732F)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFFA5732F),
          ),
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8D5B0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFA5732F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Distance helper
// ─────────────────────────────────────────────────────────────────────────────

String _calcDistance(double? jobLat, double? jobLng) {
  if (jobLat == null || jobLng == null) return 'N/A';
  try {
    final live = LocationSharingService.to.position.value;
    final fresh =
        live != null && LocationSharingService.isUsable(live, DateTime.now());
    final loc = LocationService.to;
    if (!fresh && loc.latitude.value == 0.0 && loc.longitude.value == 0.0) {
      return 'N/A';
    }
    final meters = Geolocator.distanceBetween(
      fresh ? live.latitude : loc.latitude.value,
      fresh ? live.longitude : loc.longitude.value,
      jobLat,
      jobLng,
    );
    final km = meters / 1000;
    return km >= 1
        ? '${km.toStringAsFixed(1)} km'
        : '${meters.toStringAsFixed(0)} m';
  } catch (_) {
    return 'N/A';
  }
}
