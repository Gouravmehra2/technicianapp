import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'earnings_controller.dart';

class EarningDetailScreen extends StatelessWidget {
  const EarningDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EarningsController>()
        ? Get.find<EarningsController>()
        : Get.put(EarningsController());

    final detail = controller.earningDetail;

    return MyScaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _AppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _TotalPayoutCard(detail: detail),
                  const SizedBox(height: 16),
                  _BreakdownCard(
                    title: 'Income Breakdown',
                    icon: Icons.receipt_long_outlined,
                    items: detail.incomeItems,
                  ),
                  const SizedBox(height: 16),
                  _BreakdownCard(
                    title: 'Deductions',
                    icon: Icons.receipt_outlined,
                    items: detail.deductionItems,
                  ),
                  const SizedBox(height: 16),
                  _NetSummaryCard(detail: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
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
            'Earning Detail',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColor.blackShade1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Total Payout Card ────────────────────────────────────────────────────────

class _TotalPayoutCard extends StatelessWidget {
  final EarningDetail detail;
  const _TotalPayoutCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E4CC), width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            'Total Payout',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColor.coolGrayText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.totalPayout,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              color: AppColor.brownAccentPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _StatusBadge(isPaid: detail.isPaid),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;
  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final Color fg = isPaid ? AppColor.green2Color : const Color(0xFFF59E0B);
    final Color bg = isPaid
        ? const Color(0xFFDBF4E4)
        : const Color(0xFFFEF3C7);
    final String label = isPaid ? 'Paid' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Breakdown Card ───────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<IncomeBreakdownItem> items;

  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColor.brownAccentPrimary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColor.blackShade1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFF2EEE8), height: 24),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _BreakdownRow(item: item),
                if (i < items.length - 1)
                  const Divider(
                    height: 16,
                    color: Color(0xFFF2EEE8),
                    indent: 56,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IncomeBreakdownItem item;
  const _BreakdownRow({required this.item});

  IconData _iconFor(String type) {
    switch (type) {
      case 'wrench':
        return Icons.build_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'heart':
        return Icons.favorite_border_rounded;
      case 'store':
        return Icons.storefront_outlined;
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTip = item.iconType == 'heart';
    final bool isDeduction = item.iconType == 'store';

    final Color iconBg = isDeduction
        ? const Color(0xFFFFEBEB)
        : const Color(0xFFF5EDD8);
    final Color iconColor = isDeduction
        ? const Color(0xFFE53935)
        : AppColor.brownAccentPrimary;

    final Color amountColor = isDeduction
        ? const Color(0xFFE53935)
        : isTip
            ? AppColor.green2Color
            : AppColor.blackShade1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(item.iconType), size: 18, color: iconColor),
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
                  item.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Net Summary Card ─────────────────────────────────────────────────────────

class _NetSummaryCard extends StatelessWidget {
  final EarningDetail detail;
  const _NetSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E4CC), width: 1.5),
      ),
      child: Column(
        children: [
          _NetRow(
            label: 'Total Income',
            value: '\$255.00',
            valueColor: AppColor.blackShade1,
          ),
          const Divider(height: 16, color: Color(0xFFEADDCA)),
          _NetRow(
            label: 'Total Deductions',
            value: '-\$9.50',
            valueColor: const Color(0xFFE53935),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFFD4BF9E), thickness: 1),
          ),
          _NetRow(
            label: 'Net Payout',
            value: detail.totalPayout,
            valueColor: AppColor.brownAccentPrimary,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _NetRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  const _NetRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: isBold ? 15 : 14,
            color: isBold ? AppColor.blackShade1 : AppColor.coolGrayText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
