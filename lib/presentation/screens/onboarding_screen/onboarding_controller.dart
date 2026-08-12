import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/common_widgets/common_bottom_sheet.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/widget/login_bottom_sheet.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  RxInt currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingStepList.length - 1) {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      CommonBottomSheet.show(child: LoginBottomSheet());
    }
  }

  void backPage() {
    if (currentPage.value > 0) {
      pageController.animateToPage(
        currentPage.value - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  RxList<OnboardingStepModel> get onboardingStepList => [
        OnboardingStepModel(
          imagePath: AppAssets.onboardingImage1,
          titleKey: 'onboarding_slide1_title',
          titleAccentKey: 'onboarding_slide1_title2',
          descriptionKey: 'onboarding_slide1_desc',
        ),
        OnboardingStepModel(
          imagePath: AppAssets.onboardingImage2,
          titleKey: 'onboarding_slide2_title',
          titleAccentKey: 'onboarding_slide2_title2',
          descriptionKey: 'onboarding_slide2_desc',
        ),
        OnboardingStepModel(
          imagePath: AppAssets.onboardingImage3,
          titleKey: 'onboarding_slide3_title',
          titleAccentKey: 'onboarding_slide3_title2',
          descriptionKey: 'onboarding_slide3_desc',
        ),
        OnboardingStepModel(
          imagePath: AppAssets.onboardingImage4,
          titleKey: 'onboarding_slide4_title',
          titleAccentKey: 'onboarding_slide4_title2',
          descriptionKey: 'onboarding_slide4_desc',
        ),
      ].obs;
}

class OnboardingStepModel {
  final String? imagePath;
  final String? titleKey;
  final String? titleAccentKey;
  final String? descriptionKey;

  OnboardingStepModel({
    this.imagePath,
    this.titleKey,
    this.titleAccentKey,
    this.descriptionKey,
  });
}
