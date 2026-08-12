import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';

/// MODEL CLASS
class BottomNavItemModel {
  final String label;
  final String filledIcon;
  final String outlineIcon;

  BottomNavItemModel({
    required this.label,
    required this.filledIcon,
    required this.outlineIcon,
  });
}

/// REUSABLE NAV ITEM WIDGET
class AnimatedBottomNavItem extends StatelessWidget {
  final bool isSelected;
  final BottomNavItemModel item;
  final VoidCallback onTap;

  const AnimatedBottomNavItem({
    super.key,
    required this.isSelected,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.brownAccentPrimary
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SvgPicture.asset(
                isSelected
                    ? item.filledIcon
                    : item.outlineIcon,
                key: ValueKey(isSelected),
                width: 24,
              ),
            ),

            /// SHOW TEXT ONLY WHEN SELECTED
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: AppTextStyle.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}