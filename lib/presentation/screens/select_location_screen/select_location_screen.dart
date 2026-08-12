import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/custom_search_bar.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/select_location_screen/select_location_controller.dart';

class SelectLocationScreen extends StatelessWidget {
  const SelectLocationScreen({super.key});

  static const double _hPad = 16.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectLocationController>(
      builder: (controller) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: MyScaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Column(
                children: [
                  // ── AppBar ───────────────────────────────────────────
                  _AppBar(),
                  // ── Scrollable content ───────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: _hPad,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Search Bar ───────────────────────────────
                          CustomSearchBar(
                            controller: controller.searchController,
                            hintText: 'select_location_search_hint'.tr,

                            onSearch: controller.onSearchChanged,
                          ),
                          const SizedBox(height: 20),

                          // ── Quick Actions ────────────────────────────
                          _QuickActionsRow(controller: controller),
                          const SizedBox(height: 24),

                          // ── Saved Addresses ──────────────────────────
                          Text(
                            'select_location_saved_addresses'.tr,
                            style: AppTextStyle.labelMediumSemiBold.copyWith(
                              color: AppColor.darkGray,
                              letterSpacing: 1.2,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SavedAddressList(controller: controller),
                          const SizedBox(height: 4),

                          // ── View All ─────────────────────────────────
                          _ViewAllButton(onTap: controller.onViewAll),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Buttons (pinned) ──────────────────────────
                  _BottomButtons(controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 15,
        children: [
          InkWell(
            onTap: Get.back,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.darkGray.withValues(alpha: 0.05),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            ),
          ),
          Text(
            'select_location_title'.tr,
            style: AppTextStyle.titleLargeBold.copyWith(
              color: AppColor.blackShade1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions Row ────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  final SelectLocationController controller;

  const _QuickActionsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: AppAssets.currentLocationImage,
            iconColor: const Color(0xFFE07B39),
            iconBgColor: const Color(0xFFFFF3E8),
            label: 'select_location_use_current'.tr,
            onTap: controller.onUseCurrentLocation,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: AppAssets.addLocationImage,
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFF3EEFF),
            label: 'select_location_add_new'.tr,
            onTap: controller.onAddNewAddress,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionTile(
            icon: AppAssets.whatsUpImage,
            iconColor: const Color(0xFF16A34A),
            iconBgColor: const Color(0xFFECFDF5),
            label: 'select_location_request_friend'.tr,
            onTap: controller.onRequestFromFriend,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.borderColor.withValues(alpha: 0.30),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowGrey.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(icon, height: 30, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.left,
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.blackShade1,
                height: 1.4,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Saved Addresses List ─────────────────────────────────────────────────────

class _SavedAddressList extends StatelessWidget {
  final SelectLocationController controller;

  const _SavedAddressList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderColor.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowGrey.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(controller.savedAddresses.length, (index) {
          final address = controller.savedAddresses[index];
          final isLast = index == controller.savedAddresses.length - 1;
          return Column(
            children: [
              Obx(
                () => _AddressTile(
                  imageColor: address.iconColor,
                  imagePath: address.icon,
                  address: address,
                  isSelected: controller.selectedIndex.value == index,
                  onTap: () => controller.selectAddress(index),
                  onShare: () => controller.onShareAddress(index),
                  onEdit: () => controller.onEditAddress(index),
                  onDelete: () => controller.onDeleteAddress(index),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColor.lightGreyColor,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final SavedAddress address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color imageColor;
  final String imagePath;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.imageColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon box ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: address.iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.borderColor.withValues(alpha: 0.30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(imagePath, height: 24, color: imageColor),
                  const SizedBox(height: 2),
                  Text(
                    address.type,
                    style: AppTextStyle.labelMediumSemiBold.copyWith(
                      color: AppColor.blackShade2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    address.distance,
                    style: AppTextStyle.labelSmallRegular.copyWith(
                      color: AppColor.grey3Color,
                      // fontWeight: AppColor.grey3Color
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Address text + selected badge ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.type,
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightGreen1Color,
                            borderRadius: BorderRadius.circular(20),
                            // border: Border.all(
                            //   color: const Color(0xFF16A34A),
                            //   width: 0.8,
                            // ),
                          ),
                          child: Text(
                            'select_location_selected_badge'.tr,
                            style: AppTextStyle.labelSmallMedium.copyWith(
                              color: AppColor.green2Color,
                              fontSize: 9,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.grey2Color,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Action icons ──────────────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIcon(
                  imagePath: AppAssets.shareIcon,
                  color: AppColor.blueColor,
                  onTap: onShare,
                ),
                const SizedBox(height: 6),
                _ActionIcon(
                  imagePath: AppAssets.editIcon,
                  color: const Color(0xFF16A34A),
                  onTap: onEdit,
                ),
                const SizedBox(height: 6),
                _ActionIcon(
                  imagePath: AppAssets.deleteIcon,
                  color: const Color(0xFFDC2626),
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String imagePath;
  final Color? color;
  final VoidCallback onTap;

  const _ActionIcon({required this.imagePath, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(imagePath, height: 20, width: 17, color: color),
    );
  }
}

// ─── View All Button ──────────────────────────────────────────────────────────

class _ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Color(0xffFAF7F4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColor.brownAccentPrimary, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowGrey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          'select_location_view_all'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyle.bodyMediumMedium.copyWith(
            color: AppColor.brownAccentPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Buttons ───────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  final SelectLocationController controller;

  const _BottomButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── + Add New Address (dashed outline) ──────────────────────
          GestureDetector(
            onTap: controller.onAddNewAddress,
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                radius: Radius.circular(30),
                color: AppColor.brownAccentPrimary,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EE),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'select_location_add_address_btn'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.buttonLarge.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── Confirm Location ────────────────────────────────────────
          CommonButton(
            label: 'select_location_confirm_btn'.tr,
            onTap: controller.onConfirmLocation,
            backgroundColor: AppColor.brownAccentPrimary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
