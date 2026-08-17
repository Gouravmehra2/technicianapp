import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import '../technician_home_controller.dart';

class ScheduleSection extends StatelessWidget {
  final TechnicianHomeController controller;

  const ScheduleSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Schedule",
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAllSchedule,
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColor.brownAccentPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
          children: controller.todaySchedule
              .map((job) => _ScheduleJobCard(job: job, controller: controller))
              .toList(),
        )),
      ],
    );
  }
}

class _ScheduleJobCard extends StatelessWidget {
  final ScheduleJob job;
  final TechnicianHomeController controller;

  const _ScheduleJobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isInProgress = job.status == 'IN PROGRESS';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5B0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time + status row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.time,
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: AppColor.blackShade1,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      job.duration,
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: AppColor.coolGrayText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isInProgress ? const Color(0xFFF5EDD8) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isInProgress
                        ? AppColor.brownAccentPrimary
                        : AppColor.coolGrayText,
                    width: 1,
                  ),
                ),
                child: Text(
                  job.status,
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: isInProgress
                        ? AppColor.brownAccentPrimary
                        : AppColor.coolGrayText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              isInProgress
                  ? Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 5,
                        ).paddingOnly(left: 2, right: 2),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job.title,
            style: AppTextStyle.titleMediumSemiBold.copyWith(
              color: AppColor.blackShade1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Job ID: ${job.jobId} • ${job.distance}',
            style: AppTextStyle.bodySmallMedium.copyWith(
              color: AppColor.coolGrayText,
            ),
          ),
          const SizedBox(height: 12),
          // Navigate + Contact row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.onNavigateTapped(job),
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text('NAVIGATE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.blackShade1,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTextStyle.labelSmallMedium.copyWith(
                      letterSpacing: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.onContactSupportTapped(job),
                  icon: const Icon(Icons.headset_mic_outlined, size: 16),
                  label: const Text('CONTACT SUPPORT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.blackShade1,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: AppTextStyle.labelSmallMedium.copyWith(
                      letterSpacing: 0.5,
                      fontSize: 9,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // View Details button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.onViewDetailsTapped(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.brownAccentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: Text(
                'Click to view Details',
                style: AppTextStyle.buttonMedium.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
