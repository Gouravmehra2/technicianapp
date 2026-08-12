import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/payment_screen/payment_controller.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Options', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
          Text('Booking for Jagriti at CXO Suites, Ground Floor, IT Park', style: AppTextStyle.bodySmallRegular.copyWith(color: Colors.white70)),
        ]),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text('To Pay: ', style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1)),
                  Text('\$${controller.total.toStringAsFixed(0)}', style: AppTextStyle.titleSmallSemiBold.copyWith(color: Colors.green)),
                ]),
                GestureDetector(onTap: () {}, child: Text('View Invoice', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle('Recommended Payments'),
                const SizedBox(height: 8),
                _PaymentOptionsList(controller: controller),
                const SizedBox(height: 16),
                _WalletSection(),
                const SizedBox(height: 16),
                _UpiSection(controller: controller),
                const SizedBox(height: 16),
                _CardSection(),
                const SizedBox(height: 16),
                _NetbankingSection(),
                const SizedBox(height: 16),
                _CashOnDelivery(controller: controller),
                const SizedBox(height: 16),
                CommonButton(
                  label: 'Confirm & Book',
                  onTap: controller.confirmPayment,
                  backgroundColor: AppColor.brownAccentPrimary,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontSize: 15));
}

class _PaymentOptionsList extends StatelessWidget {
  final PaymentController controller;
  const _PaymentOptionsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = ['Apple Pay UPI', 'BHIM UPI', 'PayPal Payments'];
    return _WhiteCard(
      child: Column(
        children: items.map((e) {
          final isLast = e == items.last;
          return Column(children: [
            _PaymentRow(label: e, onTap: () => controller.selectMethod(e)),
            if (!isLast) const Divider(height: 1, color: AppColor.lightGreyColor),
          ]);
        }).toList(),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _PaymentRow({required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(children: [
          const Icon(Icons.payment, size: 20, color: AppColor.brownAccentPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1))),
          trailing ?? const Icon(Icons.chevron_right, color: AppColor.coolGrayText, size: 20),
        ]),
      ),
    );
  }
}

class _WalletSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: '1APP ', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary)),
          TextSpan(text: 'Wallet', style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1, fontStyle: FontStyle.italic)),
        ])),
        const SizedBox(height: 8),
        _WhiteCard(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColor.brownAccentPrimary, borderRadius: BorderRadius.circular(4)), child: Text('1APP', style: AppTextStyle.labelSmallMedium.copyWith(color: Colors.white))),
            const SizedBox(width: 10),
            const Expanded(child: Text('Unlock 1APP Wallet', style: TextStyle(fontWeight: FontWeight.w500))),
            Text('LINK >', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
          ]),
        )),
      ],
    );
  }
}

class _UpiSection extends StatelessWidget {
  final PaymentController controller;
  const _UpiSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Pay by UPI'),
        const SizedBox(height: 8),
        _WhiteCard(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                const Icon(Icons.account_balance_outlined, size: 20, color: AppColor.brownAccentPrimary),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pay by any UPI app', style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.blackShade1)),
                  Text('Use any UPI app on the phone to pay', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                ])),
                Text('LINK >', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
              ]),
            ),
            const Divider(height: 1, color: AppColor.lightGreyColor, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['P', 'B', 'A', 'G', 'P', 'P'].map((l) => Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(l, style: AppTextStyle.labelSmallMedium.copyWith(color: AppColor.blackShade1))),
                )).toList(),
              ),
            ),
            const Divider(height: 1, color: AppColor.lightGreyColor, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                const Icon(Icons.qr_code_2, size: 20, color: AppColor.brownAccentPrimary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Pay via QR Code')),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)), child: Text('NEW', style: AppTextStyle.labelSmallMedium.copyWith(color: Colors.white))),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColor.coolGrayText, size: 20),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Credit & Debit Cards'),
        const SizedBox(height: 8),
        _WhiteCard(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            const Icon(Icons.add_circle_outline, size: 20, color: AppColor.brownAccentPrimary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add New Card', style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.brownAccentPrimary)),
              Text('Visa, Mastercard, Rupay & more', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
            ])),
            Text('LINK >', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
          ]),
        )),
      ],
    );
  }
}

class _NetbankingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final banks = ['HDFC\nBank', 'HSBC\nBank', 'SBI\nBank', 'Axis\nBank', 'ICICI\nBank', 'IOB\nBank'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Netbanking'),
        const SizedBox(height: 8),
        _WhiteCard(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: banks.map((b) => Column(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(b.split('\n')[0][0], style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.brownAccentPrimary)))),
                const SizedBox(height: 4),
                Text(b, textAlign: TextAlign.center, style: AppTextStyle.labelSmallRegular.copyWith(color: AppColor.coolGrayText)),
              ])).toList(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.keyboard_arrow_down, color: AppColor.brownAccentPrimary, size: 18),
                Text('View More Bank', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
              ]),
            ),
          ]),
        )),
      ],
    );
  }
}

class _CashOnDelivery extends StatelessWidget {
  final PaymentController controller;
  const _CashOnDelivery({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Cash on Delivery'),
        const SizedBox(height: 8),
        _WhiteCard(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            const Icon(Icons.local_atm_outlined, size: 22, color: Colors.green),
            const SizedBox(width: 12),
            const Expanded(child: Text('Pay by Cash / UPI on Service')),
            Obx(() => Radio<bool>(
              value: true,
              groupValue: controller.cashOnDelivery.value,
              onChanged: (v) => controller.cashOnDelivery.value = true,
              activeColor: AppColor.brownAccentPrimary,
            )),
          ]),
        )),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColor.lightGreyColor)),
    child: child,
  );
}
