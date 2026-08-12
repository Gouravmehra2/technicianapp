import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─── Skill Model ─────────────────────────────────────────────────────────────

class SkillItem {
  final String name;
  final RxBool isSelected;

  SkillItem({required this.name, bool selected = false})
      : isSelected = selected.obs;
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ProfessionalInfoController extends GetxController {
  // Primary trade
  final primaryTrade = 'Electrician'.obs;

  // Secondary skills
  final skills = <SkillItem>[
    SkillItem(name: 'AC Repair', selected: true),
    SkillItem(name: 'Wiring', selected: true),
    SkillItem(name: 'Solar Panel', selected: false),
    SkillItem(name: 'Generator', selected: false),
    SkillItem(name: 'CCTV', selected: true),
    SkillItem(name: 'Smart Home', selected: false),
  ];

  // Experience (years)
  final experience = 5.0.obs;

  // Weekly availability (Sun–Sat)
  final availability = List.generate(7, (i) => (i >= 1 && i <= 5).obs);
  final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Working hours
  final workStart = '9:00 AM'.obs;
  final workEnd = '6:00 PM'.obs;

  // Logistics
  final vehicleType = 'Bike'.obs;

  // Languages
  final languages = 'English, Hindi'.obs;

  // Bio
  final bioController = TextEditingController();
  final bioLength = 0.obs;

  // Certificates
  final certificates = [
    {'title': 'Electrical Safety Certificate', 'subtitle': 'Required · PDF/JPG'},
    {'title': 'Trade License', 'subtitle': 'Required · PDF/JPG'},
    {'title': 'Additional Certification', 'subtitle': 'Optional · PDF/JPG'},
  ];

  @override
  void onInit() {
    super.onInit();
    bioController.addListener(() {
      bioLength.value = bioController.text.length;
    });
  }

  void toggleSkill(SkillItem skill) {
    skill.isSelected.value = !skill.isSelected.value;
  }

  void toggleDay(int index) {
    availability[index].value = !availability[index].value;
  }

  void onSave() {
    Get.back();
    Get.snackbar(
      'Saved',
      'Professional information updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    bioController.dispose();
    super.onClose();
  }
}
