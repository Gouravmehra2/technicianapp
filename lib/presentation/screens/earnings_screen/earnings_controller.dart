import 'package:get/get.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

enum TransactionStatus { completed, failed, pending, bonus, deduction }

class RecentTransaction {
  final String title;
  final String dateTime;
  final String amount;
  final bool isPositive;
  final TransactionStatus status;

  const RecentTransaction({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.isPositive,
    required this.status,
  });
}

class EarningHistoryItem {
  final String title;
  final String jobId;
  final String time;
  final String amount;
  final bool isPositive;
  final TransactionStatus status;
  final String? iconType; // 'tv', 'wifi', 'ac', 'security', 'dollar', 'star', 'adjust'

  const EarningHistoryItem({
    required this.title,
    required this.jobId,
    required this.time,
    required this.amount,
    required this.isPositive,
    required this.status,
    this.iconType,
  });
}

class EarningHistoryGroup {
  final String dateLabel;
  final List<EarningHistoryItem> items;

  const EarningHistoryGroup({
    required this.dateLabel,
    required this.items,
  });
}

class IncomeBreakdownItem {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String iconType;

  const IncomeBreakdownItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.iconType,
  });
}

class EarningDetail {
  final String totalPayout;
  final bool isPaid;
  final List<IncomeBreakdownItem> incomeItems;
  final List<IncomeBreakdownItem> deductionItems;

  const EarningDetail({
    required this.totalPayout,
    required this.isPaid,
    required this.incomeItems,
    required this.deductionItems,
  });
}

// ─── Controller ──────────────────────────────────────────────────────────────

class EarningsController extends GetxController {
  // Earnings overview stats
  final String todayEarning = '\$360.00';
  final String pendingEarning = '\$220.00';
  final String thisMonthEarning = '\$754.00';
  final String thisMonthGrowth = '+54.65%';
  final String totalEarned = '\$3,603.00';

  // Period selector
  final RxString selectedPeriod = 'Weekly'.obs;

  // Bar chart data (S M T W T F S) — relative heights 0.0–1.0
  final List<double> weeklyBarData = const [
    0.45, 0.35, 1.0, 0.50, 0.0, 0.60, 0.0,
  ];
  final List<String> weekDayLabels = const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final int activeBarIndex = 2; // Tuesday highlighted

  final String thisWeekAmount = '\$360.00';
  final String thisWeekGrowth = '+54.65%';

  // Recent transactions
  final List<RecentTransaction> recentTransactions = const [
    RecentTransaction(
      title: 'Cash Withdraw',
      dateTime: 'Sep 10, 2025 • 10:30 AM',
      amount: '+\$443.00',
      isPositive: true,
      status: TransactionStatus.completed,
    ),
    RecentTransaction(
      title: 'Withdrawal to Paypal',
      dateTime: 'Sep 10, 2025 • 09:15 AM',
      amount: '-\$443.00',
      isPositive: false,
      status: TransactionStatus.failed,
    ),
    RecentTransaction(
      title: 'TV Wall Mounting',
      dateTime: 'Sep 9, 2025 • 02:45 PM',
      amount: '+\$120.00',
      isPositive: true,
      status: TransactionStatus.completed,
    ),
  ];

  // Earning History
  final RxString selectedHistoryTab = 'All'.obs;

