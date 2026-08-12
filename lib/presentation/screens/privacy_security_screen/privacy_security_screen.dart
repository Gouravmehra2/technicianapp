import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'privacy_security_controller.dart';

class PrivacySecurityScreen extends GetView<PrivacySecurityController> {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'Privacy & Security',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ─── Privacy banner ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.blackShade1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR PRIVACY,',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'ENHANCED PROTECTION',
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: AppColor.greenColor, size: 22),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Account Security ────────────────────────────────────────
          _SectionLabel(label: 'Account Security'),
          const SizedBox(height: 10),
          _WhiteCard(
            children: [
              _SecTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: controller.onChangePassword,
              ),
              _Divider(),
              _SecTile(
                icon: Icons.phone_iphone_outlined,
                label: 'Change Phone Number',
                onTap: controller.onChangePhoneNumber,
              ),
              _Divider(),
              _SecTile(
                icon: Icons.alternate_email_outlined,
                label: 'Change Email',
                onTap: controller.onChangeEmail,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Access Control ──────────────────────────────────────────
          _SectionLabel(label: 'Access Control'),
          const SizedBox(height: 10),
          _WhiteCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _IconBox(icon: Icons.fingerprint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biometric Login',
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use Face ID or Fingerprint',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.biometricEnabled.value,
                        onChanged: (v) => controller.biometricEnabled.value = v,
                        activeColor: Colors.white,
                        activeTrackColor: AppColor.brownAccentPrimary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColor.lightGreyColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              _Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _IconBox(icon: Icons.check_box_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two Factor Authentication',
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add an extra layer of security',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.twoFactorEnabled.value,
                        onChanged: (v) => controller.twoFactorEnabled.value = v,
                        activeColor: Colors.white,
                        activeTrackColor: AppColor.brownAccentPrimary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColor.lightGreyColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Device Management ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(label: 'Device Management'),
              GestureDetector(
                onTap: controller.onLogoutAll,
                child: Text(
                  'Log out all',
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WhiteCard(
            children: [
              // Current device
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.brownAccentPrimary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.phone_iphone, color: AppColor.brownAccentPrimary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'iPhone 15 Pro',
                                style: AppTextStyle.titleSmallSemiBold.copyWith(
                                  color: AppColor.blackShade1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.lightGreen1Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'THIS DEVICE',
                                  style: AppTextStyle.labelSmallMedium.copyWith(
                                    color: AppColor.green2Color,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'London, UK • Active Now',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert, color: AppColor.coolGrayText, size: 20),
                  ],
                ),
              ),
              _Divider(),
              // Other device
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.laptop_mac, color: AppColor.coolGrayText, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MacBook Pro 16"',
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'San Francisco, US • 2 days ago',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Account ─────────────────────────────────────────────────
          _SectionLabel(label: 'ACCOUNT'),
          const SizedBox(height: 10),
          _WhiteCard(
            children: [
              _SecTile(
                label: 'Deactivate Account',
                onTap: controller.onDeactivateAccount,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Deleting your account is permanent and will\nremove all your site history and credentials.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmallRegular.copyWith(
              color: AppColor.coolGrayText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Delete Account button
          GestureDetector(
            onTap: controller.onDeleteAccount,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: AppTextStyle.buttonMedium.copyWith(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.titleSmallSemiBold.copyWith(
        color: AppColor.blackShade1,
        fontSize: 15,
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final List<Widget> children;
  const _WhiteCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SecTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _SecTile({
    this.icon,
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
            if (icon != null) ...[
              _IconBox(icon: icon!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.coolGrayText,
                  fontSize: 14,
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

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColor.brownAccentPrimary),
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
