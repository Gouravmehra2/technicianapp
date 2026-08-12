import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class ServiceDetailBottomSheet extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailBottomSheet({super.key, required this.service});

  static void show(ServiceModel service) {
    Get.bottomSheet(
      ServiceDetailBottomSheet(service: service),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColor.lightGreyColor, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(service.image, width: 130, height: 110, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 130, height: 110, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey, size: 40))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xffFFC107)),
                              const SizedBox(width: 4),
                              Text('${service.rating} (${service.reviews} Reviews)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              Text(service.price, style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.brownAccentPrimary, fontSize: 24)),
                              // const SizedBox(width: 12),
                              // Container(width: 1, height: 20, color: AppColor.lightGreyColor),
                              // const SizedBox(width: 12),
                              // const Icon(Icons.access_time_rounded, size: 16, color: AppColor.coolGrayText),
                              // const SizedBox(width: 4),
                              // Text('45 - 60 min', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                            ]),

                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // What's Included
                  Text("What's Included", style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                  const SizedBox(height: 16),
                  _WhatIncludedRow(),
                  const Divider(height: 32),

                  // About
                  Text('About This Service', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "Our experts will install your smart thermostat and ensure it's configured for maximum comfort and energy savings. We work with all major brands including Nest, Ecobee, Honeywell and more.",
                    style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1, height: 1.6),
                  ),
                  const Divider(height: 32),

                  // Customer Review
                  Text('Customer Review', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 16)),
                  const SizedBox(height: 12),
                  _ReviewCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Book Now button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            color: Colors.white,
            child: CommonButton(
              label: 'Book Now',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.bookServiceScreen, arguments: service);
              },
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
              trailingIcon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatIncludedRow extends StatelessWidget {
  final List<Map<String, dynamic>> items = const [
    {'icon': Icons.build_outlined, 'label': 'Device\nMounting'},
    {'icon': Icons.electrical_services_outlined, 'label': 'Wiring\nSetup'},
    {'icon': Icons.wifi_outlined, 'label': 'App\nPairing'},
    {'icon': Icons.settings_outlined, 'label': 'Configuration'},
    {'icon': Icons.checklist_outlined, 'label': 'Testing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) => Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColor.brownAccentPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: AppColor.brownAccentPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(item['label'] as String, textAlign: TextAlign.center, style: AppTextStyle.labelSmallRegular.copyWith(color: AppColor.blackShade1, fontSize: 11)),
        ],
      )).toList(),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade300, child: Image.asset(AppAssets.customerImage,fit: BoxFit.cover,)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Row(children: List.generate(5, (i) => const Icon(Icons.star_rounded, size: 16, color: Color(0xffFFC107)))),
                  const SizedBox(width: 6),
                  const Text('5.0', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  Text('2 days ago', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                ]),
                const SizedBox(height: 6),
                Text('Technician arrived on time and set up my thermostat perfectly. Great service and very professional!', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.blackShade1, height: 1.5)),
                const SizedBox(height: 4),
                Text('- Michael R.', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