  final List<EarningHistoryGroup> allHistoryGroups = const [
    EarningHistoryGroup(
      dateLabel: 'Today, Sep 10, 2025',
      items: [
        EarningHistoryItem(
          title: 'TV Wall Mounting',
          jobId: 'Job ID: #1024',
          time: '10:30 AM',
          amount: '+\$120.00',
          isPositive: true,
          status: TransactionStatus.completed,
          iconType: 'tv',
        ),
        EarningHistoryItem(
          title: 'WiFi Router Setup',
          jobId: 'Job ID: #1025',
          time: '02:15 PM',
          amount: '+\$85.00',
          isPositive: true,
          status: TransactionStatus.completed,
          iconType: 'wifi',
        ),
        EarningHistoryItem(
          title: 'TV Wall Mounting',
          jobId: 'Job ID: #1024',
          time: '10:30 AM',
          amount: '\$120.00',
          isPositive: false,
          status: TransactionStatus.pending,
          iconType: 'tv',
        ),
      ],
    ),
    EarningHistoryGroup(
      dateLabel: 'Yesterday, Sep 9, 2025',
      items: [
        EarningHistoryItem(
          title: 'AC Installation',
          jobId: 'Job ID: #1022',
          time: '11:45 AM',
          amount: '+\$210.00',
          isPositive: true,
          status: TransactionStatus.completed,
          iconType: 'ac',
        ),
        EarningHistoryItem(
          title: 'Home Security Camera',
          jobId: 'Job ID: #1023',
          time: '04:30 PM',
          amount: '+\$240.00',
          isPositive: true,
          status: TransactionStatus.completed,
          iconType: 'security',
        ),
        EarningHistoryItem(
          title: 'Home Security Camera',
          jobId: 'Job ID: #1023',
          time: '04:30 PM',
          amount: '\$240.00',
          isPositive: false,
          status: TransactionStatus.pending,
          iconType: 'security',
        ),
      ],
    ),
    EarningHistoryGroup(
      dateLabel: 'Sep 8, 2025',
      items: [
        EarningHistoryItem(
          title: 'TV Dismount',
          jobId: 'Job ID: #1019',
          time: '09:10 AM',
          amount: '+\$60.00',
          isPositive: true,
          status: TransactionStatus.completed,
          iconType: 'tv',
        ),
        EarningHistoryItem(
          title: 'Bonus – Weekly Goal',
          jobId: 'Bonus',
          time: '08:00 PM',
          amount: '+\$200.00',
          isPositive: true,
          status: TransactionStatus.bonus,
          iconType: 'star',
        ),
      ],
    ),
    EarningHistoryGroup(
      dateLabel: 'Sep 7, 2025',
      items: [
        EarningHistoryItem(
          title: 'Platform Adjustment',
          jobId: 'Adjustment',
          time: '11:59 PM',
          amount: '-\$20.00',
          isPositive: false,
          status: TransactionStatus.deduction,
          iconType: 'adjust',
        ),
      ],
    ),
  ];

  List<EarningHistoryGroup> get pendingHistoryGroups {
    return allHistoryGroups
        .map((group) => EarningHistoryGroup(
              dateLabel: group.dateLabel,
              items: group.items
                  .where((item) => item.status == TransactionStatus.pending)
                  .toList(),
            ))
        .where((group) => group.items.isNotEmpty)
        .toList();
  }

  List<EarningHistoryGroup> get displayedGroups {
    return selectedHistoryTab.value == 'All'
        ? allHistoryGroups
        : pendingHistoryGroups;
  }

  // Summary stats for history header
  final String historyTotalEarned = '\$3,603.00';
  final String historyTotalGrowth = '+18.6%';
  final String historyThisMonth = '\$754.00';
  final String historyThisMonthGrowth = '+54.65%';
  final String historyPending = '\$220.00';
  final int historyPendingJobs = 3;

  // Earning Detail (static for now)
  final EarningDetail earningDetail = const EarningDetail(
    totalPayout: '\$245.50',
    isPaid: true,
    incomeItems: [
      IncomeBreakdownItem(
        title: 'Service Fee',
        subtitle: 'AC Unit Repair (2.5 hrs)',
        amount: '\$180.00',
        isPositive: true,
        iconType: 'wrench',
      ),
      IncomeBreakdownItem(
        title: 'Travel Allowance',
        subtitle: 'Zone B (15 miles)',
        amount: '\$35.00',
        isPositive: true,
        iconType: 'fuel',
      ),
      IncomeBreakdownItem(
        title: 'Customer Tip',
        subtitle: 'Added post-service',
        amount: '+\$40.00',
        isPositive: true,
        iconType: 'heart',
      ),
    ],
    deductionItems: [
      IncomeBreakdownItem(
        title: 'Platform Fee',
        subtitle: 'Standard Tier (5%)',
        amount: '-\$9.50',
        isPositive: false,
        iconType: 'store',
      ),
    ],
  );

  void onViewAllTransactions() {}
  void onHistoryItemTapped(EarningHistoryItem item) {
    Get.toNamed('/earning-detail');
  }
  void onCalendarTapped() {}
}
