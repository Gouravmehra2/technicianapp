import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'identity_verification_controller.dart';

class IdentityVerificationScreen extends GetView<IdentityVerificationController> {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _BackButton(),
        title: Text(
          'Identity Verification',
          style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic_outlined, color: AppColor.coolGrayText, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // ─── Status banner ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.blackShade1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL STATUS',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Verified',
                      style: AppTextStyle.headlineLargeBold.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: AppColor.greenColor, size: 22),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Great! All required documents are verified and you're ready for jobs.",
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Last checked strip ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.brownAccentPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'Last checked: ${controller.lastChecked.value}',
                        style: AppTextStyle.bodySmallMedium.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    'ID: ${controller.verificationId.value}',
                    style: AppTextStyle.bodySmallMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Documents ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents',
                style: AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.blackShade1,
                  fontSize: 16,
                ),
              ),
              Text(
                '${controller.documents.where((d) => d.isVerified.value).length} of ${controller.documents.length} Completed',
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: AppColor.coolGrayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...controller.documents.map(
            (doc) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.lightGreyColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(doc.icon, color: AppColor.brownAccentPrimary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: AppTextStyle.titleSmallSemiBold.copyWith(
                            color: AppColor.blackShade1,
                          ),
                        ),
                        Obx(
                          () => Text(
                            doc.isVerified.value ? 'Verified' : 'Pending',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: doc.isVerified.value
                                  ? AppColor.green2Color
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => doc.isVerified.value
                        ? const Icon(Icons.check_circle, color: AppColor.greenColor, size: 22)
                        : const Icon(Icons.pending_outlined, color: Colors.orangeAccent, size: 22),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Checks & Verification ──────────────────────────────────
          Text(
            'CHECKS & VERIFICATION',
            style: AppTextStyle.labelMediumSemiBold.copyWith(
              color: AppColor.coolGrayText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _CheckCard(
                    icon: Icons.face_outlined,
                    title: 'Selfie Verification',
                    status: controller.selfieVerified.value ? 'VERIFIED' : 'PENDING',
                    isDone: controller.selfieVerified.value,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _CheckCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Background Check',
                    status: controller.backgroundCheckCompleted.value ? 'COMPLETED' : 'PENDING',
                    isDone: controller.backgroundCheckCompleted.value,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Information Security note ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, color: AppColor.coolGrayText, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Information Security',
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your personal information is stored securely using industry-standard encryption. We only use these details for identity verification and safety purposes.',
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
          ),

          const SizedBox(height: 20),

          // Contact support link
          Center(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.helpSupportScreen),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Questions about verification? ',
                      style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                    ),
                    TextSpan(
                      text: 'Contact Support',
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final bool isDone;

  const _CheckCard({
    required this.icon,
    required this.title,
    required this.status,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColor.brownAccentPrimary, size: 26),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone ? AppColor.greenColor : Colors.orangeAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.hourglass_empty,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTextStyle.labelSmallMedium.copyWith(
              color: isDone ? AppColor.green2Color : Colors.orangeAccent,
              letterSpacing: 0.5,
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
