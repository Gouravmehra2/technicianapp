import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/map_screen/map_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(
      builder: (controller) {
        return MyScaffold(
          body: Stack(
            children: [
              _buildMap(controller),
              _buildTopBar(),
              _buildCurrentLocationButton(controller),
              _buildBottomSheet(controller),
            ],
          ),
        );
      },
    );
  }


  // ── Map ───────────────────────────────────────────────────────────────────

  Widget _buildMap(MapController controller) {
    return GoogleMap(
      onMapCreated: controller.onMapCreated,
      initialCameraPosition: CameraPosition(
        target: controller.initialCameraTarget,
        zoom: controller.initialZoom,
      ),
      markers: controller.markers,
      onTap: controller.onTap,
      onCameraIdle: controller.onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  // ── Top bar with back button ──────────────────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  'map_search_placeholder'.tr,
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My location FAB ───────────────────────────────────────────────────────

  Widget _buildCurrentLocationButton(MapController controller) {
    return Positioned(
      right: 16,
      bottom: 200,
      child: Obx(() => _CircleIconButton(
            icon: Icons.my_location_rounded,
            onTap: controller.isLoadingLocation.value
                ? null
                : controller.goToCurrentLocation,
            isLoading: controller.isLoadingLocation.value,
            backgroundColor: Colors.white,
            iconColor: AppColor.brownAccentPrimary,
          )),
    );
  }

  // ── Bottom confirm sheet ──────────────────────────────────────────────────

  Widget _buildBottomSheet(MapController controller) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColor.lightGreyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'map_selected_location_label'.tr,
              style: AppTextStyle.titleSmallSemiBold.copyWith(
                color: AppColor.coolGrayText,
              ),
            ),
            const SizedBox(height: 6),

            Obx(() {
              final address = controller.selectedAddress.value;
              final pos = controller.selectedPosition.value;
              return Text(
                address.isNotEmpty
                    ? address
                    : pos != null
                        ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
                        : 'map_tap_hint'.tr,
                style: AppTextStyle.titleMediumSemiBold.copyWith(
                  color: AppColor.blackShade1,
                ),
              );
            }),

            const SizedBox(height: 20),

            CommonButton(
              label: 'map_confirm_btn'.tr,
              onTap: controller.confirmLocation,
              backgroundColor: AppColor.blackColor,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable circle icon button ─────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color backgroundColor;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor = Colors.white,
    this.iconColor = AppColor.blackShade1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
