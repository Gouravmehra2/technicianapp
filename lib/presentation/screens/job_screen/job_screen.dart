import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'job_controller.dart';

class JobScreen extends GetView<JobController> {
  JobScreen({super.key});

  @override
  final controller = Get.put(JobController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Next Schedule Banner ──────────────────────────────────────────
          _NextScheduleBanner(),
          // ── Search + Filter ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearch,
                      style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: AppColor.coolGrayText, size: 20),
                        hintText: 'Search for job or service',
                        hintStyle: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText),
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.openFilterScreen,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // ── Tab Bar ───────────────────────────────────────────────────────
          _JobTabBar(controller: controller),
          const SizedBox(height: 4),
          // ── Job List ──────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final isNewTab = controller.selectedTab.value == JobTabType.newJobs;
              final jobs = controller.currentJobs;

              if (jobs.isEmpty) {
                return Center(
                  child: Text('No jobs found', style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText)),
                );
              }

              // For New Jobs tab: show recommended stacked card + "New Job List" + rest
              if (isNewTab && jobs.isNotEmpty) {
                final recommendedJob = jobs.first;
                final listJobs = jobs.length > 1 ? jobs.sublist(1) : <JobModel>[];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // Recommended Job stacked section
                    _RecommendedJobSection(
                      job: recommendedJob,
                      extraCount: listJobs.length,
                      controller: controller,
                    ),
                    const SizedBox(height: 20),
                    // New Job List header
                    if (listJobs.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Job List',
                            style: AppTextStyle.titleMediumSemiBold.copyWith(
                              color: AppColor.blackShade1,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {/* See all */},
                            child: Row(
                              children: [
                                Text(
                                  'See all',
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.brownAccentPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right, size: 18, color: AppColor.brownAccentPrimary),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...listJobs.asMap().entries.map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: e.key < listJobs.length - 1 ? 12 : 0),
                          child: _JobCard(job: e.value, controller: controller),
                        ),
                      ),
                    ],
                  ],
                );
              }

              // Active / Completed tabs: plain list
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: jobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _JobCard(job: jobs[i], controller: controller),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Next Schedule Banner ────────────────────────────────────────────────────

