import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

class Step4BankScreen extends GetView<TechnicianOnboardingController> {
  const Step4BankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: onboardingAppBar('Bank Details'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingStepIndicator(currentStep: 4),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bank Details', style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Enter your bank details for payouts.', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Label('Account Holder Name'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.accountNameController, hintText: 'As per bank records', borderRadius: 12),
                  const SizedBox(height: 16),
                  _Label('Bank Name'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.bankNameController, hintText: 'e.g. HDFC Bank', borderRadius: 12),
                  const SizedBox(height: 16),
                  _Label('Account Number'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.accountNumberController, hintText: 'XXXXXXXXXXXXX', borderRadius: 12, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _Label('IFSC Code'),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.ifscController, hintText: 'SBIN0000123', borderRadius: 12),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Label('UPI ID'),
                      const SizedBox(width: 6),
                      Text('(optional)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CommonTextFormField(controller: controller.upiController, hintText: 'name@upi', borderRadius: 12),
                  const SizedBox(height: 16),
                  Obx(() {
                    final path = controller.cancelledCheque.value;
                    if (path != null) {
                      final name = path.split('/').last;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FFF6),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final confirmed = await showDeleteFileDialog();
                                if (confirmed) controller.cancelledCheque.value = null;
                              },
                              child: const Icon(Icons.close, color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => controller.pickAndSet(controller.cancelledCheque),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColor.lightGreyColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cancelled Cheque', style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.blackShade1)),
                            Text('Upload', style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.brownAccentPrimary)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Obx(() => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: CommonButton(
              label: 'Next →',
              onTap: controller.submitBankDetails,
              isLoading: controller.isSubmittingBank.value,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          )),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.blackShade1));
}
