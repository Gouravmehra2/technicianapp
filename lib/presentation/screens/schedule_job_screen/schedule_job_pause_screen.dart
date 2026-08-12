import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobPauseScreen extends GetView<ScheduleJobController> {
  const ScheduleJobPauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle), child: const Icon(Icons.chevron_left, color: Colors.black87)),
        ),
        title: const Text('Job Pause', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [IconButton(icon: const Icon(Icons.support_agent_outlined, color: Colors.black87), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: Color(0xFFFAF0E6), shape: BoxShape.circle),
                  child: const Icon(Icons.pause, color: Color(0xFFA5732F), size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Job is Paused', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                const SizedBox(height: 8),
                const Text('Take your time. The job timer is currently\npaused. Please select a reason below.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
              ]),
            ),
            const SizedBox(height: 28),
            const Text('Select Valid Reason', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: controller.pauseReasons.map((reason) {
                final selected = controller.selectedPauseReason.value == reason;
                return GestureDetector(
                  onTap: () => controller.selectedPauseReason.value = reason,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Icon(_reasonIcon(reason), size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(child: Text(reason, style: const TextStyle(fontFamily: 'Inter', fontSize: 15))),
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColor.brownAccentPrimary : Colors.transparent,
                          border: Border.all(color: selected ? AppColor.brownAccentPrimary : Colors.grey.shade400),
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 20),
            const Text('Add Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: controller.pauseNoteController,
                maxLines: 4,
                maxLength: 250,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  hintText: 'Add notes...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Estimated Resume Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Obx(() => Wrap(
              spacing: 8, runSpacing: 8,
              children: controller.resumeTimes.map((t) {
                final selected = controller.selectedResumeTime.value == t;
                return GestureDetector(
                  onTap: () => controller.selectedResumeTime.value = t,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFAF0E6) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: selected ? Border.all(color: const Color(0xFFA5732F)) : null,
                    ),
                    child: Text(t, style: TextStyle(color: selected ? const Color(0xFFA5732F) : Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 20),
            const Text('Take Photo (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5732F).withValues(alpha: 0.5), style: BorderStyle.solid),
                ),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.camera_alt_outlined, color: Color(0xFFA5732F), size: 28),
                  SizedBox(height: 6),
                  Text('Add Photo', style: TextStyle(color: Color(0xFFA5732F), fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (controller.selectedPauseReason.value != null) {
                  Get.offNamed(AppRoutes.scheduleJobPauseDetailsScreen);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: const Color(0xFFA5732F), borderRadius: BorderRadius.circular(30)),
                child: const Text('Pause Job', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _reasonIcon(String reason) {
    if (reason.contains('Customer')) return Icons.person_outline;
    if (reason.contains('Spare')) return Icons.build_outlined;
    if (reason.contains('Lunch')) return Icons.coffee_outlined;
    if (reason.contains('Power')) return Icons.bolt_outlined;
    if (reason.contains('Safety')) return Icons.shield_outlined;
    return Icons.more_horiz;
  }
}

class ScheduleJobPauseDetailsScreen extends GetView<ScheduleJobController> {
  const ScheduleJobPauseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle), child: const Icon(Icons.chevron_left, color: Colors.black87)),
        ),
        title: const Text('Job Pause Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [IconButton(icon: const Icon(Icons.support_agent_outlined, color: Colors.black87), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: Color(0xFFFAF0E6), shape: BoxShape.circle),
                  child: const Icon(Icons.pause, color: Color(0xFFA5732F), size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Job is Paused', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
              ]),
            ),
            const SizedBox(height: 28),
            // Reason row
            Obx(() => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.build_outlined, color: Color(0xFFA5732F), size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Reason', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(controller.selectedPauseReason.value ?? 'Need Spare Parts', style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFA5732F))),
                  child: const Text('Change', style: TextStyle(color: Color(0xFFA5732F), fontWeight: FontWeight.w600)),
                ),
              ]),
            )),
            const SizedBox(height: 20),
            const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text(controller.pauseNoteController.text.isEmpty ? 'Need a longer HDMI cable and wall plugs. Will get it from the nearby store.' : controller.pauseNoteController.text,
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.black87)),
            ),
            const SizedBox(height: 20),
            const Text('Estimated Resume Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Obx(() => Wrap(
              spacing: 8, runSpacing: 8,
              children: controller.resumeTimes.map((t) {
                final selected = controller.selectedResumeTime.value == t;
                return GestureDetector(
                  onTap: () => controller.selectedResumeTime.value = t,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFAF0E6) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: selected ? Border.all(color: const Color(0xFFA5732F)) : null,
                    ),
                    child: Text(t, style: TextStyle(color: selected ? const Color(0xFFA5732F) : Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  ),
                );
              }).toList(),
            )),
            const Spacer(),
            GestureDetector(
              onTap: controller.resumeJob,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: const Color(0xFFA5732F), borderRadius: BorderRadius.circular(30)),
                child: const Text('Resume Job', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: controller.cancelJob,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFA5732F))),
                child: const Text('Cancel Job', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA5732F), fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
