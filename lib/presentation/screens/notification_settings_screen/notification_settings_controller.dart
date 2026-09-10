import 'package:get/get.dart';

class NotifItem {
  final String title;
  final String subtitle;
  final RxBool enabled;

  NotifItem({
    required this.title,
    required this.subtitle,
    required bool initialValue,
  }) : enabled = initialValue.obs;
}

class NotifGroup {
  final String heading;
  final List<NotifItem> items;

  NotifGroup({required this.heading, required this.items});
}

class NotificationSettingsController extends GetxController {
  late final List<NotifGroup> groups;

  @override
  void onInit() {
    super.onInit();
    groups = [
      NotifGroup(heading: 'BOOKINGS', items: [
        NotifItem(
          title: 'New Booking',
          subtitle: 'Alerts for new available service requests',
          initialValue: true,
        ),
        NotifItem(
          title: 'Cancelled Job',
          subtitle: 'Notifications when a customer cancels a booking',
          initialValue: true,
        ),
        NotifItem(
          title: 'Job Reminder',
          subtitle: 'Reminders 1 hour before scheduled start',
          initialValue: true,
        ),
      ]),
      NotifGroup(heading: 'PAYMENTS', items: [
        NotifItem(
          title: 'Payout Received',
          subtitle: 'Alert when funds are settled in your wallet',
          initialValue: true,
        ),
      ]),
      NotifGroup(heading: 'PROMOTIONS', items: [
        NotifItem(
          title: 'Offers',
          subtitle: 'Exclusive partner discounts and tool deals',
          initialValue: false,
        ),
        NotifItem(
          title: 'Referral Rewards',
          subtitle: 'Updates on successful technician referrals',
          initialValue: true,
        ),
      ]),
      NotifGroup(heading: 'COMMUNICATION CHANNELS', items: [
        NotifItem(
          title: 'Email',
          subtitle: 'Weekly summaries and legal notices',
          initialValue: true,
        ),
        NotifItem(
          title: 'SMS',
          subtitle: 'Urgent on-site arrival updates',
          initialValue: true,
        ),
        NotifItem(
          title: 'Push Notifications',
          subtitle: 'In-app real-time activity alerts',
          initialValue: true,
        ),
      ]),
    ];
  }

  void savePreferences() {
    Get.snackbar(
      'Saved',
      'Notification preferences updated.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
