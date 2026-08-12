import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/support_screen/support_controller.dart';

class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Support',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          ...controller.options.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SupportOptionCard(option: opt),
            ),
          ),
          const SizedBox(height: 16),
          _PriorityBanner(),
        ],
      ),
    );
  }
}

class _SupportOptionCard extends StatelessWidget {
  final dynamic option;
  const _SupportOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: option.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.lightGreyColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EDE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: AppColor.brownAccentPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                  ),
                  if (option.badge != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.badge!,
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColor.brownAccentPrimary, size: 28),
          const SizedBox(height: 12),
          Text(
            'Your support is our priority',
            style: AppTextStyle.titleSmallSemiBold.copyWith(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "We're here to help you 24/7 with expert technical assistance.",
            style: AppTextStyle.bodySmallRegular.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
