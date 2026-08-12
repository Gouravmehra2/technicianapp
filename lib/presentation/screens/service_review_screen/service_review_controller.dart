import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class ServiceReviewController extends GetxController {
  late ServiceModel service;
  final rating = 0.obs;
  final reviewController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    service = Get.arguments as ServiceModel;
  }

  void setRating(int r) => rating.value = r;

  String get ratingLabel {
    switch (rating.value) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Excellent';
    }
  }

  void submitReview() {
    Get.toNamed(AppRoutes.tipTechnicianScreen, arguments: service);
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
