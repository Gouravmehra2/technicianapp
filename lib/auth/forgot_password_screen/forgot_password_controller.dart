import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/otp_screen/otp_controller.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

// ── Mode ──────────────────────────────────────────────────────────────────────

/// Determines whether the forgot-password screen shows a phone or email field.
enum ForgotPasswordMode { phone, email }

// ── Args ─────────────────────────────────────────────────────────────────────

/// Pass when navigating to ForgotPasswordScreen.
///
/// From phone login:
/// ```dart
/// Get.toNamed(AppRoutes.forgotPasswordScreen);          // defaults to phone
/// ```
///
/// From email login:
/// ```dart
/// Get.toNamed(
///   AppRoutes.forgotPasswordScreen,
///   arguments: ForgotPasswordArgs.email(prefillEmail: 'user@example.com'),
/// );
/// ```
class ForgotPasswordArgs {
  final ForgotPasswordMode mode;
  final String prefillEmail;

  const ForgotPasswordArgs._({
    required this.mode,
    this.prefillEmail = '',
  });

  factory ForgotPasswordArgs.phone() =>
      const ForgotPasswordArgs._(mode: ForgotPasswordMode.phone);

  factory ForgotPasswordArgs.email({String prefillEmail = ''}) =>
      ForgotPasswordArgs._(
        mode: ForgotPasswordMode.email,
        prefillEmail: prefillEmail,
      );
}

// ── Per-country digit lengths ─────────────────────────────────────────────────

const Map<String, ({int min, int max})> _countryDigitLengths = {
  'IN': (min: 10, max: 10),
  'US': (min: 10, max: 10),
  'CA': (min: 10, max: 10),
  'GB': (min: 10, max: 11),
  'AU': (min: 9,  max: 9 ),
  'AE': (min: 9,  max: 9 ),
  'SA': (min: 9,  max: 9 ),
  'PK': (min: 10, max: 10),
  'BD': (min: 10, max: 10),
  'NG': (min: 10, max: 10),
  'SG': (min: 8,  max: 8 ),
  'NZ': (min: 8,  max: 9 ),
  'MY': (min: 9,  max: 10),
};

// ── Controller ────────────────────────────────────────────────────────────────

class ForgotPasswordController extends GetxController {
  // ── Mode ──────────────────────────────────────────────────────────────────

  late ForgotPasswordMode mode;

  bool get isEmailMode => mode == ForgotPasswordMode.email;

  /// UI strings that adapt to mode.
  String get subtitleText => isEmailMode
      ? 'forgot_subtitle_email'.tr
      : 'forgot_subtitle_phone'.tr;

  String get fieldHintText => isEmailMode
      ? 'forgot_hint_email'.tr
      : 'forgot_hint_phone'.tr;

  String get buttonLabel => 'forgot_btn'.tr;

  // ── Form ──────────────────────────────────────────────────────────────────

  /// Single controller used for both phone and email input.
  final TextEditingController inputController = TextEditingController();

  late GlobalKey<FormState> formKey;

  // ── Phone-only: country picker ────────────────────────────────────────────

  final Rx<CountryCode> selectedCountry = CountryCode(
    code: 'IN',
    dialCode: '+91',
    name: 'India',
  ).obs;

  final RxString phoneError = ''.obs;

  void onCountryChanged(CountryCode countryCode) {
    selectedCountry.value = countryCode;
    inputController.clear();
    phoneError.value = '';
  }

  ({int min, int max}) get _digitLengths {
    final code = selectedCountry.value.code?.toUpperCase() ?? '';
    return _countryDigitLengths[code] ?? (min: 6, max: 15);
  }

  List<TextInputFormatter> get phoneFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_digitLengths.max),
      ];

  // ── Validation ────────────────────────────────────────────────────────────

  String? validateInput(String? value) {
    if (isEmailMode) {
      return CommonValidators.compose([
        CommonValidators.required(message: 'validation_email_required'.tr),
        CommonValidators.email(),
      ])(value);
    }
    // Phone validation
    if (value == null || value.trim().isEmpty) {
      return 'validation_phone_required'.tr;
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final lengths = _digitLengths;
    if (digits.length < lengths.min || digits.length > lengths.max) {
      final rangeText = lengths.min == lengths.max
          ? '${lengths.min}-digit'
          : '${lengths.min}–${lengths.max}-digit';
      return 'Enter a valid $rangeText number for ${selectedCountry.value.name}';
    }
    return null;
  }

  void onInputChanged(String value) {
    if (isEmailMode) return; // email has no live error
    if (value.trim().isEmpty) {
      phoneError.value = '';
      return;
    }
    phoneError.value = validateInput(value) ?? '';
  }

  // ── State ─────────────────────────────────────────────────────────────────

  final RxBool linkSent = false.obs;
  final RxBool isLoading = false.obs;

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

  // ── Submit ────────────────────────────────────────────────────────────────

  void handleGetRecoveryLink() {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    // TODO: Call recovery API
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      linkSent.value = true;
      _startTimer();

      final OtpArgs otpArgs = isEmailMode
          ? OtpArgs.email(email: inputController.text.trim())
          : OtpArgs.phone(
              dialCode: selectedCountry.value.dialCode ?? '',
              phone: inputController.text.trim(),
            );

      Get.toNamed(AppRoutes.otpScreen, arguments: otpArgs);
    });
  }

  // ── Resend ────────────────────────────────────────────────────────────────

  void handleResend() {
    if (!canResend.value) return;
    _startTimer();
    debugPrint('Resending recovery link');
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void navigateBack() => Get.back();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    final args = Get.arguments;
    if (args is ForgotPasswordArgs) {
      mode = args.mode;
      if (args.prefillEmail.isNotEmpty) {
        inputController.text = args.prefillEmail;
      }
    } else {
      mode = ForgotPasswordMode.phone;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    inputController.dispose();
    super.onClose();
  }
}
