import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

// ── Step indicator ────────────────────────────────────────────────────────────

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final List<String> labels;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.labels = const ['Documents', 'Skills', 'Bank', 'Review'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // circles + lines row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) {
              final done = (i ~/ 2) < currentStep - 1;
              return Expanded(
                child: Container(
                  height: 2,
                  color: done ? AppColor.blackShade1 : AppColor.lightGreyColor,
                ),
              );
            }
            final step = i ~/ 2 + 1;
            final done = step < currentStep;
            final active = step == currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (done || active) ? AppColor.blackShade1 : Colors.white,
                border: Border.all(
                  color: (done || active) ? AppColor.blackShade1 : AppColor.lightGreyColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                    color: (done || active) ? Colors.white : AppColor.coolGrayText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) return const Expanded(child: SizedBox());
            final step = i ~/ 2 + 1;
            final done = step < currentStep;
            final active = step == currentStep;
            return Text(
              labels[i ~/ 2],
              textAlign: TextAlign.center,
              style: AppTextStyle.labelSmallRegular.copyWith(
                color: (done || active) ? AppColor.blackShade1 : AppColor.coolGrayText,
                fontSize: 10,
                fontWeight: FontWeight.w700
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Shared AppBar builder ─────────────────────────────────────────────────────

AppBar onboardingAppBar(String title) => AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: title == 'Under Review' ? SizedBox.shrink():
      GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_left, color: Colors.black87),
        ),
      ),
      title: Text(title, style: AppTextStyle.titleLargeBold.copyWith(color: Colors.black87)),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.supportScreen),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_outlined, color: Colors.black87, size: 20),
          ),
        ),
      ],
    );

// ── Dashed upload box ─────────────────────────────────────────────────────────

Future<bool> showDeleteFileDialog() async {
  return await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete File?'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel', style: TextStyle(color: AppColor.coolGrayText)),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;
}

class UploadBox extends StatelessWidget {
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const UploadBox({super.key, this.filePath, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (filePath != null) {
      final fileName = filePath!.split('/').last;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FFF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_outlined, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final confirmed = await showDeleteFileDialog();
                if (confirmed) onDelete?.call();
              },
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_upload_outlined, color: AppColor.brownAccentPrimary, size: 26),
              ),
              const SizedBox(height: 10),
              Text('Click to upload', style: AppTextStyle.bodyMediumMedium.copyWith(color: AppColor.brownAccentPrimary)),
              const SizedBox(height: 4),
              Text('PDF, JPG, or PNG (max. 10MB)', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.brownAccentPrimary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 8.0, gap = 5.0, r = 12.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(r)));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Info card ─────────────────────────────────────────────────────────────────

class InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const InfoCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.brownAccentPrimary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColor.brownAccentPrimary, size: 16),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText, height: 1.5)),
        ],
      ),
    );
  }
}

// ── Step header card ──────────────────────────────────────────────────────────

class StepHeaderCard extends StatelessWidget {
  final String stepLabel;
  final String title;
  final String description;

  const StepHeaderCard({super.key, required this.stepLabel, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(stepLabel, style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.coolGrayText)),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1, fontSize: 20)),
          const SizedBox(height: 6),
          Text(description, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText, height: 1.5)),
        ],
      ),
    );
  }
}
