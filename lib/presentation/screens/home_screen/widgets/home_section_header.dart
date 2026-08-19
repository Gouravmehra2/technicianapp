import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final double? fontSize;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyle.titleMediumSemiBold.copyWith(
            color: AppColor.blackShade1,
            fontSize: fontSize ?? 18.0,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'home_view_all'.tr,
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.blackColor1,
                    fontSize: 13,
                  ),),
                 SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColor.blackColor1,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
