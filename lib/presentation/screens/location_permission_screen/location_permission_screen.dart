import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/location_permission_screen/location_permission_controller.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationPermissionController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MyScaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradient),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadowGrey.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'location_perm_title'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: AppColor.blackShade1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'location_perm_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.grey1Color,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CommonButton(
                      label: 'location_perm_allow_btn'.tr,
                      onTap: () => _onAllowTapped(controller),
                      backgroundColor: AppColor.blackColor,
                      foregroundColor: Colors.white,
                      leadingIcon: const Icon(
                        Icons.near_me_rounded,
                        color: AppColor.brownAccentPrimary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CommonButton(
                      label: 'location_perm_manual_btn'.tr,
                      onTap: _onEnterManuallyTapped,
                      backgroundColor: AppColor.lightGrey2Color,
                      foregroundColor: AppColor.blackShade1,
                      border: Border.all(color: const Color(0xffCFC4C5)),
                      boxShadow: const [],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAllowTapped(LocationPermissionController controller) async {
    Get.dialog(
      const _FetchingLocationDialog(),
      barrierDismissible: false,
    );
    await controller.requestLocationAndFetch();
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void _onEnterManuallyTapped() {
    Get.toNamed(AppRoutes.locationDetailScreen);
  }
}

class _FetchingLocationDialog extends StatefulWidget {
  const _FetchingLocationDialog();

  @override
  State<_FetchingLocationDialog> createState() =>
      _FetchingLocationDialogState();
}

class _FetchingLocationDialogState extends State<_FetchingLocationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationPermissionController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowGrey.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  size: 36,
                  color: AppColor.brownAccentPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fetching your location…',
              style: AppTextStyle.titleMediumSemiBold.copyWith(
                color: AppColor.blackShade1,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final addr = controller.address.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: addr.isEmpty
                    ? Text(
                        'Please wait a moment',
                        key: const ValueKey('waiting'),
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.grey1Color,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        addr,
                        key: const ValueKey('address'),
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.brownAccentPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
              );
            }),
            const SizedBox(height: 20),
            const LinearProgressIndicator(
              backgroundColor: AppColor.lightGreyColor,
              color: AppColor.brownAccentPrimary,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }
}
