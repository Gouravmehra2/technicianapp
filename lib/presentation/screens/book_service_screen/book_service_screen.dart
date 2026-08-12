import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/book_service_screen/book_service_controller.dart';

class BookServiceScreen extends GetView<BookServiceController> {
  const BookServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Book Service',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ServiceSummaryCard(controller: controller),
                  const SizedBox(height: 20),
                  _SectionTitle('Select Location'),
                  const SizedBox(height: 10),
                  _LocationCard(),
                  const SizedBox(height: 20),
                  _SectionTitle('Choose Date'),
                  const SizedBox(height: 10),
                  _DateSelector(controller: controller),
                  const SizedBox(height: 12),
                  _InfoChip(
                    icon: Icons.info_outline,
                    text: 'Technician will be assigned soon',
                  ),
                  const SizedBox(height: 12),
                  _CouponChip(),
                  const SizedBox(height: 20),
                  _SectionTitle('Payment Breakout'),
                  const SizedBox(height: 10),
                  _PaymentBreakout(controller: controller),
                  const SizedBox(height: 12),
                  _ContactRow(),
                  const SizedBox(height: 16),
                  _CancellationPolicy(),
                ],
              ),
            ),
          ),
          _BottomBar(controller: controller),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: AppTextStyle.titleLargeBold.copyWith(color: AppColor.blackShade1),
  );
}

class _ServiceSummaryCard extends StatelessWidget {
  final BookServiceController controller;

  const _ServiceSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              controller.service.image,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  controller.service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xffFFC107)),
                    const SizedBox(width: 2),
                    Text(
                      '${controller.service.rating} (${controller.service.reviews} Reviews)',
                      style: AppTextStyle.bodySmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                        fontSize: 11
                      ),
                    ),
                  ],
                ),
                Text(
                  controller.service.price,
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.brownAccentPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Within 1 hour On-Site Service',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    fontSize: 11
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

class _LocationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xffFFF6ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: AppColor.brownAccentPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.blackShade2,
                  ),
                ),
                Text(
                  'CXO Suites, Ground Floor, IT Park, Plot No.16',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.blackShade3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.selectLocationScreen);
            },
            child: Text(
              'Change >',
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.brownAccentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final BookServiceController controller;

  const _DateSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => EasyDateTimeLine(
        initialDate: controller.selectedDate.value,

        headerProps: const EasyHeaderProps(showHeader: false),

        activeColor: AppColor.brownAccentPrimary,

        onDateChange: (selectedDate) {
          controller.selectedDate.value = selectedDate;
        },

        dayProps: EasyDayProps(
          height: 85,
          width: 65,

          activeDayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.brownAccentPrimary,
                width: 1.5,
              ),
            ),
            dayNumStyle: const TextStyle(
              color: AppColor.brownAccentPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            dayStrStyle: const TextStyle(
              color: AppColor.brownAccentPrimary,
              fontSize: 12,
            ),
            monthStrStyle: const TextStyle(
              color: AppColor.brownAccentPrimary,
              fontSize: 12,
            ),
          ),

          inactiveDayStyle: DayStyle(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            dayNumStyle: const TextStyle(
              color: AppColor.blackShade1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            dayStrStyle: const TextStyle(
              color: AppColor.coolGrayText,
              fontSize: 12,
            ),
            monthStrStyle: const TextStyle(
              color: AppColor.coolGrayText,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xffFAF7F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColor.coolGrayText),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyle.bodySmallRegular.copyWith(
              color: AppColor.coolGrayText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppAssets.offerIcon,width: 24,),
          // const Icon(
          //   Icons.local_offer_outlined,
          //   size: 20,
          //   color: AppColor.brownAccentPrimary,
          // ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You saved \$5 with 'NewUser'",
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.blackShade1,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View all coupons >',
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Remove',
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBreakout extends StatelessWidget {
  final BookServiceController controller;

  const _PaymentBreakout({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        children: [
          _BreakoutRow(
            'Service Fee',
            '\$${controller.serviceFee.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _BreakoutRow(
            'Taxes & Fees',
            '\$${controller.taxesFees.toStringAsFixed(0)}',
            showInfo: true,
          ),
          const SizedBox(height: 10),
          _BreakoutRow(
            'Discount',
            '\$${controller.discount.toStringAsFixed(0)}',
          ),
          const Divider(height: 20),
          _BreakoutRow(
            'Total Amount',
            '\$${controller.total.toStringAsFixed(0)}',
            isBold: true,
            valueColor: AppColor.brownAccentPrimary,
          ),
        ],
      ),
    );
  }
}

class _BreakoutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool showInfo;
  final Color? valueColor;

  const _BreakoutRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.showInfo = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: isBold
                  ? AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                    )
                  : AppTextStyle.bodyMediumRegular.copyWith(
                      color: AppColor.blackShade1,
                    ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColor.coolGrayText,
              ),
            ],
          ],
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyle.titleSmallSemiBold.copyWith(
                  color: valueColor ?? AppColor.blackShade1,
                  fontSize: 15,
                )
              : AppTextStyle.bodyMediumRegular.copyWith(
                  color: valueColor ?? AppColor.blackShade1,
                ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_outlined,
            size: 18,
            color: AppColor.brownAccentPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: AppColor.blackShade1,
                ),
                children: [
                  TextSpan(
                    text: 'JAGRITI SACHDEVA',
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.blackShade1,
                      fontSize: 13
                    ),
                  ),
                  TextSpan(
                    text: ', ',
                  ),
                  TextSpan(
                    text: '+91 9876543210',
                    style: AppTextStyle.bodyLargeRegular.copyWith(
                        color: AppColor.blackShade1,
                        fontSize: 13,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Edit',
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.brownAccentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CANCELLATION POLICY',
          style: AppTextStyle.labelMediumSemiBold.copyWith(
            color: AppColor.coolGrayText,
            letterSpacing: 1,
            fontSize: 16
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Help us to reduce the time of a technician by avoiding service cancellation. A 100% cancellation charge will be applied if the technician is assigned this helps us compensate the technician for their time and service',
          style: AppTextStyle.bodySmallRegular.copyWith(
            color: AppColor.coolGrayText,
            height: 1.5,
            fontSize: 13
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final BookServiceController controller;

  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColor.lightGreyColor)),
      ),
      child: Row(
        spacing: 10,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAYING VIA',
                style: AppTextStyle.labelSmallRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.apple, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'APPLE PAY',
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ],
          ),
          Expanded(
            child: CommonButton(
              label: 'Confirm & Book',
              onTap: controller.confirmAndBook,
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
              height: 48,
              borderRadius: 8.0,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 10),
    );
  }
}
