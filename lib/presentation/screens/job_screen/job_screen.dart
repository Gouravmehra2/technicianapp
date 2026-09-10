import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/app_shimmer.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
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
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.blackShade1,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColor.coolGrayText,
                          size: 20,
                        ),
                        hintText: 'Search for job or service',
                        hintStyle: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
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
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
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
              final tabKey = ValueKey(controller.selectedTab.value);
              if (controller.isLoading.value) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: ListView(
                    key: tabKey,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: const [
                      RecommendedJobCardShimmer(),
                      SizedBox(height: 20),
                      JobListCardShimmer(),
                      SizedBox(height: 12),
                      JobListCardShimmer(),
                      SizedBox(height: 12),
                      JobListCardShimmer(),
                    ],
                  ),
                );
              }

              final isNewTab =
                  controller.selectedTab.value == JobTabType.newJobs;
              final jobs = controller.currentJobs;

              Widget content;

              if (jobs.isEmpty) {
                content = Center(
                  key: ValueKey('empty-${controller.selectedTab.value}'),
                  child: Text(
                    'No jobs found',
                    style: AppTextStyle.bodyMediumRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                  ),
                );
              } else if (isNewTab) {
                final recommendedJob = jobs.first;
                final listJobs = jobs.length > 1 ? jobs.sublist(1) : <Jobs>[];

                content = ListView(
                  key: tabKey,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _RecommendedJobSection(
                      job: recommendedJob,
                      extraCount: listJobs.length,
                      controller: controller,
                    ),
                    const SizedBox(height: 20),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...listJobs.asMap().entries.map(
                        (e) => Padding(
                          padding: EdgeInsets.only(
                            bottom: e.key < listJobs.length - 1 ? 12 : 0,
                          ),
                          child: _JobCard(
                            job: e.value,
                            controller: controller,
                            isRequestedTab: false,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              } else {
                final isRequested =
                    controller.selectedTab.value == JobTabType.requestedJob;
                content = ListView.separated(
                  key: tabKey,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) => _JobCard(
                    job: jobs[i],
                    controller: controller,
                    isRequestedTab: isRequested,
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: content,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Next Schedule Banner ─────────────────────────────────────────────────────

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
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Next Schedule in:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '2h 45m',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
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
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommended Job Stacked Section ─────────────────────────────────────────

class _RecommendedJobSection extends StatelessWidget {
  final Jobs job;
  final int extraCount;
  final JobController controller;

  const _RecommendedJobSection({
    required this.job,
    required this.extraCount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ghostCount = extraCount.clamp(0, 2);
    const cardRadius = 20.0;
    const peekOffset = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onTap: () {},
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
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColor.brownAccentPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 45),
        SizedBox(
          height: _estimatedCardHeight + (ghostCount * peekOffset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (ghostCount >= 2)
                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: _estimatedCardHeight,
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                  ),
                ),
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

  static const double _estimatedCardHeight = 230.0;
}

// ─── Recommended Job Card ─────────────────────────────────────────────────────

class _RecommendedJobCard extends StatelessWidget {
  final Jobs job;
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
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
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
                      job.title ?? '',
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
              const Icon(Icons.more_horiz, color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          // Info chips — service type, location, schedule
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if ((job.serviceType?.name ?? '').isNotEmpty)
                  _InfoChip(label: job.serviceType!.name!),
                if ((job.serviceType?.name ?? '').isNotEmpty)
                  const SizedBox(width: 8),
                _InfoChip(label: job.location ?? ''),
                const SizedBox(width: 8),
                _InfoChip(label: controller.scheduleTimeLabel(job)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Pay type badge
          Row(children: [_PayTypeBadge(label: controller.payTypeLabel(job))]),
          const SizedBox(height: 12),
          // Description + Pay detail
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  job.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.payDetailLabel(job),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isRequesting = controller.requestingJobIds.contains(
                    job.sId ?? '',
                  );
                  return GestureDetector(
                    onTap: isRequesting
                        ? null
                        : () => controller.requestJob(job),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: isRequesting
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isRequesting ? Colors.white38 : Colors.white54,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isRequesting
                            ? const SizedBox(
                                key: ValueKey('rec-loading'),
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Request Job',
                                key: ValueKey('rec-label'),
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
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.counterOffer(job),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Counter Offer',
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

// ─── Info Chip ────────────────────────────────────────────────────────────────

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

// ─── Pay Type Badge (inside recommended card) ─────────────────────────────────

class _PayTypeBadge extends StatelessWidget {
  final String label;

  const _PayTypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.payment_outlined, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meta Chip (inside list job card) ────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _MetaChip({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _TabItem {
  final JobTabType type;
  final String label;

  const _TabItem(this.type, this.label);
}

class _JobTabBar extends StatefulWidget {
  final JobController controller;

  const _JobTabBar({required this.controller});

  @override
  State<_JobTabBar> createState() => _JobTabBarState();
}

class _JobTabBarState extends State<_JobTabBar> {
  final _scrollController = ScrollController();
  final List<GlobalKey> _keys = List.generate(4, (_) => GlobalKey());

  static const _tabs = [
    _TabItem(JobTabType.newJobs, 'New Jobs'),
    _TabItem(JobTabType.activeJobs, 'Active Jobs'),
    _TabItem(JobTabType.completedJobs, 'Completed Jobs'),
    _TabItem(JobTabType.requestedJob, 'Requested Jobs'),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[index].currentContext;
      if (ctx == null || !_scrollController.hasClients) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = widget.controller.selectedTab.value;
      final selectedIndex = _tabs.indexWhere((t) => t.type == current);
      _scrollToSelected(selectedIndex);

      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final selected = current == tab.type;

            return GestureDetector(
              key: _keys[i],
              onTap: () => widget.controller.changeTab(tab.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 20 : 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColor.brownAccentPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? AppColor.brownAccentPrimary
                        : AppColor.lightGreyColor,
                    width: selected ? 1.5 : 1.0,
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: selected
                        ? Colors.white
                        : AppColor.brownAccentPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: selected ? 13 : 12,
                  ),
                  child: Text(tab.label),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final Jobs job;
  final JobController controller;
  final bool isRequestedTab;

  const _JobCard({
    required this.job,
    required this.controller,
    required this.isRequestedTab,
  });

  @override
  Widget build(BuildContext context) {
    final status = job.status ?? '';
    final badge = isRequestedTab
        ? _badgeFromStatus(job.requestStatus.toString() ?? '')
        : _badgeFromStatus(status);

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
          // ── Title Row ──────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title ?? '',
                  style: AppTextStyle.titleMediumSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
              ),
              _BadgeChip(badge: badge),
            ],
          ),
          const SizedBox(height: 8),
          // ── Service Type + Pay Type chips ──────────────────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if ((job.serviceType?.name ?? '').isNotEmpty)
                _MetaChip(
                  label: job.serviceType!.name!,
                  color: const Color(0xFFFFF3E0),
                  textColor: AppColor.brownAccentPrimary,
                  icon: Icons.build_outlined,
                ),
              _MetaChip(
                label: controller.payTypeLabel(job),
                color: const Color(0xFFE8F5E9),
                textColor: const Color(0xFF2E7D32),
                icon: Icons.payment_outlined,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Distance + Location ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColor.brownAccentPrimary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location ?? '',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: const Color(0xff333333),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Schedule time ──────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 16,
                color: AppColor.brownAccentPrimary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.scheduleTimeLabel(job),
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: const Color(0xff333333),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // ── Pay detail ─────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                size: 16,
                color: AppColor.brownAccentPrimary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.payDetailLabel(job),
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          // ── New Jobs tab: Request Job + Counter Offer ──────────────────────
          // if (!isRequestedTab && !isCompleted) ...[
          //   const SizedBox(height: 10),
          //   Row(
          //     children: [
          //       Expanded(
          //         child: Obx(() {
          //           final isRequesting =
          //               controller.requestingJobIds.contains(job.sId ?? '');
          //           return GestureDetector(
          //             onTap: isRequesting
          //                 ? null
          //                 : () => controller.requestJob(job),
          //             child: AnimatedContainer(
          //               duration: const Duration(milliseconds: 250),
          //               curve: Curves.easeInOut,
          //               padding: const EdgeInsets.symmetric(vertical: 12),
          //               decoration: BoxDecoration(
          //                 color: isRequesting
          //                     ? AppColor.lightGreyColor.withValues(alpha: 0.5)
          //                     : Colors.white,
          //                 borderRadius: BorderRadius.circular(30),
          //                 border: Border.all(color: AppColor.lightGreyColor),
          //               ),
          //               child: AnimatedSwitcher(
          //                 duration: const Duration(milliseconds: 200),
          //                 child: isRequesting
          //                     ? const SizedBox(
          //                         key: ValueKey('card-loading'),
          //                         width: 18,
          //                         height: 18,
          //                         child: CircularProgressIndicator(
          //                           strokeWidth: 2,
          //                           color: AppColor.brownAccentPrimary,
          //                         ),
          //                       )
          //                     : Text(
          //                         'Request job',
          //                         key: const ValueKey('card-label'),
          //                         textAlign: TextAlign.center,
          //                         style: AppTextStyle.buttonSmall.copyWith(
          //                           color: AppColor.blackShade1,
          //                         ),
          //                       ),
          //               ),
          //             ),
          //           );
          //         }),
          //       ),
          //       const SizedBox(width: 10),
          //       Expanded(
          //         child: _FilledButton(
          //           label: 'Counter Offer',
          //           onTap: () => controller.counterOffer(job),
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
          // ── Active Jobs tab: Navigate button ────────────────────────────
          if (controller.selectedTab.value == JobTabType.activeJobs) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => controller.navigateToJob(job),
              icon: const Icon(Icons.navigation_outlined, size: 16),
              label: const Text('NAVIGATE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.blackShade1,
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(double.infinity, 42),
                textStyle: AppTextStyle.labelSmallMedium.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          // ── Requested tab: Cancel Request + Counter Offer ──────────────────
          if (isRequestedTab) ...[
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
                    label: 'Counter Offer',
                    onTap: () => controller.counterOffer(job),
                  ),
                ),
              ],
            ),
          ],
          // ── View Details / Request Payment ────────────────────────────────
          const SizedBox(height: 8),
          if (controller.showRequestPayment(job))
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

// ─── Badge from status string ─────────────────────────────────────────────────

_JobBadgeType _badgeFromStatus(String status) {
  return switch (status) {
    'in-progress' => _JobBadgeType.inProgress,
    'completed' => _JobBadgeType.completed,
    'assigned' => _JobBadgeType.assigned,
    'canceled' => _JobBadgeType.canceled,
    'pending' => _JobBadgeType.pending,
    'accepted' => _JobBadgeType.accepted,
    'counter-offer' || 'countered' => _JobBadgeType.counterOffer,
    'rejected' => _JobBadgeType.rejected,
    _ => _JobBadgeType.open,
  };
}

enum _JobBadgeType {
  open,
  assigned,
  inProgress,
  completed,
  canceled,
  pending,
  accepted,
  counterOffer,
  rejected,
}

// ─── Category Icon ────────────────────────────────────────────────────────────

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
      child: const Icon(
        Icons.air,
        color: AppColor.brownAccentPrimary,
        size: 22,
      ),
    );
  }
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final _JobBadgeType badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (badge) {
      _JobBadgeType.open => ('Open', const Color(0xFF1565C0)),
      _JobBadgeType.assigned => ('Assigned', const Color(0xFF008614)),
      _JobBadgeType.inProgress => ('In Progress', const Color(0xFFFF9800)),
      _JobBadgeType.completed => ('Completed', const Color(0xFF4CAF50)),
      _JobBadgeType.canceled => ('Canceled', const Color(0xFF9E9E9E)),
      _JobBadgeType.pending => ('Pending', const Color(0xFFFFA726)),
      _JobBadgeType.accepted => ('Accepted', const Color(0xFF008614)),
      _JobBadgeType.counterOffer => ('Counter Offer', const Color(0xFF7B1FA2)),
      _JobBadgeType.rejected => ('Rejected', const Color(0xFFD32F2F)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: Colors.white,
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
