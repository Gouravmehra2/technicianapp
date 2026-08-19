import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import '../technician_home_controller.dart';

class TechnicianHeader extends StatelessWidget {
  final TechnicianHomeController controller;

  const TechnicianHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with online dot
          Stack(
            // clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(AppAssets.personImage),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Greeting + name + badge + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   controller.greeting,
                //   style: AppTextStyle.bodySmallMedium.copyWith(
                //     color: Colors.white,
                //   ),
                // ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.userName.value.capitalizeFirst ?? '',
                      style: AppTextStyle.titleLargeBold.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 1),
                // ── Current location chip (tappable) ──────────────────
                Obx(() {
                  final loc = controller.currentLocation.value;
                  return GestureDetector(
                    onTap: controller.onLocationTapped,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            loc.isEmpty ? 'Set your location' : loc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.labelSmallMedium.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: controller.onNotificationTapped,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: AppTextStyle.labelSmallMedium.copyWith(
                          color: AppColor.brownAccentPrimary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
