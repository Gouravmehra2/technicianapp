import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class _Device {
  final String name;
  final String detail;
  final bool isCurrentDevice;

  _Device({
    required this.name,
    required this.detail,
    required this.isCurrentDevice,
  });
}

class PrivacySecurityController extends GetxController {
  final RxBool biometricEnabled = true.obs;
  final RxBool twoFactorEnabled = false.obs;

  final devices = <_Device>[
    _Device(
      name: 'iPhone 15 Pro',
      detail: 'London, UK • Active Now',
      isCurrentDevice: true,
    ),
    _Device(
      name: 'MacBook Pro 16"',
      detail: 'San Francisco, US • 2 days ago',
      isCurrentDevice: false,
    ),
  ];

  void onChangePassword() {}
  void onChangePhoneNumber() {}
  void onChangeEmail() {}

  void onLogoutAll() {
    Get.snackbar(
      'Logged Out',
      'All devices have been logged out.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void onDeactivateAccount() {}

  void onDeleteAccount() {
    Get.toNamed(AppRoutes.deleteAccountScreen);
  }
}
