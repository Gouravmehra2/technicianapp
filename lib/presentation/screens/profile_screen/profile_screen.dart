import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  ProfileScreen({super.key});

  @override
  var controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final double profileSize = Get.width * 0.26;
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            // Push content below the overlapping avatar (half of avatar height)
            SizedBox(height: profileSize / 2 + 12),
            _buildProfileInfo(),
            const SizedBox(height: 24),
            _buildPerformanceCard(),
            const SizedBox(height: 20),
            _buildMenuCard(),
            const SizedBox(height: 20),
            _ReferEarnSection(),
            const SizedBox(height: 20),
            _LogoutButton(),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: AppTextStyle.bodySmallRegular.copyWith(
                color: AppColor.coolGrayText,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Header with brown curved background + profile avatar ─────────────────

  Widget _buildHeader(BuildContext context) {
    final double profileSize = Get.width * 0.26;
    final double headerHeight = Get.height * 0.20;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Brown curved background
        Container(
          width: Get.width,
          height: headerHeight,
          decoration: BoxDecoration(
            color: AppColor.brownAccentPrimary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        // Profile avatar positioned to overlap bottom of header
        Positioned(
          top: headerHeight - profileSize / 2,
          child: GestureDetector(
            onTap: controller.pickProfileImage,
            child: Stack(
              children: [
                Obx(() {
                  final file = controller.profileImage.value;
                  return Container(
                    width: profileSize,
                    height: profileSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: file != null
                          ? Image.file(file, fit: BoxFit.cover)
                          : Obx(
                              () => controller.profileImageUrl.value.isEmpty
                                  ? Image.asset(
                                      AppAssets.onboardingImage2,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      controller.profileImageUrl.value,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                AppAssets.onboardingImage2,
                                                fit: BoxFit.cover,
                                              ),
                                    ),
                            ),
                    ),
                  );
                }),
                // Edit pencil badge
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Profile name, rating, badges ─────────────────────────────────────────

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Name + edit icon
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.userName.value.capitalizeFirst ?? '',
                  style: AppTextStyle.titleLargeBold.copyWith(
                    color: AppColor.blackShade1,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
              const SizedBox(width: 4),
              Text(
                '-',
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Reviews unavailable',
                style: AppTextStyle.bodySmallRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.experienceLevel.value,
              style: AppTextStyle.bodySmallRegular.copyWith(
                color: AppColor.coolGrayText,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => Text(
              controller.memberSince.value,
              style: AppTextStyle.bodySmallRegular.copyWith(
                color: AppColor.coolGrayText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Verified + Background Checked badges
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Badge(
                  icon: Icons.verified_outlined,
                  label: controller.verificationStatus.value.toUpperCase(),
                  color: AppColor.green2Color,
                  bgColor: AppColor.lightGreen1Color,
                ),
                const SizedBox(width: 8),
                _Badge(
                  icon: Icons.shield_outlined,
                  label: 'PROFILE COMPLETE',
                  color: AppColor.brownAccentPrimary,
                  bgColor: const Color(0xFFFFF3E0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Performance Overview card ─────────────────────────────────────────────

  Widget _buildPerformanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Overview',
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.lightGreyColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'All Time',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _StatBox(
                    label: 'Jobs Completed',
                    value: controller.jobsCompleted.value,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(label: 'Response Rate', value: '-'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatBox(label: 'Acceptance Rate', value: '-'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => _StatBox(
                    label: 'Earnings',
                    value: controller.earnings.value,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Menu card ─────────────────────────────────────────────────────────────

  Widget _buildMenuCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.notifications_none_outlined,
            label: 'Notification Settings',
            onTap: () => Get.toNamed(AppRoutes.notificationSettingsScreen),
            isFirst: true,
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.language_outlined,
            label: 'Language',
            trailing: _LanguageToggle(controller: controller),
            onTap: () {},
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.security_outlined,
            label: 'Security',
            onTap: () => Get.toNamed(AppRoutes.privacySecurityScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.person_outline,
            label: 'Personal Information',
            onTap: () => Get.toNamed(AppRoutes.personalInformationScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.build_outlined,
            label: 'Professional Info',
            onTap: () => Get.toNamed(AppRoutes.professionalInfoScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.description_outlined,
            label: 'Documents',
            onTap: () => Get.toNamed(AppRoutes.identityVerificationScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.account_balance_outlined,
            label: 'Bank Details',
            onTap: () => Get.toNamed(AppRoutes.bankPayoutScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.headset_mic_outlined,
            label: 'Support & Help',
            onTap: () => Get.toNamed(AppRoutes.helpSupportScreen),
          ),
          _buildDivider(),
          _MenuTile(
            icon: Icons.info_outline,
            label: 'About',
            onTap: () => Get.toNamed(AppRoutes.aboutScreen),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
    height: 1,
    thickness: 1,
    color: AppColor.lightGreyColor,
    indent: 16,
    endIndent: 16,
  );
}

// ─── Badge chip ────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.labelSmallMedium.copyWith(
              color: color,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat box ──────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.labelSmallRegular.copyWith(
              color: AppColor.coolGrayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyle.titleMediumSemiBold.copyWith(
              color: AppColor.brownAccentPrimary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Language toggle ──────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final ProfileController controller;

  const _LanguageToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['English', 'Spanish'].map((lang) {
          final selected = controller.selectedLanguage.value == lang;
          return GestureDetector(
            onTap: () => controller.changeLanguage(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColor.brownAccentPrimary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang,
                style: AppTextStyle.labelSmallMedium.copyWith(
                  color: selected ? Colors.white : AppColor.coolGrayText,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Menu tile ────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColor.brownAccentPrimary),
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
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColor.coolGrayText,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}

// ─── Refer & Earn ──────────────────────────────────────────────────────────

class _ReferEarnSection extends GetView<ProfileController> {
  const _ReferEarnSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAssets.referenceAndEarnImage),
        const SizedBox(height: 16),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F1F1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColor.brownAccentPrimary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Referral Code: ${controller.referralCode.value}',
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      Clipboard.setData(
                        ClipboardData(text: controller.referralCode.value),
                      ).then(
                        (_) => Get.snackbar(
                          'Copied',
                          'Referral code copied to clipboard',
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 2),
                        ),
                      ),
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Logout button ─────────────────────────────────────────────────────────

class _LogoutButton extends GetView<ProfileController> {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: controller.onLogout,
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
              const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Logout from 1APP-Technician',
                style: AppTextStyle.buttonMedium.copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
