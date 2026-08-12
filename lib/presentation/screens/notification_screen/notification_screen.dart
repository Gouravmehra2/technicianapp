import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.hasNotifications.value
        ? _NotificationsListView(controller: controller)
        : const _EmptyNotificationView());
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyNotificationView extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const _BackButton(),
        title: Text(
          'Notification Center',
          style: AppTextStyle.titleLargeBold
              .copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleeping bell icon
              Icon(
                Icons.notifications_off_outlined,
                size: 90,
                color: AppColor.brownAccentPrimary,
              ),
              const SizedBox(height: 28),
              Text(
                "You're all caught up",
                style: AppTextStyle.titleLargeBold
                    .copyWith(color: AppColor.blackShade1, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'No update to stay updated!\nAccept the job to get reminders.',
                style: AppTextStyle.bodyMediumRegular
                    .copyWith(color: AppColor.blackShade1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── List View ────────────────────────────────────────────────────────────────

class _NotificationsListView extends StatelessWidget {
  final NotificationController controller;
  const _NotificationsListView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const _BackButton(),
        title: Text(
          'Notification Center',
          style: AppTextStyle.titleLargeBold
              .copyWith(color: AppColor.blackShade1),
        ),
        actions: [
          GestureDetector(
            onTap: controller.markAllAsRead,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Mark all as read',
                style: AppTextStyle.bodySmallMedium
                    .copyWith(color: AppColor.brownAccentPrimary),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          _SectionHeader(title: 'Today'),
          _NotificationGroup(items: controller.todayNotifications),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Yesterday'),
          _NotificationGroup(items: controller.yesterdayNotifications),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Earlier'),
          _NotificationGroup(items: controller.earlierNotifications),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title,
        style: AppTextStyle.titleSmallSemiBold.copyWith(
          color: AppColor.blackShade1,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ─── Notification Group (white card container) ────────────────────────────────

class _NotificationGroup extends StatelessWidget {
  final List<NotificationItem> items;
  const _NotificationGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _NotificationCard(item: items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF0F0F0),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          _NotificationIcon(icon: item.icon),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: AppColor.blackShade1,
                              fontSize: 14,
                            ),
                          ),
                          if (item.isNew) ...[
                            const SizedBox(width: 6),
                            _NewBadge(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: AppTextStyle.labelSmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // Body text
                Text(
                  item.body,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.4,
                  ),
                ),

                // New Job Request extras: distance + price
                if (item.type == NotificationType.newJobRequest &&
                    item.distance != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColor.coolGrayText,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.distance!,
                        style: AppTextStyle.labelSmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                      const Spacer(),
                      if (item.estimatedPrice != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.estimatedPrice!,
                              style: AppTextStyle.titleSmallSemiBold.copyWith(
                                color: AppColor.blackShade1,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Estimated',
                              style: AppTextStyle.labelSmallRegular.copyWith(
                                color: AppColor.coolGrayText,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],

                // Schedule detail line
                if (item.type == NotificationType.scheduleUpdated &&
                    item.scheduleDetail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.scheduleDetail!,
                    style: AppTextStyle.bodySmallMedium.copyWith(
                      color: AppColor.brownAccentPrimary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Chevron
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColor.coolGrayText,
          ),
        ],
      ),
    );
  }
}

// ─── Notification Icon ────────────────────────────────────────────────────────

class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  const _NotificationIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColor.brownAccentPrimary, size: 22),
    );
  }
}

// ─── NEW Badge ────────────────────────────────────────────────────────────────

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.brownAccentPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NEW',
        style: AppTextStyle.labelSmallMedium.copyWith(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Back Button ──────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColor.blackShade1,
          size: 22,
        ),
      ),
    );
  }
}