class _NextScheduleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(top: top + 8, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.brownAccentPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Schedule in:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  '2h 45m',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'TV Wall Mounting • 4:30 PM',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Recommended Job Stacked Section ─────────────────────────────────────────

class _RecommendedJobSection extends StatelessWidget {
  final JobModel job;
  final int extraCount;
  final JobController controller;

  const _RecommendedJobSection({
    required this.job,
    required this.extraCount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // How many ghost cards to show behind (max 2)
    final ghostCount = extraCount.clamp(0, 2);
    // Total height is card + ghost peeks
    const cardRadius = 20.0;
    const peekOffset = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "Recommended Job" + "See all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended Job',
              style: AppTextStyle.titleMediumSemiBold.copyWith(
                color: AppColor.blackShade1,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: () {/* See all */},
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: AppTextStyle.bodySmallMedium.copyWith(
                      color: AppColor.brownAccentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 18, color: AppColor.brownAccentPrimary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Stacked cards
        SizedBox(
          // Extra bottom space so ghost cards are visible
          height: _estimatedCardHeight + (ghostCount * peekOffset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Ghost card 2 (furthest back)
              if (ghostCount >= 2)
                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: _estimatedCardHeight,
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                  ),
                ),
              // Ghost card 1
              if (ghostCount >= 1)
                Positioned(
                  bottom: ghostCount >= 2 ? peekOffset : 0,
                  left: 6,
                  right: 6,
                  child: Container(
                    height: _estimatedCardHeight,
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                  ),
                ),
              // Front card (full detail)
              Positioned(
                bottom: ghostCount >= 2
                    ? peekOffset * 2
                    : ghostCount == 1
                        ? peekOffset
                        : 0,
                left: 0,
                right: 0,
                child: _RecommendedJobCard(job: job, controller: controller),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Approximate height of the front card
  static const double _estimatedCardHeight = 230.0;
}

class _RecommendedJobCard extends StatelessWidget {
  final JobModel job;
  final JobController controller;

  const _RecommendedJobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.brownAccentPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.brownAccentPrimary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + badge + title + menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon (dark circle)
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.layers_rounded, color: Color(0xFF4CAF50), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NEW badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // More icon
              const Icon(Icons.more_horiz, color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          // Info chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _InfoChip(label: job.distance),
                const SizedBox(width: 8),
                _InfoChip(label: job.location),
                const SizedBox(width: 8),
                _InfoChip(label: 'Today: 04:30 PM'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Description + Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Installation of TV in Wall Mounting and Test wiring.',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white30,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  job.priceLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.declineJob(job),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: const Text(
                      'Reject Job',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.acceptJob(job),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Accept Job',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColor.brownAccentPrimary,
                      ),
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

// ─── Info Chip (used inside recommended card) ─────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _TabItem {
  final JobTabType type;
  final String label;
  const _TabItem(this.type, this.label);
}

class _JobTabBar extends StatelessWidget {
  final JobController controller;
  const _JobTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(JobTabType.newJobs, 'New Jobs'),
      _TabItem(JobTabType.activeJobs, 'Active Jobs'),
      _TabItem(JobTabType.completedJobs, 'Completed Jobs'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final selected = controller.selectedTab.value == tab.type;
          return GestureDetector(
            onTap: () => controller.selectTab(tab.type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColor.brownAccentPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                ),
              ),
              child: Text(
                tab.label,
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: selected ? Colors.white : AppColor.brownAccentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Job Card ────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final JobModel job;
  final JobController controller;
  const _JobCard({required this.job, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title,
                  style: AppTextStyle.titleMediumSemiBold.copyWith(color: AppColor.blackShade1),
                ),
              ),
              _BadgeChip(badge: job.badge),
            ],
          ),
          const SizedBox(height: 8),
          // Distance + Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColor.brownAccentPrimary),
              const SizedBox(width: 4),
              Text(
                '${job.distance} • ${job.location}',
                style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Requested Time
          Row(
            children: [
              const Icon(Icons.access_time_outlined, size: 13, color: AppColor.brownAccentPrimary),
              const SizedBox(width: 4),
              Text(
                'Requested for: ${job.requestedTime}',
                style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Price Row
          Row(
            children: [
              const Icon(Icons.credit_card_outlined, size: 13, color: AppColor.brownAccentPrimary),
              const SizedBox(width: 4),
              Text(
                job.priceLabel,
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.blackShade1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (job.additionalNote != null) ...[
                Text(
                  job.additionalNote!,
                  style: AppTextStyle.labelSmallRegular.copyWith(color: AppColor.coolGrayText),
                ),
              ],
            ],
          ),
          // Action Buttons
          if (job.showDeclineAccept) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Decline',
                    onTap: () => controller.declineJob(job),
                    borderColor: AppColor.lightGreyColor,
                    textColor: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilledButton(
                    label: job.isCustomQuote ? 'Accept & Quote' : 'Accept',
                    onTap: () => controller.acceptJob(job),
                  ),
                ),
              ],
            ),
          ],
          if (job.showCancelRequest) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _OutlineButton(
                    label: 'Cancel Request',
                    onTap: () => controller.cancelRequest(job),
                    borderColor: AppColor.lightGreyColor,
                    textColor: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilledButton(
                    label: 'Accept at Same',
                    onTap: () => controller.acceptAtSame(job),
                  ),
                ),
              ],
            ),
          ],
          // View Details Button
          const SizedBox(height: 8),
          if (job.showRequestPayment)
            _FilledButton(
              label: 'Request for Payment',
              onTap: () => controller.requestPayment(job),
            )
          else
            GestureDetector(
              onTap: () => controller.viewJobDetails(job),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Click to view Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

// ─── Category Icon ───────────────────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.air, color: AppColor.brownAccentPrimary, size: 22),
    );
  }
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final JobBadgeType badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color textColor;

    switch (badge) {
      case JobBadgeType.newBadge:
        label = 'NEW';
        bg = Colors.red;
        textColor = Colors.white;
        break;
      case JobBadgeType.installation:
        label = 'Installation';
        bg = const Color(0xFF2E7D32);
        textColor = Colors.white;
        break;
      case JobBadgeType.security:
        label = 'Security';
        bg = const Color(0xFFFF9800);
        textColor = Colors.white;
        break;
      case JobBadgeType.cleaning:
        label = 'Cleaning';
        bg = const Color(0xFF1565C0);
        textColor = Colors.white;
        break;
      case JobBadgeType.active:
        label = 'Active';
        bg = const Color(0xFF2E7D32);
        textColor = Colors.white;
        break;
      case JobBadgeType.updated:
        label = 'Updated';
        bg = const Color(0xFF1565C0);
        textColor = Colors.white;
        break;
      case JobBadgeType.underProcessing:
        label = 'Under Processing';
        bg = const Color(0xFFFF9800);
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Filled Button ────────────────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilledButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.brownAccentPrimary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyle.buttonSmall.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color borderColor;
  final Color textColor;
  const _OutlineButton({
    required this.label,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyle.buttonSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
