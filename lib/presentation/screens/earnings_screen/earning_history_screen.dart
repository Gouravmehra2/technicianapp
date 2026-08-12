import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'earnings_controller.dart';
import 'earning_detail_screen.dart';

class EarningHistoryScreen extends StatelessWidget {
  const EarningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse existing controller if already put, else init a new one
    final controller = Get.isRegistered<EarningsController>()
        ? Get.find<EarningsController>()
        : Get.put(EarningsController());

    return MyScaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _AppBar(controller: controller),
          // Tab Row
          _TabBar(controller: controller),
          // Summary Stats
          _SummaryCard(controller: controller),
          // Grouped history list
          Expanded(
            child: Obx(() {
              final groups = controller.displayedGroups;
              if (groups.isEmpty) {
                return const Center(
                  child: Text(
                    'No earnings found.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColor.coolGrayText,
                    ),
                  ),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: groups.length,
                itemBuilder: (context, i) {
                  final group = groups[i];
                  return _HistoryGroup(group: group, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final EarningsController controller;
  const _AppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: AppColor.blackShade1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Earning History',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColor.blackShade1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: controller.onCalendarTapped,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColor.brownAccentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final EarningsController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E8D8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: ['All', 'Pendings'].map((tab) {
              final isSelected =
                  controller.selectedHistoryTab.value == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedHistoryTab.value = tab,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.brownAccentPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color:
                            isSelected ? Colors.white : AppColor.brownAccentPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final EarningsController controller;
  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF6EE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0E4CC), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SummaryStat(
                icon: Icons.wallet_outlined,
                iconColor: AppColor.brownAccentPrimary,
                iconBg: const Color(0xFFF0E8D8),
                label: 'Total Earned',
                value: controller.historyTotalEarned,
                badge: controller.historyTotalGrowth,
                badgePositive: true,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _SummaryStat(
                icon: Icons.trending_up_rounded,
                iconColor: AppColor.green2Color,
                iconBg: const Color(0xFFDBF4E4),
                label: 'This Month',
                value: controller.historyThisMonth,
                badge: controller.historyThisMonthGrowth,
                badgePositive: true,
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _SummaryStat(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                label: 'Pending',
                value: controller.historyPending,
                badge: '${controller.historyPendingJobs} Jobs',
                badgePositive: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE8DDD0),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String badge;
  final bool? badgePositive; // null = neutral (clock icon)

  const _SummaryStat({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgePositive,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = badgePositive == null
        ? const Color(0xFFF59E0B)
        : badgePositive!
            ? AppColor.green2Color
            : const Color(0xFFE53935);
    final Color badgeBg = badgePositive == null
        ? const Color(0xFFFEF3C7)
        : badgePositive!
            ? const Color(0xFFDBF4E4)
            : const Color(0xFFFFEBEB);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: AppColor.coolGrayText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColor.blackShade1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgePositive != null)
                Icon(
                  badgePositive! ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 9,
                  color: badgeColor,
                ),
              if (badgePositive == null)
                Icon(Icons.access_time, size: 9, color: badgeColor),
              const SizedBox(width: 2),
              Text(
                badge,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── History Group ────────────────────────────────────────────────────────────

class _HistoryGroup extends StatelessWidget {
  final EarningHistoryGroup group;
  final EarningsController controller;

  const _HistoryGroup({required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Text(
            group.dateLabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColor.blackShade1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0EBE3), width: 1),
          ),
          child: Column(
            children: group.items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _HistoryItemTile(
                    item: item,
                    onTap: () => Get.to(
                      () => const EarningDetailScreen(),
                      arguments: item,
                    ),
                  ),
                  if (i < group.items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFF2EEE8),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final EarningHistoryItem item;
  final VoidCallback onTap;

  const _HistoryItemTile({required this.item, required this.onTap});

  IconData _iconFor(String? type) {
    switch (type) {
      case 'tv':
        return Icons.tv_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'ac':
        return Icons.air_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'star':
        return Icons.star_border_rounded;
      case 'dollar':
        return Icons.attach_money_rounded;
      case 'adjust':
        return Icons.tune_rounded;
      default:
        return Icons.work_outline;
    }
  }

  Color _iconBgFor(String? type) {
    switch (type) {
      case 'star':
        return const Color(0xFFFEF3C7);
      case 'adjust':
        return const Color(0xFFFFEBEB);
      default:
        return const Color(0xFFF5EDD8);
    }
  }

  Color _iconColorFor(String? type) {
    switch (type) {
      case 'star':
        return const Color(0xFFF59E0B);
      case 'adjust':
        return const Color(0xFFE53935);
      default:
        return AppColor.brownAccentPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color amountColor;
    final Color statusBg;
    final Color statusFg;
    final String statusLabel;

    switch (item.status) {
      case TransactionStatus.completed:
        amountColor = AppColor.green2Color;
        statusBg = const Color(0xFFDBF4E4);
        statusFg = AppColor.green2Color;
        statusLabel = 'Completed';
        break;
      case TransactionStatus.pending:
        amountColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
        statusFg = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        break;
      case TransactionStatus.bonus:
        amountColor = AppColor.green2Color;
        statusBg = const Color(0xFFDBF4E4);
        statusFg = AppColor.green2Color;
        statusLabel = 'Bonus';
        break;
      case TransactionStatus.deduction:
        amountColor = const Color(0xFFE53935);
        statusBg = const Color(0xFFFFEBEB);
        statusFg = const Color(0xFFE53935);
        statusLabel = 'Deduction';
        break;
      default:
        amountColor = AppColor.blackShade1;
        statusBg = const Color(0xFFF2F2F2);
        statusFg = AppColor.coolGrayText;
        statusLabel = '';
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBgFor(item.iconType),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(item.iconType),
                size: 18,
                color: _iconColorFor(item.iconType),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColor.blackShade1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.jobId} • ${item.time}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColor.coolGrayText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColor.coolGrayText,
            ),
          ],
        ),
      ),
    );
  }
}
