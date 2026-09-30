import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/empty_api_state.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import '../technician_home_controller.dart';

class NewJobsSection extends StatelessWidget {
  final TechnicianHomeController controller;

  const NewJobsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Job',
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
              GestureDetector(
                onTap: controller.onViewAllNewJobs,
                child: Text(
                  'View All',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => _FilterButton(
                    icon: Icons.star_border_rounded,
                    label: controller.recommendedSelected.value
                        ? 'Recommended Jobs'
                        : 'All Jobs',
                    selected: controller.recommendedSelected.value,
                    onTap: () => _showRecommendationFilter(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => _FilterButton(
                    icon: Icons.location_on_outlined,
                    label: controller.selectedDistanceMiles.value == null
                        ? 'Any distance'
                        : '${controller.selectedDistanceMiles.value} miles',
                    subtitle: 'Distance',
                    onTap: () => _showDistanceFilter(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => _FilterButton(
                    icon: Icons.business_center_outlined,
                    label: controller.selectedServiceTypeLabel,
                    onTap: () => _showServiceTypeFilter(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            if (controller.newJobs.isEmpty) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: EmptyApiState(
                  compact: true,
                  title: 'No New Jobs Found',
                  onRefresh: controller.hitJobsApi,
                ),
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < controller.newJobs.length; i++) ...[
                    _NewJobCard(
                      job: controller.newJobs[i],
                      controller: controller,
                    ),
                    if (i < controller.newJobs.length - 1)
                      const SizedBox(width: 12),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showDistanceFilter(BuildContext context) {
    const distances = [5, 10, 20, 30, 50];
    int? draftDistance = controller.selectedDistanceMiles.value;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Distance'),
                subtitle: Text('Choose a radius for recommended jobs'),
              ),
              ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: AppColor.brownAccentPrimary,
                ),
                title: const Text('Any distance'),
                trailing: draftDistance == null
                    ? const Icon(
                        Icons.check,
                        color: AppColor.brownAccentPrimary,
                      )
                    : null,
                onTap: () => setState(() => draftDistance = null),
              ),
              for (final distance in distances)
                RadioListTile<int>(
                  value: distance,
                  groupValue: draftDistance,
                  activeColor: AppColor.brownAccentPrimary,
                  title: Text('Within $distance miles'),
                  onChanged: (value) => setState(() => draftDistance = value),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => draftDistance = null),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (draftDistance == null) {
                            controller.resetDistanceMiles();
                          } else {
                            controller.setDistanceMiles(draftDistance!);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.brownAccentPrimary,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendationFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Job feed'),
                subtitle: Text('Choose which jobs to show'),
              ),
              RadioListTile<bool>(
                value: false,
                groupValue: controller.recommendedSelected.value,
                title: const Text('All Jobs'),
                activeColor: AppColor.brownAccentPrimary,
                onChanged: (value) {
                  if (value != null &&
                      value != controller.recommendedSelected.value) {
                    controller.toggleRecommended();
                  }
                  Navigator.pop(context);
                },
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: controller.recommendedSelected.value,
                title: const Text('Recommended Jobs'),
                activeColor: AppColor.brownAccentPrimary,
                onChanged: (value) {
                  if (value != null &&
                      value != controller.recommendedSelected.value) {
                    controller.toggleRecommended();
                  }
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceTypeFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => GetBuilder(
        init: controller,
        builder: (controller) {
          return SafeArea(
            child: Obx(
              () => SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Job Types'),
                      trailing: TextButton(
                        onPressed: controller.clearServiceTypes,
                        child: const Text('Clear'),
                      ),
                    ),
                    Expanded(
                      child: controller.isServiceTypesLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: controller.serviceTypes.length,
                              itemBuilder: (_, index) {
                                final type = controller.serviceTypes[index];
                                return CheckboxListTile(
                                  value: controller.selectedServiceTypeIds
                                      .contains(type.id),
                                  activeColor: AppColor.brownAccentPrimary,
                                  title: Text(type.name),
                                  onChanged: (_) =>
                                      controller.toggleServiceType(type.id),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.applyJobTypeFilter();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.brownAccentPrimary,
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColor.brownAccentPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3CBA7)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColor.brownAccentPrimary,
              size: 21,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected ? Colors.white70 : AppColor.darkGray,
                      ),
                    ),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColor.blackShade1,
                    ),
                  ),
                ],
              ),
            ),
            if (!selected)
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColor.brownAccentPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

class _NewJobCard extends StatelessWidget {
  final Jobs job;
  final TechnicianHomeController controller;

  const _NewJobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5B0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row with NEW badge ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.brownAccentPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title ?? 'Untitled Job',
                  style: AppTextStyle.titleMediumSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Location & category ─────────────────────────────────
          InfoRow(
            icon: Icons.location_on_outlined,
            text: '${job.location ?? 'No location'}',
          ),
          const SizedBox(height: 4),

          // ── Schedule time ────────────────────────────────────────
          InfoRow(
            icon: Icons.access_time_outlined,
            text: controller.jobController.scheduleTimeLabel(job),
          ),
          const SizedBox(height: 4),

          // ── Est. Pay amount ──────────────────────────────────────
          InfoRow(
            icon: Icons.credit_card_outlined,
            text: controller.jobController.estPayLabel(job),
            bold: true,
          ),

          // // ── Description ─────────────────────────────────────────
          // if (description.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   const Divider(height: 1, color: Color(0xFFF0E6D0)),
          //   const SizedBox(height: 10),
          //   Text(
          //     'Description',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Text(
          //     description,
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.blackShade1,
          //     ),
          //     maxLines: 3,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          // ],
          //
          // // ── Requirements ────────────────────────────────────────
          // if (requirements.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   Text(
          //     'Requirements',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Wrap(
          //     spacing: 6,
          //     runSpacing: 4,
          //     children: requirements.map((r) => _Chip(label: r)).toList(),
          //   ),
          // ],
          //
          // // ── Preferred Skills ────────────────────────────────────
          // if (preferredSkills.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   Text(
          //     'Preferred Skills',
          //     style: AppTextStyle.bodySmallMedium.copyWith(
          //       color: AppColor.coolGrayText,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 11,
          //     ),
          //   ),
          //   const SizedBox(height: 4),
          //   Wrap(
          //     spacing: 6,
          //     runSpacing: 4,
          //     children: preferredSkills
          //         .map((s) => _Chip(label: s, accent: true))
          //         .toList(),
          //   ),
          // ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0E6D0)),
          const SizedBox(height: 12),

          Obx(() {
            final isRequesting = controller.requestingJobIds.contains(
              job.sId ?? '',
            );
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isRequesting
                        ? null
                        : () => controller.onRequestJob(job),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.brownAccentPrimary,
                      side: const BorderSide(
                        color: AppColor.brownAccentPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Request Job',
                      style: AppTextStyle.buttonSmall.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRequesting
                        ? null
                        : () => controller.onCounterOffer(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.brownAccentPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      'Counter Offer',
                      style: AppTextStyle.buttonSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
          // ── Navigate button ─────────────────────────────────────
          // OutlinedButton.icon(
          //   onPressed: () => controller.onNavigateJobTapped(job),
          //   icon: const Icon(Icons.navigation_outlined, size: 16),
          //   label: const Text('NAVIGATE'),
          //   style: OutlinedButton.styleFrom(
          //     foregroundColor: AppColor.blackShade1,
          //     side: const BorderSide(color: Color(0xFFDDDDDD)),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     minimumSize: const Size(double.infinity, 42),
          //     textStyle: AppTextStyle.labelSmallMedium.copyWith(
          //       letterSpacing: 0.5,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.onViewNewJobDetails(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.brownAccentPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
              ),
              child: Text(
                'Click to view Details',
                style: AppTextStyle.buttonSmall.copyWith(
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

// ── Shared helpers ─────────────────────────────────────────────────────────────

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const InfoRow({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppColor.brownAccentPrimary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.bodySmallMedium.copyWith(
              color: AppColor.blackShade1,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
