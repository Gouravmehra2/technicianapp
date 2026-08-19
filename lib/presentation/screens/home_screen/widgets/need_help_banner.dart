import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/home_screen/home_controller.dart';

class NeedHelpBanner extends StatelessWidget {
  final HomeController controller;

  const NeedHelpBanner({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onNeedHelpSosTapped,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12)
        ),

        /// Inner Glass Container
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),

            border: Border.all(
              color: Colors.white.withOpacity(.5),
              width: 1,
            ),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF707070).withOpacity(.95),
                const Color(0xFF5B5B5B).withOpacity(.85),
                const Color(0xFF8A806B).withOpacity(.70),
              ],
            ),
          ),
          child: Row(
            children: [
              /// Left Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need urgent help?',
                      style: AppTextStyle.titleMediumSemiBold.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Emergency SOS Support',
                      style: AppTextStyle.bodySmallMedium.copyWith(
                        color: Colors.white.withOpacity(.8),
                      ),
                    ),
                  ],
                ),
              ),

              /// SOS Button
              InkWell(onTap:(){
                Get.toNamed(AppRoutes.sosScreen);
              },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8860B),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SOS',
                        style: AppTextStyle.titleMediumSemiBold.copyWith(
                          color: AppColor.blackColor1,
                          fontWeight: FontWeight.w700,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}