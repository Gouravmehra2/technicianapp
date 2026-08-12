import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'help_support_controller.dart';

class HelpSupportScreen extends GetView<HelpSupportController> {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'Help & Support',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ─── Hero section ────────────────────────────────────────────
          Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.headset_mic_rounded,
                    size: 56,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How can we help?',
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.blackShade1,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Get quick help or connect with our team.',
                style: AppTextStyle.bodyMediumRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Contact Support button
              GestureDetector(
                onTap: controller.onContactSupport,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Contact Support',
                    style: AppTextStyle.buttonMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ─── Quick Help ──────────────────────────────────────────────
          Text(
            'QUICK HELP',
            style: AppTextStyle.labelMediumSemiBold.copyWith(
              color: AppColor.coolGrayText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            child: Column(
              children: List.generate(controller.items.length, (i) {
                final item = controller.items[i];
                final isLast = i == controller.items.length - 1;
                return Column(
                  children: [
                    _HelpTile(item: item, isLast: isLast),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColor.lightGreyColor,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final HelpItem item;
  final bool isLast;
  const _HelpTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: item.iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColor.coolGrayText, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Color(0xFFEEEEEE), shape: BoxShape.circle),
        child: const Icon(Icons.chevron_left, color: AppColor.blackShade1, size: 24),
      ),
    );
  }
}
