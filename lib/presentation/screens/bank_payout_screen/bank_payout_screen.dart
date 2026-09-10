import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'bank_payout_controller.dart';

class BankPayoutScreen extends GetView<BankPayoutController> {
  const BankPayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MyScaffold(
        backgroundColor: const Color(0xffF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: _BackButton(),
          title: Text(
            'Bank & Payout Details',
            style: AppTextStyle.titleLargeBold.copyWith(
              color: AppColor.blackShade1,
            ),
          ),
        ),
        body: controller.isEditing.value
            ? _EditView(controller: controller)
            : _ReadView(controller: controller),
      ),
    );
  }
}

// ─── Read view ────────────────────────────────────────────────────────────────

class _ReadView extends StatelessWidget {
  final BankPayoutController controller;

  const _ReadView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _SubTitle(),
        const SizedBox(height: 16),
        _EncryptionBanner(),
        const SizedBox(height: 24),

        Text(
          'Bank Details',
          style: AppTextStyle.titleSmallSemiBold.copyWith(
            color: AppColor.blackShade1,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.lightGreyColor),
          ),
          child: Column(
            children: [
              Obx(
                () => _DetailRow(
                  label: 'Bank Name',
                  value: controller.bankName.value,
                ),
              ),
              _Divider(),
              Obx(
                () => _DetailRow(
                  label: 'Account Holder',
                  value: controller.accountHolder.value,
                ),
              ),
              _Divider(),
              Obx(
                () => _DetailRow(
                  label: 'Account Number',
                  value: controller.accountNumber.value,
                ),
              ),
              _Divider(),
              Obx(
                () => _DetailRow(
                  label: 'IFSC Code',
                  value: controller.ifscCode.value,
                ),
              ),
              _Divider(),
              Obx(
                () => _DetailRow(
                  label: 'UPI ID',
                  value: controller.upiId.value,
                  isLast: true,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        GestureDetector(
          onTap: () => controller.isEditing.value = true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColor.brownAccentPrimary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Edit Details',
              textAlign: TextAlign.center,
              style: AppTextStyle.buttonLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.bodyMediumRegular.copyWith(
              color: AppColor.coolGrayText,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyle.titleSmallSemiBold.copyWith(
              color: AppColor.blackShade1,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            color: AppColor.coolGrayText,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ─── Edit view ────────────────────────────────────────────────────────────────

class _EditView extends StatelessWidget {
  final BankPayoutController controller;

  const _EditView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            children: [
              _SubTitle(),
              const SizedBox(height: 16),
              _EncryptionBanner(),
              const SizedBox(height: 20),

              // ─── Account Information ────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT INFORMATION',
                      style: AppTextStyle.labelMediumSemiBold.copyWith(
                        color: AppColor.brownAccentPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Bank Name',
                      controller: controller.bankNameCtrl,
                      hint: 'Swiss Bank',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'Account Holder Name',
                      controller: controller.accountHolderCtrl,
                      hint: 'As per bank records',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'Account Number',
                      controller: controller.accountNumberCtrl,
                      hint: 'Enter your bank account number',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'IFSC Code',
                      controller: controller.ifscCtrl,
                      hint: 'E.G. HDFC0001234',
                    ),
                    const SizedBox(height: 14),
                    _FormField(
                      label: 'UPI ID',
                      controller: controller.upiCtrl,
                      hint: 'username@bankname',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Tax & Compliance ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TAX & COMPLIANCE',
                      style: AppTextStyle.labelMediumSemiBold.copyWith(
                        color: AppColor.brownAccentPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'PAN Number',
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                        ),
                        Text(
                          '* Required',
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _FieldBox(
                      controller: controller.panCtrl,
                      hint: 'ABCDE1234F',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'GST Number',
                            style: AppTextStyle.bodySmallMedium.copyWith(
                              color: AppColor.blackShade1,
                            ),
                          ),
                        ),
                        Text(
                          'Optional',
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: AppColor.coolGrayText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _FieldBox(
                      controller: controller.gstCtrl,
                      hint: '22AAAAA0000A1Z5',
                    ),

                    const SizedBox(height: 20),

                    // Verify Account button
                    Obx(
                      () => GestureDetector(
                        onTap: controller.onVerifyAccount,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.isAccountVerified.value
                                    ? Icons.check_circle_outline
                                    : Icons.verified_outlined,
                                color: AppColor.brownAccentPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.isAccountVerified.value
                                    ? 'Account Verified'
                                    : 'Verify Account',
                                style: AppTextStyle.buttonMedium.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'By saving, you authorize 1app-Technician to initiate a small test transaction of \$1.00 to verify your account details.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.labelSmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),

        // ─── Save Payout Details button (sticky bottom) ─────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          color: const Color(0xffF6F6F6),
          child: Column(
            children: [
              GestureDetector(
                onTap: controller.onSave,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save Payout Details',
                        style: AppTextStyle.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: AppColor.coolGrayText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Bank-grade 256-bit AES Encryption',
                    style: AppTextStyle.labelSmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SubTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Manage your payout preferences',
      style: AppTextStyle.titleSmallSemiBold.copyWith(
        color: AppColor.blackShade1,
        fontSize: 16,
      ),
    );
  }
}

class _EncryptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColor.brownAccentPrimary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Payout Encryption',
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your banking details are encrypted and stored according to industry-standard PCI-DSS compliance protocols. We never share these with third parties.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.5,
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

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.bodySmallMedium.copyWith(
            color: AppColor.blackShade1,
          ),
        ),
        const SizedBox(height: 8),
        _FieldBox(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FieldBox({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyle.bodyMediumRegular.copyWith(
        color: AppColor.blackShade1,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.bodyMediumRegular.copyWith(
          color: AppColor.coolGrayText,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.lightGreyColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.lightGreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.brownAccentPrimary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.lightGreyColor,
      indent: 16,
      endIndent: 16,
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
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColor.blackShade1,
          size: 24,
        ),
      ),
    );
  }
}
