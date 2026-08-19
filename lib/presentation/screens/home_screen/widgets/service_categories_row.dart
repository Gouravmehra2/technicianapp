import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class ServiceCategoriesRow extends StatelessWidget {
  final HomeController controller;

  const ServiceCategoriesRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = controller.serviceCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3.0,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _ServiceCategoryTile(
            icon: category.icon,
            label: category.label,
            onTap: () => controller.onServiceCategoryTapped(category),
          );
        },
      ),
    );
  }
}

class _ServiceCategoryTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceCategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.neutral2,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xffF2F2F2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColor.grey1Color.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xfff2f2f2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(icon, height: 20, width: 20, fit: BoxFit.contain),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.titleMediumMedium.copyWith(
                  color: AppColor.blackShade1,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColor.brownAccentPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
