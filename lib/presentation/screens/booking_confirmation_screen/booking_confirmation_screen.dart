import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments;
    final ServiceModel service;
    final double total;
    if (rawArgs is Map<String, dynamic>) {
      service = rawArgs['service'] as ServiceModel;
      total = (rawArgs['total'] as num).toDouble();
    } else {
      service = rawArgs as ServiceModel;
      total = 0;
    }

    return MyScaffold(
      backgroundColor: const Color(0xffFAF7F4),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Booking Confirmation', style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColor.brownAccentPrimary, width: 3)),

              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColor.brownAccentPrimary, width: 3), color: AppColor.brownAccentPrimary),
                child: const Icon(Icons.check, color: Colors.white, size: 52),
              ),
            ),
            const SizedBox(height: 28),
            Text('Booking Confirmed!', style: AppTextStyle.headlineLargeBold.copyWith(color: AppColor.blackShade1)),
            const SizedBox(height: 12),
            Text(
              'Your booking has been confirmed and payment of \$${total.toStringAsFixed(0)} has been processed successfully.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText, height: 1.6),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Color(0xffFAF7F4), borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xffA5732F))),
              child: Text('Booking Service ID: SOS-1202', textAlign: TextAlign.center, style: AppTextStyle.titleSmallSemiBold.copyWith(color: AppColor.blackShade1)),
            ),
            const SizedBox(height: 16),
            Text('You will receive an update once a technician is assigned.', textAlign: TextAlign.center, style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
            const Spacer(),
            CommonButton(
              label: 'Back to Home',
              onTap: () => Get.until((r) => r.settings.name == AppRoutes.dashboardScreen),
              backgroundColor: Colors.white,
              foregroundColor: AppColor.brownAccentPrimary,
              border: Border.all(color: AppColor.brownAccentPrimary),
              boxShadow: const [],
            ),
            const SizedBox(height: 12),
            CommonButton(
              label: 'Track Booking →',
              onTap: () => Get.toNamed(AppRoutes.bookingStatusScreen, arguments: service),
              backgroundColor: AppColor.brownAccentPrimary,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
