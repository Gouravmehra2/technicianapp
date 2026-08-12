import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/tip_technician_screen/tip_technician_controller.dart';

class TipTechnicianScreen extends GetView<TipTechnicianController> {
  const TipTechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Tip your Technician', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text('Thank Michael for a\ngreat service!', textAlign: TextAlign.center, style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 26, height: 1.3)),
            const SizedBox(height: 12),
            Text('100% of your tips goes to our\ntechnicians only.', textAlign: TextAlign.center, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText, height: 1.6)),
            const SizedBox(height: 32),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...controller.tipOptions.map((amount) {
                  final selected = controller.selectedTip.value == amount;
                  return GestureDetector(
                    onTap: () => controller.selectTip(amount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? AppColor.brownAccentPrimary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor, width: 1.5),
                      ),
                      child: Text('\$$amount', style: AppTextStyle.titleSmallSemiBold.copyWith(color: selected ? Colors.white : AppColor.blackShade1, fontSize: 16)),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => controller.selectTip(-1),
                  child: Obx(() {
                    final selected = !controller.tipOptions.contains(controller.selectedTip.value);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? AppColor.brownAccentPrimary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor, width: 1.5),
                      ),
                      child: Text('Other', style: AppTextStyle.titleSmallSemiBold.copyWith(color: selected ? Colors.white : AppColor.blackShade1, fontSize: 16)),
                    );
                  }),
                ),
              ],
            )),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(text: TextSpan(children: [
                TextSpan(text: 'Add a Note ', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
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
                controller: controller.noteController,
                maxLines: 5,
                maxLength: 200,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  hintText: 'Write a note for the technician...',
                  hintStyle: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                ),
                style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1),
              ),
            ),
            const Spacer(),
            Row(children: [
              Expanded(
                child: CommonButton(
                  label: 'SKIP',
                  onTap: controller.skip,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColor.brownAccentPrimary,
                  border: Border.all(color: AppColor.brownAccentPrimary),
                  boxShadow: const [],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  label: 'SEND TIP',
                  onTap: controller.sendTip,
                  backgroundColor: AppColor.brownAccentPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
