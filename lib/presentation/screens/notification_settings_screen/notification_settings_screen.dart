import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'notification_settings_controller.dart';

class NotificationSettingsScreen extends GetView<NotificationSettingsController> {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'Notification Settings',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: controller.groups
                  .map((group) => _NotifGroup(group: group))
                  .toList(),
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: GestureDetector(
              onTap: controller.savePreferences,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Save Preferences',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifGroup extends StatelessWidget {
  final NotifGroup group;
  const _NotifGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            group.heading,
            style: AppTextStyle.labelMediumSemiBold.copyWith(
              color: AppColor.coolGrayText,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.lightGreyColor),
          ),
          child: Column(
            children: List.generate(group.items.length, (i) {
              final item = group.items[i];
              final isLast = i == group.items.length - 1;
              return Column(
                children: [
                  _NotifTile(item: item),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColor.lightGreyColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Switch(
              value: item.enabled.value,
              onChanged: (v) => item.enabled.value = v,
              activeColor: Colors.white,
              activeTrackColor: AppColor.brownAccentPrimary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColor.lightGreyColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
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
