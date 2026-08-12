import 'package:get/get.dart';

class SecurityController extends GetxController {
  final isMobileVerified = true.obs;
  final isEmailVerified = true.obs;

  final currentDevice = 'Android • Chandigarh';
  final lastLogin = 'Today • 11:12 AM';

  void onChangePassword() {
    // TODO: navigate to change password screen
  }

  void onSecurityPin() {
    // TODO: navigate to security PIN screen
  }

  void onCurrentDevice() {
    // TODO: navigate to device/session details
  }

  void onDeleteAccount() {
    // TODO: show confirmation dialog via CommonDialog
  }
}