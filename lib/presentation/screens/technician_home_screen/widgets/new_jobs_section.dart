import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import '../technician_home_controller.dart';

class NewJobsSection extends StatelessWidget {
  final TechnicianHomeController controller;

  const NewJobsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Job',
                style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
              ),
              GestureDetector(
                onTap: controller.onViewAllNewJobs,
                child: Text(
                  'View details',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < controller.newJobs.length; i++) ...[
                  _NewJobCard(
                    job: controller.newJobs[i],
                    controller: controller,
                  ),
                  if (i < controller.newJobs.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewJobCard extends StatelessWidget {
  final NewJob job;
  final TechnicianHomeController controller;

  const _NewJobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5B0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with NEW badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tv_outlined, color: AppColor.brownAccentPrimary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title,
                  style: AppTextStyle.titleMediumSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          _InfoRow(icon: Icons.location_on_outlined, text: '${job.distance} • ${job.sector}'),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.access_time_outlined, text: 'Requested for: ${job.requestedFor}'),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Est. ${job.estimatedPay}',
            bold: true,
          ),
          const SizedBox(height: 12),
          // Decline / Accept row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.onDeclineJob(job),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.brownAccentPrimary,
                    side: const BorderSide(color: AppColor.brownAccentPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Decline', style: AppTextStyle.buttonSmall.copyWith(color: AppColor.brownAccentPrimary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.onAcceptJob(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.brownAccentPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Text('Accept', style: AppTextStyle.buttonSmall.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () => controller.onViewNewJobDetails(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.brownAccentPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _InfoRow({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColor.brownAccentPrimary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyle.bodySmallMedium.copyWith(
            color: AppColor.blackShade1,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
