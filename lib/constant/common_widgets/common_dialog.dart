import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';

class CommonDialog {
  static Future<T?> show<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Shows a bottom-sheet style dialog for picking image from gallery or camera.
  /// Returns the picked [XFile] or null if cancelled.
  static Future<XFile?> showImagePickerDialog() {
    return Get.dialog<XFile>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackShade2.withOpacity(.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header — matches project AppBar theming
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upload Profile Photo",
                            style: AppTextStyle.titleLargeSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Choose how you'd like to add your profile photo",
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: Get.back,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// Options
                    Row(
                      children: [
                        Expanded(
                          child: _ImageSourceCard(
                            icon: Icons.photo_library_outlined,
                            title: "Gallery",
                            subtitle: "Select Photo",
                            onTap: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              Get.back(result: image);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ImageSourceCard(
                            icon: Icons.camera_alt_outlined,
                            title: "Camera",
                            subtitle: "Take Photo",
                            onTap: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              Get.back(result: image);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    CommonButton(
                      label: "Cancel",
                      onTap: Get.back,
                      backgroundColor: AppColor.brownAccentPrimary,
                      height: 46,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColor.lightGreyColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColor.brownAccentPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: AppTextStyle.titleSmallSemiBold,
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySmallRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
