import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class EmailSupportController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void onAttachFile() {
    // TODO: file picker
  }

  void onSendMessage() {
    if (!formKey.currentState!.validate()) return;
    Get.toNamed(AppRoutes.supportThankYouScreen, arguments: 'email');
  }

  void onKnowledgeBase() {}

  void onLiveChat() {
    Get.toNamed(AppRoutes.chatSupportScreen);
  }

  @override
  void onClose() {
    subjectController.dispose();
    orderIdController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
