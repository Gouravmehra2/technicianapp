import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_detail_bottom_sheet.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController(), permanent: false);

    return MyScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'All Services',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          _LeftCategoryRail(controller: controller),
          Expanded(child: _RightServiceList(controller: controller)),
        ],
      ),
    );
  }
}

class _LeftCategoryRail extends StatelessWidget {
  final ServiceController controller;

  const _LeftCategoryRail({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.22,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xffA5732F).withValues(alpha: 0.07),
            width: 2.0,
          ),
        ),
      ),
      child: Obx(() {
        final selected = controller.selectedIndex.value;
        return ListView.separated(
          controller: controller.leftScrollController,
          itemCount: controller.categories.length,
          separatorBuilder: (context, index) {
            return Divider(
              color: Color(0xffA5732F).withValues(alpha: 0.07),
              thickness: 2.0,
            );
          },
          itemBuilder: (_, i) {
            final isSelected = selected == i;
            return GestureDetector(
              onTap: () => controller.onCategoryTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? null : Colors.white,
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Color(0xffF8F4EE).withValues(alpha: 0.60),
                                  Color(0xffEDE3D3).withValues(alpha: 0.80),
                                  Color(0xffDCC5A3),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: SvgPicture.asset(
                        isSelected
                            ? controller.categories[i].selectedImage
                            : controller.categories[i].image,
                        height: 30,
                        width: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.categories[i].name,
                      style: AppTextStyle.labelSmallRegular.copyWith(
                        color: isSelected
                            ? AppColor.brownAccentPrimary
                            : AppColor.coolGrayText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _RightServiceList extends StatelessWidget {
  final ServiceController controller;

  const _RightServiceList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller.rightScrollController,
      slivers: [
        ...List.generate(controller.categories.length, (i) {
          final cat = controller.categories[i];
          return SliverToBoxAdapter(
            key: controller.categoryKeys[i],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: AppTextStyle.titleLargeBold.copyWith(
                      color: AppColor.blackColor1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      for (int j = 0; j < cat.services.length; j += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _ServiceCard(service: cat.services[j])),
                                const SizedBox(width: 10),
                                if (j + 1 < cat.services.length)
                                  Expanded(child: _ServiceCard(service: cat.services[j + 1]))
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SliverToBoxAdapter(child: _SuggestServiceBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE6E6E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.25,
                child: Image.asset(
                  service.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// TITLE
            Text(
              service.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.titleSmallSemiBold.copyWith(fontSize: 13),
            ),

            const SizedBox(height: 6),

            /// STARTING FROM
            Text(
              'Starting From',
              style: AppTextStyle.labelSmallRegular.copyWith(
                fontSize: 10,
                color: Color(0xff000000).withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 2),

            /// PRICE
            Text(
              service.price,
              style: AppTextStyle.titleLargeBold.copyWith(
                  fontSize: 13,color: AppColor.brownAccentPrimary
              ),
            ),

            const SizedBox(height: 6),

            /// RATING
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xffFFC107)),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    '${service.rating} (${service.reviews} Reviews)',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.labelSmallRegular.copyWith(
                      fontSize: 10,
                      color: Color(0xff000000).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: () => ServiceDetailBottomSheet.show(service),
              child: Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    'BOOK NOW '.tr,
                    style: AppTextStyle.buttonLarge.copyWith(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestServiceBanner extends StatelessWidget {
  const _SuggestServiceBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(width: 32, height: 1, color: AppColor.coolGrayText),
              const SizedBox(width: 8),
              Text(
                'HEY, JAGRITI!',
                style: AppTextStyle.labelSmallMedium.copyWith(
                  color: AppColor.coolGrayText,
                  letterSpacing: 1,
                ),
              ),
              // const SizedBox(width: 8),
              // Container(width: 32, height: 1, color: AppColor.coolGrayText),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: AppTextStyle.displayMediumBold.copyWith(
                color: AppColor.coolGrayText,
              ),
              children: [
                const TextSpan(text: "Didn't find\nwhat you were\n"),
                TextSpan(
                  text: 'Looking for?',
                  style: AppTextStyle.displayMediumBold.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Suggest us a service & we'll look into it",
            style: AppTextStyle.bodyMediumRegular.copyWith(
              color: AppColor.coolGrayText,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColor.brownAccentPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Suggest us a Service',
              style: AppTextStyle.bodyMediumMedium.copyWith(
                color: AppColor.brownAccentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
