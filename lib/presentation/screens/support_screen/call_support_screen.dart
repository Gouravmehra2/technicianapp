import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/support_screen/call_support_controller.dart';

class CallSupportScreen extends GetView<CallSupportController> {
  const CallSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Call Support',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          children: [
            Text(
              "We're here to help",
              style: AppTextStyle.headlineLargeBold.copyWith(
                color: AppColor.blackShade1,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect instantly with our technical experts.',
              style: AppTextStyle.bodyMediumRegular.copyWith(
                color: AppColor.coolGrayText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Ripple circles with phone icon
            _RipplePhoneIcon(),

            const SizedBox(height: 40),

            Text(
              'Speak with our support team',
              style: AppTextStyle.titleLargeBold.copyWith(
                color: AppColor.blackShade1,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Our expert agents are ready to assist you with any technical hurdles or service requests.',
              style: AppTextStyle.bodyMediumRegular.copyWith(
                color: AppColor.coolGrayText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Support hours card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.lightGreyColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EDE8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time_rounded,
                        color: AppColor.brownAccentPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Support Hours',
                            style: AppTextStyle.titleSmallSemiBold
                                .copyWith(color: AppColor.blackShade1)),
                        Text('Monday — Sunday',
                            style: AppTextStyle.bodySmallRegular
                                .copyWith(color: AppColor.coolGrayText)),
                      ],
                    ),
                  ),
                  Text('24 Hours',
                      style: AppTextStyle.titleSmallSemiBold
                          .copyWith(color: AppColor.blackShade1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Wait time badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.lightGreyColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Average wait time: ~ 2 mins',
                      style: AppTextStyle.bodySmallMedium
                          .copyWith(color: AppColor.coolGrayText)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Call now button
            CommonButton(
              label: 'Call Now',
              onTap: controller.onCallNow,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
              leadingIcon: const Icon(Icons.phone_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 14),

            Text(
              'Prefer not to call?',
              style: AppTextStyle.bodySmallRegular
                  .copyWith(color: AppColor.coolGrayText),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: controller.onLiveChat,
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          color: AppColor.brownAccentPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text('Live Chat',
                          style: AppTextStyle.bodySmallMedium.copyWith(
                            color: AppColor.brownAccentPrimary,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('•', style: AppTextStyle.bodySmallRegular
                      .copyWith(color: AppColor.coolGrayText)),
                ),
                GestureDetector(
                  onTap: controller.onEmailUs,
                  child: Row(
                    children: [
                      const Icon(Icons.mail_outline_rounded,
                          color: AppColor.brownAccentPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text('Email Us',
                          style: AppTextStyle.bodySmallMedium.copyWith(
                            color: AppColor.brownAccentPrimary,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RipplePhoneIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _circle(200, alpha: 0.08),
          _circle(160, alpha: 0.12),
          _circle(120, alpha: 0.18),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2EDE8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.phone_outlined,
                color: AppColor.brownAccentPrimary, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, {required double alpha}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.brownAccentPrimary.withValues(alpha: alpha + 0.2),
          width: 1.5,
        ),
        color: AppColor.brownAccentPrimary.withValues(alpha: alpha * 0.3),
      ),
    );
  }
}
