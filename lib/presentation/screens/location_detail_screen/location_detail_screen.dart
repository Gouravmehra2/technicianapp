import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/location_detail_screen/location_detail_controller.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationDetailController>(
      builder: (controller) {
        return MyScaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColor.backgroundGradient,
            ),
            child: Column(
              children: [
                SizedBox(height: Get.height*0.06),
                Row(
                  children: [
                    InkWell(
                      onTap: (){Get.back();},
                      child: Container(
                        margin: EdgeInsetsDirectional.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.darkGray.withValues(alpha: 0.05),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                    Align(alignment: Alignment.center,child: _buildTitle()),
                  ],
                ),
                Expanded(
                  child: Form(
                    key: controller.formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(controller),
                          const SizedBox(height: 14),
                          _buildCurrentLocationButton(controller),
                          const SizedBox(height: 28),
                          _buildEnterDetailsSection(controller),
                          const SizedBox(height: 22),
                          _buildSaveAsSection(controller),
                          const SizedBox(height: 28),
                          _buildConfirmButton(controller),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Text(
      'location_detail_title'.tr,
      style: AppTextStyle.headlineMediumSemiBold.copyWith(
        color: AppColor.blackShade1,
        fontSize: 20
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(LocationDetailController controller) {
    return CommonTextFormField(readOnly: true,
      onTap: (){
        Get.toNamed(AppRoutes.mapScreen);
      },
      controller: controller.searchController,
      hintText: 'location_detail_search_hint'.tr,
      keyboardType: TextInputType.streetAddress,
      textInputAction: TextInputAction.search,
      prefixIcon: Icons.search_rounded,
      onChanged: controller.onSearchChanged,
      borderColor: Colors.transparent,
      backgroundColor: Colors.white,
    );
  }

  // ── Use current location ───────────────────────────────────────────────────

  Widget _buildCurrentLocationButton(LocationDetailController controller) {
    return GestureDetector(
      onTap: controller.useCurrentLocation,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.my_location_rounded,
            size: 20,
            color: AppColor.brownAccentPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            'location_detail_use_current'.tr,
            style: AppTextStyle.titleSmallSemiBold.copyWith(
              color: AppColor.brownAccentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Enter Details section ──────────────────────────────────────────────────

  Widget _buildEnterDetailsSection(LocationDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'location_detail_enter_details'.tr,
          style: AppTextStyle.titleLargeBold.copyWith(
            color: AppColor.blackShade1,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('location_detail_house_label'.tr),
        const SizedBox(height: 6),
        CommonTextFormField(
          controller: controller.houseController,
          hintText: '',
          textInputAction: TextInputAction.next,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          validator: CommonValidators.required(
            message: 'location_detail_house_required'.tr,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('location_detail_apartment_label'.tr),
        const SizedBox(height: 6),
        CommonTextFormField(
          controller: controller.apartmentController,
          hintText: '',
          textInputAction: TextInputAction.next,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          validator: CommonValidators.required(
            message: 'location_detail_apartment_required'.tr,
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('location_detail_landmark_label'.tr),
        const SizedBox(height: 6),
        CommonTextFormField(
          controller: controller.landmarkController,
          hintText: '',
          textInputAction: TextInputAction.done,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
        ),
      ],
    );
  }

  // ── Save as section ────────────────────────────────────────────────────────

  Widget _buildSaveAsSection(LocationDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('location_detail_save_as'.tr),
        const SizedBox(height: 10),
        Obx(() => _SaveAsRow(
              selected: controller.selectedSaveAs.value,
              onSelect: controller.selectSaveAs,
            )),
      ],
    );
  }

  // ── Confirm button ─────────────────────────────────────────────────────────

  Widget _buildConfirmButton(LocationDetailController controller) {
    return CommonButton(
      label: 'location_detail_confirm_btn'.tr,
      onTap: controller.confirmLocation,
      backgroundColor: AppColor.blackColor,
      foregroundColor: Colors.white,
    );
  }

  // ── Shared field label ─────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyle.bodyMediumRegular.copyWith(
        color: AppColor.grey2Color,
      ),
    );
  }
}

// ─── Save-as chip row ─────────────────────────────────────────────────────────

class _SaveAsRow extends StatelessWidget {
  final SaveAsType selected;
  final ValueChanged<SaveAsType> onSelect;

  const _SaveAsRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SaveAsChip(
          label: 'location_detail_save_home'.tr,
          icon: Icons.home_outlined,
          type: SaveAsType.home,
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(width: 10),
        _SaveAsChip(
          label: 'location_detail_save_office'.tr,
          icon: Icons.work_outline_rounded,
          type: SaveAsType.office,
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(width: 10),
        _SaveAsChip(
          label: 'location_detail_save_other'.tr,
          icon: Icons.location_on_outlined,
          type: SaveAsType.other,
          selected: selected,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _SaveAsChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final SaveAsType type;
  final SaveAsType selected;
  final ValueChanged<SaveAsType> onSelect;

  const _SaveAsChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.selected,
    required this.onSelect,
  });

  bool get _isSelected => type == selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isSelected ? AppColor.blackColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isSelected ? AppColor.blackColor : AppColor.lightGreyColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: _isSelected ? Colors.white : AppColor.blackShade1,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyle.bodyMediumMedium.copyWith(
                color: _isSelected ? Colors.white : AppColor.blackShade1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
