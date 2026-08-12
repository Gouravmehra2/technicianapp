import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class TipTechnicianController extends GetxController {
  late ServiceModel service;
  final selectedTip = 10.obs;
  final noteController = TextEditingController();

  final List<int> tipOptions = [5, 10, 20];

  @override
  void onInit() {
    super.onInit();
    service = Get.arguments as ServiceModel;
  }

  void selectTip(int amount) => selectedTip.value = amount;

  void sendTip() {
    Get.until((r) => r.settings.name == AppRoutes.dashboardScreen);
  }

  void skip() {
    Get.until((r) => r.settings.name == AppRoutes.dashboardScreen);
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
