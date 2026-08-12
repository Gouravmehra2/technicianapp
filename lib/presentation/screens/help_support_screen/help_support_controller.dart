import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class HelpItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const HelpItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
}

class HelpSupportController extends GetxController {
  late final List<HelpItem> items;

  @override
  void onInit() {
    super.onInit();
    items = [
      HelpItem(
        icon: Icons.help_outline_rounded,
        iconColor: const Color(0xFFA5732F),
        label: 'FAQs',
        onTap: () {},
      ),
      HelpItem(
        icon: Icons.chat_bubble_outline_rounded,
        iconColor: const Color(0xFF2A8DA8),
        label: 'Live Chat',
        onTap: () => Get.toNamed(AppRoutes.chatSupportScreen),
      ),
      HelpItem(
        icon: Icons.phone_outlined,
        iconColor: const Color(0xFF229D4F),
        label: 'Call Support',
        onTap: () => Get.toNamed(AppRoutes.callSupportScreen),
      ),
      HelpItem(
        icon: Icons.description_outlined,
        iconColor: const Color(0xFF935DED),
        label: 'Raise a Ticket',
        onTap: () => Get.toNamed(AppRoutes.emailSupportScreen),
      ),
      HelpItem(
        icon: Icons.access_time_outlined,
        iconColor: const Color(0xFF555555),
        label: 'Terms & Conditions',
        onTap: () {},
      ),
      HelpItem(
        icon: Icons.lock_outline,
        iconColor: const Color(0xFF555555),
        label: 'Privacy Policy',
        onTap: () => Get.toNamed(AppRoutes.privacyPolicyScreen),
      ),
      HelpItem(
        icon: Icons.star_outline_rounded,
        iconColor: const Color(0xFFFFB800),
        label: 'Rate Our App',
        onTap: () {},
      ),
      HelpItem(
        icon: Icons.share_outlined,
        iconColor: const Color(0xFFE53935),
        label: 'Share Our App',
        onTap: () {},
      ),
    ];
  }

  void onContactSupport() {
    Get.toNamed(AppRoutes.chatSupportScreen);
  }
}
