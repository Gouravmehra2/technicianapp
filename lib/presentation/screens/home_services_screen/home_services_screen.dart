import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/home_services_screen/home_services_controller.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_detail_bottom_sheet.dart';

class HomeServicesScreen extends GetView<HomeServicesController> {
  const HomeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => MyScaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColor.brownAccentPrimary,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              controller.appBarTitle,
              style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _TabBar(controller: controller),
                const SizedBox(height: 16),
                _HeroBannerCard(controller: controller),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    controller.selectedTabIndex.value == 0
                        ? 'Explore by Services'
                        : 'Explore by Category',
                    style: AppTextStyle.headlineSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryGrid(controller: controller),
                if (controller.selectedTabIndex.value == 0) ...[
                  const SizedBox(height: 24),
                  _PromoBanner(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Popular Services',
                      style: AppTextStyle.headlineSmallSemiBold.copyWith(
                        color: AppColor.blackShade1,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PopularServicesList(controller: controller),
                ],
              ],
            ),
          ),
        ));
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final HomeServicesController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(controller.tabs.length, (i) {
          final selected = controller.selectedTabIndex.value == i;
          return GestureDetector(
            onTap: () => controller.selectTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColor.brownAccentPrimary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? AppColor.brownAccentPrimary : AppColor.lightGreyColor,
                ),
              ),
              child: Text(
                controller.tabs[i],
                style: AppTextStyle.bodyMediumMedium.copyWith(
                  color: selected ? Colors.white : AppColor.blackShade1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBannerCard extends StatelessWidget {
  final HomeServicesController controller;
  const _HeroBannerCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final banner = controller.currentBanner;
    final highlight = banner.titleHighlight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: const Color(0xffF5EFE6),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (highlight.isNotEmpty)
                    _buildHighlightTitle(banner.title, highlight)
                  else
                    Text(
                      banner.title,
                      style: AppTextStyle.titleLargeBold.copyWith(
                        color: AppColor.blackShade1,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                      height: 1.4,
                    ),
                  ),
                  if (controller.selectedTabIndex.value == 0) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColor.brownAccentPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Book Now',
                          style: AppTextStyle.buttonSmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Image.asset(
              banner.imagePath,
              width: 140,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightTitle(String title, String highlight) {
    final parts = title.split(highlight);
    return RichText(
      text: TextSpan(
        style: AppTextStyle.titleLargeBold.copyWith(
          color: AppColor.blackShade1,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(color: AppColor.brownAccentPrimary),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

// ── Category Grid ─────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final HomeServicesController controller;
  const _CategoryGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cats = controller.visibleCategories;
    final isHomeTab = controller.selectedTabIndex.value == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (_, i) {
              final cat = cats[i];
              final isToggle = isHomeTab &&
                  (cat.label == 'More' || cat.label == 'View Less');
              return GestureDetector(
                onTap: isToggle ? controller.toggleCategories : () {},
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffE7C98B),width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: AppColor.brownAccentPrimary, size: 32),
                      const SizedBox(height: 6),
                      Text(
                        cat.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.labelSmallRegular.copyWith(
                          color: AppColor.blackShade1,
                          fontSize: 11,
                          height: 1.3,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isHomeTab && controller.showAllCategories.value) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: controller.toggleCategories,
              child: Container(
                width: double.infinity / 4,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.keyboard_arrow_up, color: AppColor.brownAccentPrimary),
                    const SizedBox(width: 4),
                    Text('View Less',
                        style: AppTextStyle.bodySmallMedium
                            .copyWith(color: AppColor.brownAccentPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Promo Banner ──────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF5EFE6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE8D9C0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Limited time offer badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffE8D9C0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 12, color: AppColor.brownAccentPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'LIMITED TIME OFFER',
                        style: AppTextStyle.labelSmallMedium.copyWith(
                          color: AppColor.brownAccentPrimary,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: AppTextStyle.headlineLargeBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: 'Home Revamp\n'),
                      TextSpan(
                        text: 'Special',
                        style: TextStyle(color: AppColor.brownAccentPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Give your home a fresh new look\nwith our expert painting services.',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 20% OFF
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '20',
                            style: AppTextStyle.headlineLargeBold.copyWith(
                              color: AppColor.blackShade1,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: '%\nOFF',
                            style: AppTextStyle.labelSmallMedium.copyWith(
                              color: AppColor.blackShade1,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColor.lightGreyColor,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_paint_outlined,
                            size: 16, color: AppColor.brownAccentPrimary),
                        Text(
                          'ON PAINTING\nSERVICES',
                          style: AppTextStyle.labelSmallMedium.copyWith(
                            color: AppColor.blackShade1,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Valid till badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xffE8D9C0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 14, color: AppColor.brownAccentPrimary),
                          Text(
                            'VALID TILL',
                            style: AppTextStyle.labelSmallRegular.copyWith(
                              fontSize: 8,
                              color: AppColor.coolGrayText,
                            ),
                          ),
                          Text(
                            'TONIGHT\nONLY!',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.labelSmallMedium.copyWith(
                              fontSize: 10,
                              color: AppColor.blackShade1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Book Now',
                            style: AppTextStyle.buttonSmall.copyWith(color: Colors.white)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xffE8D9C0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColor.brownAccentPrimary),
                const SizedBox(width: 4),
                Text(
                  'Offer ends at 11:59 PM',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    fontSize: 12,
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

// ── Popular Services List ─────────────────────────────────────────────────────

class _PopularServicesList extends StatelessWidget {
  final HomeServicesController controller;
  const _PopularServicesList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: controller.popularServices
          .map((s) => _PopularServiceTile(service: s))
          .toList(),
    );
  }
}

class _PopularServiceTile extends StatelessWidget {
  final ServiceModel service;
  const _PopularServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              service.image,
              width: 120,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 130,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Starting From',
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    service.price,
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.brownAccentPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xffFFC107)),
                      const SizedBox(width: 2),
                      Text(
                        '${service.rating} (${service.reviews} Reviews)',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => ServiceDetailBottomSheet.show(service),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColor.brownAccentPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'BOOK NOW',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.buttonSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
