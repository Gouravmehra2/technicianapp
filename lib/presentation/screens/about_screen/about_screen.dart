import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'about_controller.dart';

class AboutScreen extends GetView<AboutController> {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'About',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          // ─── App icon + name ────────────────────────────────────────
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECD7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.extension_rounded,
                    size: 44,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '1APP',
                style: AppTextStyle.titleLargeBold.copyWith(
                  color: AppColor.blackShade1,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Technician App',
                style: AppTextStyle.bodyMediumRegular.copyWith(
                  color: AppColor.brownAccentPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Version 1.0.0',
                style: AppTextStyle.bodySmallRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '1APP connects you with customers who need trusted service professionals at their doorstep.',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMediumRegular.copyWith(
                  color: AppColor.coolGrayText,
                  height: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ─── Company Info card ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPANY INFO',
                  style: AppTextStyle.labelMediumSemiBold.copyWith(
                    color: AppColor.brownAccentPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SquadOnSite is a premium service management platform built for elite technical professionals. '
                  'We bridge the gap between complex on-site requirements and efficient digital oversight.',
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: AppColor.brownAccentPrimary),
                    const SizedBox(width: 8),
                    Text(
                      '1APP TECHNOLOGIES INC.',
                      style: AppTextStyle.labelMediumSemiBold.copyWith(
                        color: AppColor.brownAccentPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Legal ──────────────────────────────────────────────────
          Text(
            'LEGAL',
            style: AppTextStyle.titleSmallSemiBold.copyWith(
              color: AppColor.blackShade1,
              fontSize: 15,
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
              children: [
                _LegalTile(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColor.brownAccentPrimary,
                  label: 'Licenses',
                  onTap: controller.onLicenses,
                ),
                _Divider(),
                _LegalTile(
                  icon: Icons.lock_outline,
                  iconColor: AppColor.coolGrayText,
                  label: 'Privacy Policy',
                  onTap: controller.onPrivacyPolicy,
                ),
                _Divider(),
                _LegalTile(
                  icon: Icons.gavel_outlined,
                  iconColor: AppColor.coolGrayText,
                  label: 'Terms & Conditions',
                  onTap: controller.onTerms,
                ),
                _Divider(),
                _LegalTile(
                  icon: Icons.code_outlined,
                  iconColor: AppColor.coolGrayText,
                  label: 'Open Source Libraries',
                  onTap: controller.onOpenSource,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _LegalTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.lightGreyColor,
      indent: 16,
      endIndent: 16,
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
