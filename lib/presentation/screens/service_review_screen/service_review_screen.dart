import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/service_review_screen/service_review_controller.dart';

class ServiceReviewScreen extends GetView<ServiceReviewController> {
  const ServiceReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColor.blackShade1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Green check circle
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
                color: Colors.green,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            Text('Service Completed!', style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 26)),
            const SizedBox(height: 12),
            Text(
              'Thank you for choosing 1APP Services. We technicianapp technicians are always up for you.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText, height: 1.6),
            ),
            const Divider(height: 40),
            Text('Rate Your Experience', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
            const SizedBox(height: 12),
            Text('How was your experience with Michael Johnson?', textAlign: TextAlign.center, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
            const SizedBox(height: 20),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < controller.rating.value;
                return GestureDetector(
                  onTap: () => controller.setRating(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 44,
                      color: filled ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                    ),
                  ),
                );
              }),
            )),
            const SizedBox(height: 8),
            Obx(() => Text(controller.ratingLabel, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText))),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(text: TextSpan(children: [
                TextSpan(text: 'Write a Review ', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                TextSpan(text: '(Optional)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
              ])),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.lightGreyColor),
              ),
              child: TextField(
                controller: controller.reviewController,
                maxLines: 5,
                maxLength: 200,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  hintText: 'Write your review here...',
                  hintStyle: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                ),
                style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1),
              ),
            ),
            const SizedBox(height: 24),
            CommonButton(
              label: 'Submit a Review',
              onTap: controller.submitReview,
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
