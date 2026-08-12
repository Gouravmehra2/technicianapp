import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'job_detail_controller.dart';

class JobDetailScreen extends GetView<JobDetailController> {
  JobDetailScreen({super.key});

  @override
  final controller = Get.put(JobDetailController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Job Info Card ─────────────────────────────────────
                  _JobInfoCard(),
                  const SizedBox(height: 14),
                  // ── Stats Grid ────────────────────────────────────────
                  _StatsGrid(),
                  const SizedBox(height: 14),
                  // ── Destination Card ──────────────────────────────────
                  _DestinationCard(),
                  const SizedBox(height: 14),
                  // ── Arrival & Distance Card ───────────────────────────
                  _ArrivalCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ── Bottom Actions ────────────────────────────────────────────
          _BottomActions(controller: controller),
        ],
      ),
    );
  }
}

// ─── Job Info Card ────────────────────────────────────────────────────────────

class _JobInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tv_outlined, color: AppColor.brownAccentPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TV Mounting',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Job ID: #1024',
                    style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.brownAccentPrimary),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'IN PROGRESS',
                    style: AppTextStyle.labelSmallMedium.copyWith(
                      color: AppColor.brownAccentPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phone Button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.lightGreyColor),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_outlined, size: 18, color: AppColor.blackShade1),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.access_time_outlined,
                  value: '10:30 AM',
                  label: 'ETA',
                ),
              ),
              Container(width: 1, height: 50, color: AppColor.lightGreyColor),
              Expanded(
                child: _StatItem(
                  icon: Icons.timer_outlined,
                  value: '1.5 hrs',
                  label: 'Duration',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: AppColor.lightGreyColor),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.location_on_outlined,
                  value: '1.8 km',
                  label: 'Distance',
                ),
              ),
              Container(width: 1, height: 50, color: AppColor.lightGreyColor),
              Expanded(
                child: _StatItem(
                  icon: Icons.currency_rupee,
                  value: '\$650',
                  label: 'Est. Amount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColor.brownAccentPrimary),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyle.titleMediumSemiBold.copyWith(
              color: AppColor.blackShade1,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
        ],
      ),
    );
  }
}

// ─── Destination Card ────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESTINATION',
            style: AppTextStyle.labelSmallMedium.copyWith(
              color: AppColor.coolGrayText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'House No. 123, Sector 14',
                      style: AppTextStyle.titleSmallSemiBold.copyWith(
                        color: AppColor.blackShade1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Near City Mall, Sector 14',
                      style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.brownAccentPrimary),
                  ),
                  child: Text(
                    'Navigate',
                    style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Arrival Card ────────────────────────────────────────────────────────────

class _ArrivalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 14, color: AppColor.brownAccentPrimary),
                    const SizedBox(width: 4),
                    Text('Arrival', style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.coolGrayText)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '10:45 AM ',
                        style: AppTextStyle.titleMediumSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: '(8 min)',
                        style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColor.brownAccentPrimary.withValues(alpha: 0.3)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.social_distance_outlined, size: 14, color: AppColor.brownAccentPrimary),
                    const SizedBox(width: 4),
                    Text('Distance', style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.coolGrayText)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '4.2 km',
                  style: AppTextStyle.titleMediumSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final JobDetailController controller;
  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColor.lightGreyColor)),
      ),
      child: Column(
        children: [
          // Accept Job
          GestureDetector(
            onTap: controller.acceptJob,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.brownAccentPrimary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Accept Job',
                textAlign: TextAlign.center,
                style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Quote your own price
          GestureDetector(
            onTap: controller.quoteOwnPrice,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColor.brownAccentPrimary),
              ),
              child: Text(
                'Quote your own price',
                textAlign: TextAlign.center,
                style: AppTextStyle.buttonLarge.copyWith(color: AppColor.brownAccentPrimary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Call Support + Reject
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.callSupport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: AppColor.blackShade1),
                        const SizedBox(width: 6),
                        Text(
                          'Call Support',
                          style: AppTextStyle.buttonSmall.copyWith(color: AppColor.blackShade1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: controller.rejectJob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          'Reject job',
                          style: AppTextStyle.buttonSmall.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
