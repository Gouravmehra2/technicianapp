import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class SupportOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const SupportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });
}

class SupportController extends GetxController {
  late final List<SupportOption> options;

  @override
  void onInit() {
    super.onInit();
    options = [
      SupportOption(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Chat with Us',
        subtitle: 'Instantly chat with our support team',
        onTap: () => Get.toNamed(AppRoutes.chatSupportScreen),
      ),
      SupportOption(
        icon: Icons.phone_outlined,
        title: 'Call Support',
        subtitle: 'Talk to our support team',
        badge: 'Average wait ~ 2 mins',
        onTap: () => Get.toNamed(AppRoutes.callSupportScreen),
      ),
      SupportOption(
        icon: Icons.mail_outline_rounded,
        title: 'Email Support',
        subtitle: "Send us an email and we'll reply",
        badge: 'Reply in 24 hours',
        onTap: () => Get.toNamed(AppRoutes.emailSupportScreen),
      ),
    ];
  }
}
