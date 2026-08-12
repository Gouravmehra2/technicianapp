import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobScreen extends GetView<ScheduleJobController> {
   ScheduleJobScreen({super.key});

  var controller = Get.put(ScheduleJobController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Schedules',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Working Hours: 8.5 hrs',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter')),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 2 / 6,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFA5732F)),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('2 / 6 Jobs Completed',
                      style: AppTextStyle.titleSmallSemiBold
                          .copyWith(color: AppColor.brownAccentPrimary, fontSize: 15)),
                ),
                const SizedBox(height: 14),
                _TabSelector(controller: controller),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: controller.jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _JobCard(job: controller.jobs[i], controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Selector ────────────────────────────────────────────────────────────

class _TabSelector extends StatelessWidget {
  final ScheduleJobController controller;
  const _TabSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    const tabs = ['Today', 'Tomorrow', 'Week'];
    return Obx(() => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = controller.selectedTab.value == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = i,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColor.brownAccentPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Text(tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.black87,
                            fontFamily: 'Inter')),
                  ),
                ),
              );
            }),
          ),
        ));
  }
}

// ─── Job Card ────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final ScheduledJobModel job;
  final ScheduleJobController controller;
  const _JobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isCompleted = job.status == JobStatus.completed;
    final isInProgress = job.status == JobStatus.inProgress;
    final cardColor = isCompleted
        ? const Color(0xFF1A1A1A)
        : isInProgress
            ? const Color(0xFFFFF8EE)
            : const Color(0xFFFAF0E6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCompleted
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFA5732F).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.time,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            color: isCompleted ? Colors.white : Colors.black)),
                    Text(job.duration,
                        style: TextStyle(
                            fontSize: 15,
                            color: isCompleted ? Colors.white60 : Colors.grey.shade600,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              _StatusBadge(status: job.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(job.title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: isCompleted ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text('Job ID: ${job.jobId} • ${job.distance}',
              style: TextStyle(
                  color: isCompleted ? Colors.white60 : Colors.grey.shade600,
                  fontFamily: 'Inter')),
          if (!isCompleted) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _OutlineBtn(
                        label: 'NAVIGATE',
                        icon: Icons.send,
                        onTap: () => controller.navigateToNavigation(job))),
                const SizedBox(width: 10),
                Expanded(
                    child: _OutlineBtn(
                        label: 'CONTACT SUPPORT',
                        icon: Icons.headset_mic_outlined,
                        onTap: () {})),
              ],
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => controller.navigateToJobDetails(job),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration:
                  BoxDecoration(color: const Color(0xFFA5732F), borderRadius: BorderRadius.circular(30)),
              child: const Text('Click to view Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final JobStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color textColor;

    switch (status) {
      case JobStatus.inProgress:
        label = 'IN PROGRESS';
        bg = const Color(0xFFFAF0E6);
        textColor = const Color(0xFFA5732F);
        break;
      case JobStatus.upcoming:
        label = 'UPCOMING';
        bg = Colors.white;
        textColor = Colors.black87;
        break;
      case JobStatus.completed:
        label = 'COMPLETED';
        bg = Colors.white;
        textColor = Colors.black87;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFamily: 'Inter',
              letterSpacing: 0.5)),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFA5732F)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}
