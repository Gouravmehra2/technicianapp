import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/gradient_background.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'technician_home_controller.dart';
import 'widgets/technician_header.dart';
import 'widgets/earnings_card.dart';
import 'widgets/overview_card.dart';
import 'widgets/schedule_section.dart';
import 'widgets/bonus_banner.dart';
import 'widgets/new_jobs_section.dart';

class TechnicianHomeScreen extends StatelessWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TechnicianHomeController>(
      init: TechnicianHomeController(),
      builder: (controller) {
        return MyScaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Gradient section (scrolls with content) ───────────
                GradientBackground(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 10),
                      TechnicianHeader(controller: controller),
                      const SizedBox(height: 20),
                      EarningsCard(controller: controller),
                      const SizedBox(height: 20),
                      OverviewCard(controller: controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Rest on white background ───────────────────────────
                const SizedBox(height: 8),
                ScheduleSection(controller: controller),
                const SizedBox(height: 16),
                const BonusBanner(),
                const SizedBox(height: 24),
                NewJobsSection(controller: controller),
                const SizedBox(height: 28),

                // ── Footer tagline ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 2,
                            color: AppColor.brownAccentPrimary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'HEY, GOURAV MEHRA!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Love Your\n',
                              style: AppTextStyle.displayHeroExtraBold.copyWith(
                                color: const Color(0xFFD0D0D0),
                                letterSpacing: -3,
                              ),
                            ),
                            TextSpan(
                              text: 'Living',
                              style: AppTextStyle.displayHeroExtraBold.copyWith(
                                color: AppColor.brownAccentPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Keep up Skilling,\nKeep Earning,\nKeep Growing!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.6,
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
