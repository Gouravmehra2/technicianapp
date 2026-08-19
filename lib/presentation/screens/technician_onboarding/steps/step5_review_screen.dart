import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/app_shimmer.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/onboarding_widgets.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_controller.dart';

/// Standalone "Under Review" screen navigated to directly from the splash
/// when verificationStatus == 'pending' or 'rejected'.
///
/// Uses [TechnicianOnboardingController] (registered via TechnicianOnboardingBinding)
/// so all socket updates, fetchMe calls and re-upload logic work exactly the
/// same as the embedded _UnderReviewPage inside the PageView flow.
class Step5UnderReviewScreen extends GetView<TechnicianOnboardingController> {
  const Step5UnderReviewScreen({super.key});

  // Map API documentId → icon
  static IconData _iconFor(String documentId) {
    switch (documentId) {
      case 'drivingLicenseFront':
      case 'drivingLicenseBack':
        return Icons.badge_outlined;
      case 'residentialProof':
        return Icons.home_outlined;
      case 'taxInformationW9':
      case 'taxInformation1099':
        return Icons.receipt_long_outlined;
      case 'cvResume':
        return Icons.description_outlined;
      case 'backgroundVerification':
        return Icons.security_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static List<DocumentItem> _prepareDocuments(List<DocumentItem> docs) =>
      docs.where((d) => d.documentId != 'profilePhoto').toList();

  @override
  Widget build(BuildContext context) {
    // Fetch fresh status as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchMe());

    return Obx(() {
      final status = controller.verificationStatus.value;
      final isRejected = status == 'rejected';

      return MyScaffold(
        backgroundColor: Colors.white,
        appBar: onboardingAppBar('Under Review'),
        body: isRejected
            ? _RejectedBody(
                controller: controller,
                prepareDocuments: _prepareDocuments,
                iconFor: _iconFor,
              )
            : _PendingBody(controller: controller),
      );
    });
  }
}

// ── Pending / In-Review body ──────────────────────────────────────────────────

class _PendingBody extends StatelessWidget {
  final TechnicianOnboardingController controller;
  const _PendingBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isFetchingMe.value) {
        return AppShimmer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: const [
                SizedBox(height: 24),
                ShimmerBox(width: 120, height: 120, radius: 60),
                SizedBox(height: 28),
                ShimmerBox(width: 220, height: 28),
                SizedBox(height: 10),
                ShimmerBox(width: 200, height: 16),
                SizedBox(height: 28),
                ShimmerBox(width: double.infinity, height: 160, radius: 12),
              ],
            ),
          ),
        );
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5EFE6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4B896).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search,
                size: 52,
                color: AppColor.brownAccentPrimary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "We're Reviewing Your\nDocuments",
              textAlign: TextAlign.center,
              style: AppTextStyle.headlineLargeBold.copyWith(
                color: AppColor.blackShade1,
                fontSize: 24,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Verification usually takes 24–72 Hours.',
              style: AppTextStyle.bodyMediumRegular
                  .copyWith(color: AppColor.coolGrayText),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Status',
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatusItem(
                    color: Colors.green,
                    title: 'Documents Received',
                    subtitle: 'Completed',
                    isLast: false,
                  ),
                  _StatusItem(
                    color: Colors.orange,
                    title: 'Background and Document Verification',
                    subtitle: 'In progress',
                    isLast: false,
                  ),
                  _StatusItem(
                    color: Colors.grey.shade300,
                    title: 'Final Approval',
                    subtitle: 'Pending',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Rejected body ─────────────────────────────────────────────────────────────

class _RejectedBody extends StatelessWidget {
  final TechnicianOnboardingController controller;
  final List<DocumentItem> Function(List<DocumentItem>) prepareDocuments;
  final IconData Function(String) iconFor;

  const _RejectedBody({
    required this.controller,
    required this.prepareDocuments,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = prepareDocuments(controller.documents.toList());
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + headline
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFAEDE0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.insert_drive_file_outlined,
                              size: 56,
                              color: AppColor.brownAccentPrimary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Documents not Approved',
                      style: AppTextStyle.headlineLargeBold
                          .copyWith(color: AppColor.blackShade1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Please review the feedback below and re-upload.',
                      style: AppTextStyle.bodyMediumRegular
                          .copyWith(color: AppColor.coolGrayText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Required banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Action Required',
                                style: AppTextStyle.titleSmallSemiBold
                                    .copyWith(color: Colors.red),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Some documents need your attention. Please review the feedback below and update your documents to continue.',
                                style: AppTextStyle.bodySmallRegular.copyWith(
                                  color: AppColor.blackShade1,
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
                  // Status timeline
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Status',
                          style: AppTextStyle.titleSmallSemiBold.copyWith(
                            color: AppColor.blackShade1,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatusItem(
                          color: Colors.green,
                          title: 'Documents Received',
                          subtitle: 'Completed',
                          isLast: false,
                        ),
                        _StatusItem(
                          color: Colors.red,
                          title: 'Background and Document Verification',
                          subtitle: 'Rejected',
                          isLast: false,
                        ),
                        _StatusItem(
                          color: Colors.grey.shade300,
                          title: 'Final Approval',
                          subtitle: 'Pending',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Document cards
                  ...docs.map(
                    (doc) => _DocumentCard(
                      doc: doc,
                      icon: iconFor(doc.documentId),
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom CTA
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: CommonButton(
                label: 'Confirm and Update Documents',
                onTap: controller.submitReUpload,
                isLoading: controller.isReUploading.value,
                backgroundColor: AppColor.brownAccentPrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ── Document card (rejected with re-upload / approved) ────────────────────────

class _DocumentCard extends StatefulWidget {
  final DocumentItem doc;
  final IconData icon;
  final TechnicianOnboardingController controller;

  const _DocumentCard({
    required this.doc,
    required this.icon,
    required this.controller,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final isRejected = doc.isRejected;
    final uploadedFileName =
        doc.s3Key.isNotEmpty ? doc.s3Key.split('/').last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRejected
              ? Colors.red.withValues(alpha: 0.5)
              : AppColor.lightGreyColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? const Color(0xFFFFF0EE)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: isRejected ? Colors.red : AppColor.brownAccentPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.label,
                        style: AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isRejected
                              ? Colors.red.withValues(alpha: 0.1)
                              : doc.status.toLowerCase() == 'pending'
                                  ? Colors.yellow.withValues(alpha: 0.2)
                                  : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isRejected
                                ? Colors.red
                                : doc.status.toLowerCase() == 'pending'
                                    ? Colors.orange.withValues(alpha: 0.4)
                                    : Colors.green,
                          ),
                        ),
                        child: Text(
                          isRejected
                              ? 'Rejected'
                              : doc.status.capitalizeFirst.toString(),
                          style: AppTextStyle.labelSmallMedium.copyWith(
                            color: isRejected
                                ? Colors.red
                                : doc.status.toLowerCase() == 'pending'
                                    ? Colors.orange
                                    : Colors.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Approved / pending: show filename
          if (!isRejected && uploadedFileName != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: doc.status.toLowerCase() == 'pending'
                      ? Colors.yellow.withValues(alpha: 0.1)
                      : const Color(0xFFF6FFF6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: doc.status.toLowerCase() == 'pending'
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: doc.status.toLowerCase() == 'pending'
                          ? Colors.orange
                          : Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploadedFileName,
                        style: AppTextStyle.bodySmallMedium
                            .copyWith(color: AppColor.blackShade1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      doc.status.toLowerCase() == 'pending'
                          ? Icons.info
                          : Icons.check_circle,
                      color: doc.status.toLowerCase() == 'pending'
                          ? Colors.orange
                          : Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (!isRejected)
            const SizedBox(height: 14),

          // Rejected: reason + re-upload
          if (isRejected) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reason for rejection',
                      style: AppTextStyle.titleSmallSemiBold
                          .copyWith(color: Colors.red, fontSize: 14),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  doc.rejectionReason?.isNotEmpty == true
                      ? doc.rejectionReason!
                      : 'Document is blurry and some information is not clearly visible.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.blackShade1,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.wb_sunny_outlined,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to fix',
                              style: AppTextStyle.bodySmallMedium
                                  .copyWith(color: AppColor.blackShade1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please upload a clear, high-resolution image.\nAll edges and details should be visible.',
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
              ),
              const SizedBox(height: 12),
              // Re-upload button or chosen file chip
              Obx(() {
                final newPath =
                    widget.controller.reUploadPaths[doc.documentId];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: newPath != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6FFF6),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: Colors.green,
                                  size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  newPath.split('/').last,
                                  style: AppTextStyle.bodySmallMedium
                                      .copyWith(color: AppColor.blackShade1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => widget.controller.reUploadPaths
                                    .remove(doc.documentId),
                                child: const Icon(Icons.close,
                                    color: Colors.red, size: 18),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                widget.controller.pickReUploadFile(
                              doc.documentId,
                            ),
                            icon: const Icon(Icons.refresh,
                                color: Colors.white, size: 18),
                            label: const Text('Re-upload Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Color color;
  final String title, subtitle;
  final bool isLast;
  const _StatusItem({required this.color, required this.title, required this.subtitle, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            if (!isLast) Container(width: 2, height: 36, color: AppColor.lightGreyColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── All Set screen ────────────────────────────────────────────────────────────

class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5EFE6),
              border: Border.all(color: const Color(0xFFE8D5B7), width: 2),
            ),
            child: const Icon(Icons.verified, color: AppColor.brownAccentPrimary, size: 52),
          ),
          const SizedBox(height: 24),
          Text('All Set!', style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 28)),
          const SizedBox(height: 10),
          Text(
            'Your technician account has been\nverified and you are ready to earn.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText, height: 1.6),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: CommonButton(
              label: 'Start Earning',
              onTap: () => Get.offAllNamed(AppRoutes.dashboardScreen),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
