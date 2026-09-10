import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class PersonalInformationController extends GetxController {
  final nameController = TextEditingController(text: 'Jagriti Sachdeva');
  final phoneController = TextEditingController(text: '+91 94639 XXXXX');
  final emailController = TextEditingController(text: 'jags.jagriti12@gmail.com');
  final altPhoneController = TextEditingController();

  final gender = 'Female'.obs;
  final dob = '12 Feb 2003'.obs;

  String countryCode = '+91';

  void onCountryChanged(CountryCode code) {
    countryCode = code.dialCode ?? '+91';
  }

  Future<void> pickDate(BuildContext context) async {
    final parts = dob.value.split(' ');
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final initial = DateTime(
      int.parse(parts[2]),
      months.indexOf(parts[1]) + 1,
      int.parse(parts[0]),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColor.brownAccentPrimary,
            onPrimary: Colors.white,
            onSurface: AppColor.blackShade1,
            surface: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColor.brownAccentPrimary,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final m = months[picked.month - 1];
      dob.value = '${picked.day.toString().padLeft(2, '0')} $m ${picked.year}';
    }
  }

  void saveProfile() {
    // TODO: implement save logic
    Get.snackbar('Success', 'Profile saved successfully',
        snackPosition: SnackPosition.TOP);
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    altPhoneController.dispose();
    super.onClose();
  }
}
