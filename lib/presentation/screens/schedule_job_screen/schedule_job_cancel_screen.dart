import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobCancelScreen extends GetView<ScheduleJobController> {
  const ScheduleJobCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
        title: const Text('Canceling Job',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, fontFamily: 'Inter', color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.support_agent_outlined, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFFAF0E6), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.tv_outlined, color: Color(0xFFA5732F), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TV Wall Mounting',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                _SmallBadge(label: 'Job ID: #1024', color: Color(0xFFFAF0E6), textColor: Color(0xFFA5732F)),
                                SizedBox(width: 8),
                                _SmallBadge(label: 'IN PROGRESS', color: Color(0xFFFAF0E6), textColor: Color(0xFFA5732F)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _InfoRow(icon: Icons.access_time_outlined, label: 'Started At', value: '10:55 AM'),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: 'House No. 123, Sector 14'),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.person_outline, label: 'Customer', value: 'Rohit Sharma'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Warning banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5732F).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFA5732F), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Canceling this job?',
                            style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter', fontSize: 14)),
                        SizedBox(height: 4),
                        Text(
                          'Please let us know the reason for cancellation. This helps us improve our service.',
                          style: TextStyle(color: Colors.black87, fontFamily: 'Inter', fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Why are you canceling this job?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: controller.cancelReasons.map((reason) {
                final selected = controller.selectedCancelReason.value == reason;
                return GestureDetector(
                  onTap: () => controller.selectedCancelReason.value = reason,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? const Color(0xFFA5732F) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(children: [
                      Icon(_cancelReasonIcon(reason), size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(reason,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 14))),
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? const Color(0xFFA5732F) : Colors.transparent,
                          border: Border.all(
                              color: selected ? const Color(0xFFA5732F) : Colors.grey.shade400),
                        ),
                        child: selected
                            ? const Icon(Icons.circle, size: 10, color: Colors.white)
                            : null,
                      ),
                    ]),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 20),
            const Text('Tell us Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: controller.cancelNoteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  hintText: 'Describe the issue...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: controller.submitCancellation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFA5732F), borderRadius: BorderRadius.circular(30)),
                child: const Text('Submit Cancelation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: Get.back,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300)),
                child: const Text('Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _cancelReasonIcon(String reason) {
    if (reason.contains('Customer not available')) return Icons.person_off_outlined;
    if (reason.contains('requested to cancel')) return Icons.cancel_outlined;
    if (reason.contains('reach location')) return Icons.location_off_outlined;
    if (reason.contains('Duplicate')) return Icons.content_copy_outlined;
    if (reason.contains('tools')) return Icons.build_outlined;
    if (reason.contains('Safety')) return Icons.shield_outlined;
    return Icons.more_horiz;
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _SmallBadge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 11, fontFamily: 'Inter')),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Inter', color: Colors.black)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.black87)),
      ],
    );
  }
}
