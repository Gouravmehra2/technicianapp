import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NotificationType {
  newJobRequest,
  jobAccepted,
  scheduleUpdated,
  paymentReceived,
  customerMessage,
  jobCompleted,
  weeklyEarnings,
  documentVerified,
}

class NotificationItem {
  final String title;
  final String time;
  final String body;
  final NotificationType type;
  final IconData icon;

  // Optional extras for "New Job Request"
  final String? jobType;
  final String? distance;
  final String? estimatedPrice;
  final bool isNew;

  // For "Schedule Updated"
  final String? scheduleDetail;

  const NotificationItem({
    required this.title,
    required this.time,
    required this.body,
    required this.type,
    required this.icon,
    this.jobType,
    this.distance,
    this.estimatedPrice,
    this.isNew = false,
    this.scheduleDetail,
  });
}

class NotificationController extends GetxController {
  final RxBool hasNotifications = true.obs;
  final RxBool hasUnread = true.obs;

  final List<NotificationItem> todayNotifications = const [
    NotificationItem(
      title: 'New Job Request',
      time: '8 min ago',
      body: 'Smart TV Installation',
      type: NotificationType.newJobRequest,
      icon: Icons.work_outline,
      jobType: 'Smart TV Installation',
      distance: '2.4 km away',
      estimatedPrice: '₹1,200',
      isNew: true,
    ),
    NotificationItem(
      title: 'Job Accepted',
      time: '32 min ago',
      body: 'Your TV Mounting job has been confirmed.',
      type: NotificationType.jobAccepted,
      icon: Icons.check_circle_outline,
    ),
    NotificationItem(
      title: 'Schedule Updated',
      time: '1 hr ago',
      body: 'Customer changed the appointment time.',
      type: NotificationType.scheduleUpdated,
      icon: Icons.calendar_today_outlined,
      scheduleDetail: 'Today • 6:30 PM  →  7:00 PM',
    ),
  ];

  final List<NotificationItem> yesterdayNotifications = const [
    NotificationItem(
      title: 'Payment Received',
      time: 'Yesterday, 7:45 PM',
      body: '₹1,050 has been added to your earnings.',
      type: NotificationType.paymentReceived,
      icon: Icons.account_balance_wallet_outlined,
    ),
    NotificationItem(
      title: 'Customer Message',
      time: 'Yesterday, 5:20 PM',
      body: 'Client wants you to bring HDMI Wire.',
      type: NotificationType.customerMessage,
      icon: Icons.chat_bubble_outline,
    ),
    NotificationItem(
      title: 'Job Completed',
      time: 'Yesterday, 2:15 PM',
      body: 'Great work! Your job has been marked completed.',
      type: NotificationType.jobCompleted,
      icon: Icons.star_outline,
    ),
  ];

  final List<NotificationItem> earlierNotifications = const [
    NotificationItem(
      title: 'Weekly Earnings',
      time: 'Mon, 9:30 AM',
      body: 'You earned ₹8,450 this week.',
      type: NotificationType.weeklyEarnings,
      icon: Icons.bar_chart,
    ),
    NotificationItem(
      title: 'Document Verified',
      time: 'Sun, 1:10 PM',
      body: 'Your updated verification has been approved.',
      type: NotificationType.documentVerified,
      icon: Icons.shield_outlined,
    ),
  ];

  void markAllAsRead() {
    hasUnread.value = false;
  }

  void clearAll() {
    hasNotifications.value = false;
  }
}
