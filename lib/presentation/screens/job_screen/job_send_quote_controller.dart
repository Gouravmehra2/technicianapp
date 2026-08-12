import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class JobSendQuoteController extends GetxController {
  final baseQuoteController = TextEditingController();
  final estimatedCompletionController = TextEditingController();
  final noteController = TextEditingController();

  // Additional charge entries: label → amount text controller
  final additionalCharges = <MapEntry<String, TextEditingController>>[
    MapEntry('Materials / Parts', TextEditingController()),
    MapEntry('Travel Fee', TextEditingController()),
    MapEntry('Emergency Fee', TextEditingController()),
  ];

  final enabledCharges = <String>{}.obs;

  void toggleCharge(String key) {
    if (enabledCharges.contains(key)) {
      enabledCharges.remove(key);
    } else {
      enabledCharges.add(key);
    }
  }

  void sendQuote() {
    Get.toNamed(AppRoutes.jobQuoteSentScreen);
  }

  @override
  void onClose() {
    baseQuoteController.dispose();
    estimatedCompletionController.dispose();
    noteController.dispose();
    for (final entry in additionalCharges) {
      entry.value.dispose();
    }
    super.onClose();
  }
}
