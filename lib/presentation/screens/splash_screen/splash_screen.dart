import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/presentation/screens/splash_screen/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Center(
                child: Image.asset(
                  AppAssets.appLogoIcon,
                ).paddingSymmetric(horizontal: 20),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: Obx(() {
                  final text = controller.locationText.value;
                  return AnimatedSlide(
                    offset: text.isEmpty ? const Offset(0, 1) : Offset.zero,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: text.isEmpty ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Transform.rotate(
                              angle: 45,
                              child: Icon(
                                Icons.navigation_sharp,
                                color: Colors.brown.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
