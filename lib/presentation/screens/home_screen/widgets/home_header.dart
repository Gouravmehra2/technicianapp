import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class HomeHeader extends StatelessWidget {
  final HomeController controller;

  const HomeHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting + Location ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.greeting}, ${controller.userName}',
                  style: AppTextStyle.titleLargeSemiBold.copyWith(
                    color: AppColor.blackShade1,
                    fontSize: 20
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(onTap: ()=>Get.toNamed(AppRoutes.selectLocationScreen),
                  child: Row(
                    children: [
                      Image.asset(AppAssets.locationImage,height: 14,),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          controller.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: AppColor.coolGrayText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Action icons ───────────────────────────────────────────────
          Row(
            children: [
              // Notification icon
              GestureDetector(
                onTap: (){
                  Get.toNamed(AppRoutes.walletScreen);
                },
                child: _CircleIconButton(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(AppAssets.walletImage,height: 24),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColor.brownAccentPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // notification avatar
              GestureDetector(
                onTap: controller.onNotificationsTapped,
                child: _CircleIconButton(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(AppAssets.notificationImage,height: 24),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColor.brownAccentPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Widget child;

  const _CircleIconButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowGrey.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
