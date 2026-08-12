import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';

class SupportThankYouScreen extends StatelessWidget {
  const SupportThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String type = (Get.arguments as String?) ?? 'chat';
    final bool isEmail = type == 'email';

    final String title = isEmail ? 'Thank you for mailing us!' : 'Thank you for connecting!';
    final String subtitle = isEmail
        ? 'We will get back to you within 24 to 48 hours'
        : 'We hope your issue was resolved.\nReach out anytime if you need further time.';

    return MyScaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 100,
              color: AppColor.brownAccentPrimary,
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: AppTextStyle.headlineLargeBold.copyWith(
                color: AppColor.blackShade1,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTextStyle.bodyMediumRegular.copyWith(
                color: AppColor.coolGrayText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CommonButton(
              label: 'Close',
              onTap: () => Get.back(),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
