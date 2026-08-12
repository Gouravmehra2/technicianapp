import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/sign_up_detail_screen/sign_up_detail_controller.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';

// ── Verify mode ───────────────────────────────────────────────────────────────

/// Tells the OTP screen whether it is verifying a phone number or an email.
enum OtpVerifyMode { phone, email }

// ── Args ─────────────────────────────────────────────────────────────────────

/// Arguments passed when navigating to the OTP screen.
///
/// Phone flow:
/// ```dart
/// Get.toNamed(
///   AppRoutes.otpScreen,
///   arguments: OtpArgs.phone(dialCode: '+91', phone: '9876543210'),
/// );
/// ```
///
/// Email flow:
/// ```dart
/// Get.toNamed(
///   AppRoutes.otpScreen,
///   arguments: OtpArgs.email(email: 'user@example.com'),
/// );
/// ```
class OtpArgs {
  final OtpVerifyMode mode;
  final String dialCode;
  final String phone;
  final String email;

  const OtpArgs._({
    required this.mode,
    this.dialCode = '',
    this.phone = '',
    this.email = '',
  });

  factory OtpArgs.phone({required String dialCode, required String phone}) =>
      OtpArgs._(mode: OtpVerifyMode.phone, dialCode: dialCode, phone: phone);

  factory OtpArgs.email({required String email}) =>
      OtpArgs._(mode: OtpVerifyMode.email, email: email);
}

// ── Controller ────────────────────────────────────────────────────────────────

class OtpController extends GetxController {
  // ── Mode & destination ────────────────────────────────────────────────────

  late OtpVerifyMode mode;
  late String dialCode;
  late String phone;
  late String email;

  bool get isEmailMode => mode == OtpVerifyMode.email;

  /// Full E.164 phone string, e.g. "+917710567945"
  String get fullPhone => '$dialCode$phone';

  String get maskedDestination =>
      isEmailMode ? email : '$dialCode ${_formatPhone(phone)}';

  String get titleText =>
      isEmailMode ? 'otp_title_email'.tr : 'otp_title_phone'.tr;

  String get subtitleText => 'otp_subtitle'.trArgs([maskedDestination]);

  String get changeLinkText =>
      isEmailMode ? 'otp_change_email'.tr : 'otp_change_number'.tr;

  // ── Pin input ─────────────────────────────────────────────────────────────

  final TextEditingController pinController = TextEditingController();
  late GlobalKey<FormState> formKey;

  final RxString otpValue = ''.obs;

  void onOtpChanged(String value) => otpValue.value = value;
  void onOtpCompleted(String value) => otpValue.value = value;

  // ── Resend countdown ──────────────────────────────────────────────────────

  static const int _resendSeconds = 30;

  final RxInt secondsRemaining = _resendSeconds.obs;
  final RxBool canResend = false.obs;

  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    secondsRemaining.value = _resendSeconds;
    canResend.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining.value <= 1) {
        t.cancel();
        secondsRemaining.value = 0;
        canResend.value = true;
      } else {
        secondsRemaining.value--;
      }
    });
  }

  String get countdownText {
    final mins = secondsRemaining.value ~/ 60;
    final secs = secondsRemaining.value % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ── Verify ────────────────────────────────────────────────────────────────

  final _apiRepo = Get.find<ApiRepo>();
  final RxBool isVerifyLoading = false.obs;

  Future<void> handleVerify() async {
    if (!formKey.currentState!.validate()) return;

    final otp = otpValue.value;
    if (otp.length < 6) {
      AppSnackbar.error('Please enter the complete 6-digit OTP');
      return;
    }

    isVerifyLoading.value = true;

    try {
      // Payload: { "email": "...", "otp": "..." }
      //       or { "phone": "+91...", "otp": "..." }
      if (isEmailMode) {
        await _apiRepo.verifyOtpApi(email: email, otp: otp);
        Get.toNamed(
          AppRoutes.signUpDetailScreen,
          arguments: SignUpDetailArgs.email(verifiedEmail: email),
        );
      } else {
        await _apiRepo.verifyOtpApi(phone: fullPhone, otp: otp);
        Get.toNamed(
          AppRoutes.signUpDetailScreen,
          arguments: SignUpDetailArgs.phone(
            dialCode: dialCode,
            verifiedPhone: phone,
          ),
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Verification Failed');
    } finally {
      isVerifyLoading.value = false;
    }
  }

  // ── Resend ────────────────────────────────────────────────────────────────

  Future<void> handleResend() async {
    if (!canResend.value) return;
    pinController.clear();
    otpValue.value = '';
    _startTimer();

    try {
      if (isEmailMode) {
        await _apiRepo.sendOtpApi(email: email);
      } else {
        await _apiRepo.sendOtpApi(phone: fullPhone);
      }
      AppSnackbar.success('OTP sent successfully');
    } catch (e) {
      AppSnackbar.error(e.toString());
    }
  }

  // ── Change destination ────────────────────────────────────────────────────

  void handleChangeDestination() => Get.back();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    final args = Get.arguments;
    if (args is OtpArgs) {
      mode = args.mode;
      dialCode = args.dialCode;
      phone = args.phone;
      email = args.email;
    } else {
      mode = OtpVerifyMode.phone;
      dialCode = '';
      phone = '';
      email = '';
    }
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pinController.dispose();
    super.onClose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatPhone(String raw) {
    if (raw.length <= 5) return raw;
    return '${raw.substring(0, 5)} ${raw.substring(5)}';
  }
}
