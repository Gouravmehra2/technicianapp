import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'add_money_controller.dart';

class AddMoneyScreen extends GetView<AddMoneyController> {
  const AddMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Add Money', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AmountSection(controller: controller),
          const SizedBox(height: 12),
          _ProceedButton(controller: controller),
          const SizedBox(height: 4),
          _PaymentMethodSection(controller: controller),
          const SizedBox(height: 12),
          _AddNewPaymentMethod(),
          const SizedBox(height: 16),
          _DisclaimerText(),
        ],
      ),
    );
  }
}

class _AmountSection extends StatelessWidget {
  final AddMoneyController controller;
  const _AmountSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ENTER AMOUNT', style: AppTextStyle.labelSmallRegular.copyWith(color: AppColor.coolGrayText, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('\$', style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.brownAccentPrimary, fontSize: 28)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyle.displayLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 36),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColor.brownAccentPrimary)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColor.brownAccentPrimary, width: 2)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColor.brownAccentPrimary)),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final amount = int.tryParse(v);
                    controller.selectedAmount.value = amount;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.quickAmounts.map((amount) {
              final isSelected = controller.selectedAmount.value == amount;
              return GestureDetector(
                onTap: () => controller.selectQuickAmount(amount),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.brownAccentPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor),
                  ),
                  child: Text(
                    '\$$amount',
                    style: AppTextStyle.bodyMediumMedium.copyWith(
                      color: isSelected ? Colors.white : AppColor.brownAccentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  final AddMoneyController controller;
  const _ProceedButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.proceedToPay,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.brownAccentPrimary,
          border: Border.all(color: Colors.blue.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Proceed to Pay', style: AppTextStyle.buttonLarge.copyWith(color: Colors.white)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final AddMoneyController controller;
  const _PaymentMethodSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.blue.shade200, width: 1.5),
          right: BorderSide(color: Colors.blue.shade200, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Select Payment Method', style: AppTextStyle.titleMediumSemiBold.copyWith(color: AppColor.blackShade1)),
          ),
          ...List.generate(controller.paymentMethods.length, (i) {
            return Column(
              children: [
                const Divider(height: 1, color: AppColor.lightGreyColor),
                Obx(() => _PaymentMethodTile(
                  method: controller.paymentMethods[i],
                  isSelected: controller.selectedMethodIndex.value == i,
                  onTap: () => controller.selectedMethodIndex.value = i,
                )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentMethodTile({required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method.icon, color: AppColor.brownAccentPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                  Text(method.subtitle, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                ],
              ),
            ),
            isSelected
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColor.brownAccentPrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.lightGreyColor, width: 2),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AddNewPaymentMethod extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF9F9F9),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        border: Border.all(color: AppColor.brownAccentPrimary.withOpacity(0.4), width: 1.5, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.credit_card_outlined, color: AppColor.brownAccentPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Text('Add New Payment Method', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
        ],
      ),
    );
  }
}

class _DisclaimerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: AppColor.brownAccentPrimary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Money added to your 1App wallet can be used for instant bookings and payments across all network services. Standard T&Cs apply.',
            style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
          ),
        ),
      ],
    );
  }
}
