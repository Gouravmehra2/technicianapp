import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_controller.dart';
import '../technician_home_controller.dart';

class OverviewCard extends StatelessWidget {
  final TechnicianHomeController controller;

  const OverviewCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBF9660).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xffFDF3E7), width: 1),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: AppTextStyle.headlineLargeBold.copyWith(
                  color: Colors.white,
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          controller.selectedPeriod.value,
                          style: AppTextStyle.bodySmallMedium.copyWith(
                            color: AppColor.blackShade1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColor.blackShade1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Grid of 4 stats
          Obx(
            () => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              padding: EdgeInsets.zero,
              children: [
                _StatTile(
                  icon: Icons.folder_open_rounded,
                  value: '${controller.newJobs.length}',
                  label: 'New Jobs',
                  badge: '${controller.newJobs.length}',
                  onTap: () {
                    controller.dashboardController.changeIndex(index: 1);
                    controller.jobController.selectedTab.value =
                        JobTabType.newJobs;
                  },
                ),
                _StatTile(
                  icon: Icons.description_outlined,
                  value: '${controller.activeJob.value}',
                  label: 'Active Jobs',
                  onTap: () {
                    controller.dashboardController.changeIndex(index: 1);
                    controller.jobController.selectedTab.value =
                        JobTabType.activeJobs;
                  },
                ),
                _StatTile(
                  icon: Icons.calendar_today_outlined,
                  value: '${controller.todayJobCount.value}',
                  label: "Today's  Schedule",
                  onTap: () {
                    controller.dashboardController.changeIndex(index: 2);
                  },
                ),
                _StatTile(
                  icon: Icons.bar_chart_rounded,
                  value: '${controller.requestCount.value ?? 0}',
                  label: 'Requests',
                  onTap: () {
                    controller.dashboardController.changeIndex(index: 1);
                    controller.jobController.selectedTab.value =
                        JobTabType.requestedJob;
                    controller.jobController.api.getRequestedJobsApi();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColor.brownColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyle.headlineLargeBold.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
