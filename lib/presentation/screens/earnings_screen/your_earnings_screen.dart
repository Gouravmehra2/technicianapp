import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'earnings_controller.dart';
import 'earning_history_screen.dart';

class YourEarningsScreen extends StatelessWidget {
  const YourEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EarningsController>(
      init: EarningsController(),
      builder: (controller) {
        return MyScaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Column(
            children: [
              _AppBar(controller: controller),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EarningsOverviewCard(controller: controller),
                      const SizedBox(height: 16),
                      _EarningsActivityCard(controller: controller),
                      const SizedBox(height: 16),
                      _RecentTransactionsSection(controller: controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          Text(
            'Your Earnings',
            style: AppTextStyle.titleLargeBold.copyWith(
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

// ─── Earnings Overview Card ───────────────────────────────────────────────────

class _EarningsOverviewCard extends StatelessWidget {
  final EarningsController controller;
  const _EarningsOverviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC49A45),
            Color(0xFFA5732F),
            Color(0xFF8A5F22),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Overview',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OverviewStatBox(
                  label: "Today's Earning",
                  icon: Icons.calendar_today_outlined,
                  value: controller.todayEarning,
                  badge: null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewStatBox(
                  label: 'Pending',
                  icon: Icons.history_outlined,
                  value: controller.pendingEarning,
                  badge: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OverviewStatBox(
                  label: 'This Month',
                  icon: null,
                  value: controller.thisMonthEarning,
                  badge: controller.thisMonthGrowth,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewStatBox(
                  label: 'Total Earned',
                  icon: Icons.work_outline,
                  value: controller.totalEarned,
                  badge: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStatBox extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String value;
  final String? badge;

  const _OverviewStatBox({
    required this.label,
    required this.icon,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColor.coolGrayText,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBF4E4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 9,
                        color: AppColor.green2Color,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        badge!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          color: AppColor.green2Color,
                        ),
                      ),
                    ],
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 14, color: AppColor.brownAccentPrimary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColor.blackShade1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Earnings Activity Card ───────────────────────────────────────────────────

class _EarningsActivityCard extends StatelessWidget {
  final EarningsController controller;
  const _EarningsActivityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Earnings Activity',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColor.blackShade1,
                ),
              ),
              const Spacer(),
              _PeriodDropdown(controller: controller),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EDD8),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '\$',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'This Week',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.thisWeekAmount,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColor.blackShade1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 11,
                        color: AppColor.green2Color,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        controller.thisWeekGrowth,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColor.green2Color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _BarChart(controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final EarningsController controller;
  const _PeriodDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final options = ['Weekly', 'Monthly', 'Yearly'];
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map((opt) => ListTile(
                        title: Text(opt),
                        trailing: controller.selectedPeriod.value == opt
                            ? const Icon(Icons.check,
                                color: AppColor.brownAccentPrimary)
                            : null,
                        onTap: () {
                          controller.selectedPeriod.value = opt;
                          Get.back();
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.brownAccentPrimary, width: 1.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.selectedPeriod.value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColor.brownAccentPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColor.brownAccentPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final EarningsController controller;
  const _BarChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 80;
    const double barWidth = 22;
    const double barSpacing = 6;

    return SizedBox(
      height: chartHeight + 30,
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(controller.weeklyBarData.length, (i) {
                final isActive = i == controller.activeBarIndex;
                final barH =
                    (controller.weeklyBarData[i] * chartHeight).clamp(6.0, chartHeight);
                return Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : barSpacing / 2,
                    right: i == controller.weeklyBarData.length - 1
                        ? 0
                        : barSpacing / 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: barWidth,
                        height: barH,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColor.brownAccentPrimary
                              : const Color(0xFFF0E8D8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(controller.weekDayLabels.length, (i) {
              final isActive = i == controller.activeBarIndex;
              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : barSpacing / 2,
                  right: i == controller.weekDayLabels.length - 1
                      ? 0
                      : barSpacing / 2,
                ),
                child: SizedBox(
                  width: barWidth,
                  child: Center(
                    child: Text(
                      controller.weekDayLabels[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 11,
                        color: isActive
                            ? AppColor.brownAccentPrimary
                            : AppColor.coolGrayText,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Recent Transactions Section ─────────────────────────────────────────────

class _RecentTransactionsSection extends StatelessWidget {
  final EarningsController controller;
  const _RecentTransactionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColor.blackShade1,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.recentTransactions
              .map((tx) => _TransactionTile(transaction: tx)),
          const SizedBox(height: 4),
          Center(
            child: GestureDetector(
              onTap: () => Get.to(() => const EarningHistoryScreen()),
              child: const Text(
                'View All Transactions >',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColor.brownAccentPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RecentTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final Color iconBg;
    final Color iconColor;
    final IconData iconData;

    switch (transaction.status) {
      case TransactionStatus.completed:
        if (transaction.title == 'Cash Withdraw') {
          iconBg = const Color(0xFFDBF4E4);
          iconColor = AppColor.green2Color;
          iconData = Icons.call_received_rounded;
        } else {
          iconBg = const Color(0xFFF5EDD8);
          iconColor = AppColor.brownAccentPrimary;
          iconData = Icons.work_outline;
        }
        break;
      case TransactionStatus.failed:
        iconBg = const Color(0xFFFFEBEB);
        iconColor = const Color(0xFFE53935);
        iconData = Icons.call_made_rounded;
        break;
      default:
        iconBg = const Color(0xFFF5EDD8);
        iconColor = AppColor.brownAccentPrimary;
        iconData = Icons.work_outline;
    }

    final Color statusColor;
    final String statusLabel;
    switch (transaction.status) {
      case TransactionStatus.completed:
        statusColor = AppColor.green2Color;
        statusLabel = 'Completed';
        break;
      case TransactionStatus.failed:
        statusColor = const Color(0xFFE53935);
        statusLabel = 'Failed';
        break;
      case TransactionStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Pending';
        break;
      default:
        statusColor = AppColor.coolGrayText;
        statusLabel = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.dateTime,
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
                transaction.amount,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: transaction.isPositive
                      ? AppColor.blackShade1
                      : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                statusLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
