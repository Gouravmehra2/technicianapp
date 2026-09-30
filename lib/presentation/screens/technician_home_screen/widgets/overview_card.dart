import 'dart:io';

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
          GetBuilder(
            init: controller,
            builder: (controller) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Each tile width = (total width - one gap) / 2
                  final tileWidth = (constraints.maxWidth - 10) / 2;
                  // Height scales with width using a responsive ratio,
                  // clamped so it never overflows on small screens.
                  final tileHeight = (tileWidth / 1.3).clamp(80.0, 130.0);

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: tileWidth / tileHeight,
                    padding: EdgeInsets.zero,
                    children: [
                      _StatTile(
                        icon: Icons.folder_open_rounded,
                        value: '${controller.newJobs.length}',
                        label: 'New Jobs',
                        badge: '${controller.newJobs.length}',
                        tileHeight: tileHeight,
                        onTap: () => controller.openJobsTab(JobTabType.newJobs),
                      ),
                      _StatTile(
                        icon: Icons.description_outlined,
                        value: '${controller.activeJob.value}',
                        label: 'Active Jobs',
                        tileHeight: tileHeight,
                        onTap: () => controller.openJobsTab(JobTabType.activeJobs),
                      ),
                      _StatTile(
                        icon: Icons.calendar_today_outlined,
                        value: '${controller.todayJobCount.value}',
                        label: "Today's Schedule",
                        tileHeight: tileHeight,
                        onTap: controller.openScheduleTab,
                      ),
                      _StatTile(
                        icon: Icons.bar_chart_rounded,
                        value: '${controller.requestCount.value ?? 0}',
                        label: 'Requests',
                        tileHeight: tileHeight,
                        onTap: () =>
                            controller.openJobsTab(JobTabType.requestedJob),
                      ),
                    ],
                  );
                },
              );
            },
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
  final double tileHeight;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    required this.tileHeight,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    // Scale font sizes and icon proportionally to tile height.
    // Base design targets a tile height of ~100px.
    final scale = (tileHeight / 100).clamp(0.75, 1.2);
    final valueFontSize = (20 * scale).clamp(14.0, 22.0);
    final labelFontSize = (13 * scale).clamp(10.0, 15.0);
    final iconSize = (20 * scale).clamp(16.0, 24.0);
    final iconPadding = (8 * scale).clamp(5.0, 8.0);
    final verticalGap = (8 * scale).clamp(4.0, 10.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.only(top: Platform.isAndroid ? 5.0:0.0),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColor.brownColor, size: iconSize),
            ),
            SizedBox(height: verticalGap),
            Text(
              value,
              style: AppTextStyle.headlineLargeBold.copyWith(
                color: Colors.white,
                fontSize: valueFontSize,
              ),
            ),
            SizedBox(height: verticalGap * 0.3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: Colors.white,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
