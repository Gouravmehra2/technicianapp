import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/otp_screen/otp_controller.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/social_auth_service.dart';

// ── Mode ──────────────────────────────────────────────────────────────────────

enum SignUpMode { phone, email }

// ── Args ─────────────────────────────────────────────────────────────────────

/// Pass when navigating to SignUpScreen.
///
/// Default (phone flow):
/// ```dart
/// Get.toNamed(AppRoutes.signUpScreen);
/// ```
///
/// From email login screen:
/// ```dart
/// Get.toNamed(AppRoutes.signUpScreen, arguments: SignUpArgs.email());
/// ```
class SignUpArgs {
  final SignUpMode mode;

  const SignUpArgs._({required this.mode});

  factory SignUpArgs.phone() => const SignUpArgs._(mode: SignUpMode.phone);
  factory SignUpArgs.email() => const SignUpArgs._(mode: SignUpMode.email);
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
  'CN': (min: 11, max: 11),
  'JP': (min: 10, max: 11),
  'DE': (min: 10, max: 11),
  'FR': (min: 10, max: 10),
  'BR': (min: 10, max: 11),
  'MX': (min: 10, max: 10),
  'ZA': (min: 9,  max: 9 ),
  'KE': (min: 9,  max: 9 ),
  'EG': (min: 10, max: 10),
  'IT': (min: 9,  max: 10),
  'ES': (min: 9,  max: 9 ),
  'RU': (min: 10, max: 10),
  'TR': (min: 10, max: 10),
  'ID': (min: 9,  max: 12),
  'PH': (min: 10, max: 10),
  'TH': (min: 9,  max: 9 ),
  'VN': (min: 9,  max: 10),
  'MY': (min: 9,  max: 10),
  'SG': (min: 8,  max: 8 ),
  'NZ': (min: 8,  max: 9 ),
  'AR': (min: 10, max: 10),
  'CO': (min: 10, max: 10),
  'CL': (min: 9,  max: 9 ),
  'GH': (min: 9,  max: 9 ),
  'ET': (min: 9,  max: 9 ),
  'TZ': (min: 9,  max: 9 ),
  'UG': (min: 9,  max: 9 ),
  'IQ': (min: 10, max: 10),
  'IR': (min: 10, max: 10),
  'MA': (min: 9,  max: 9 ),
  'DZ': (min: 9,  max: 9 ),
  'SD': (min: 9,  max: 9 ),
  'UA': (min: 9,  max: 9 ),
  'PL': (min: 9,  max: 9 ),
  'NL': (min: 9,  max: 9 ),
  'BE': (min: 8,  max: 9 ),
  'SE': (min: 9,  max: 10),
  'NO': (min: 8,  max: 8 ),
  'DK': (min: 8,  max: 8 ),
  'FI': (min: 9,  max: 10),
  'PT': (min: 9,  max: 9 ),
  'CH': (min: 9,  max: 9 ),
  'AT': (min: 10, max: 11),
  'CZ': (min: 9,  max: 9 ),
  'RO': (min: 9,  max: 9 ),
  'HU': (min: 9,  max: 9 ),
  'GR': (min: 10, max: 10),
  'IL': (min: 9,  max: 9 ),
  'KW': (min: 8,  max: 8 ),
  'QA': (min: 8,  max: 8 ),
  'BH': (min: 8,  max: 8 ),
  'JO': (min: 9,  max: 9 ),
  'LB': (min: 8,  max: 8 ),
  'LK': (min: 9,  max: 9 ),
  'NP': (min: 10, max: 10),
  'MM': (min: 9,  max: 10),
  'KH': (min: 8,  max: 9 ),
  'KZ': (min: 10, max: 10),
};

// ── Controller ────────────────────────────────────────────────────────────────

class SignUpController extends GetxController {
  // ── Mode ──────────────────────────────────────────────────────────────────

  late SignUpMode mode;

  bool get isEmailMode => mode == SignUpMode.email;

  String get subtitleText => isEmailMode
      ? 'signup_subtitle_email'.tr
      : 'signup_subtitle_phone'.tr;

  // ── Controllers ───────────────────────────────────────────────────────────

  /// Used in phone mode.
  final TextEditingController phoneController = TextEditingController();

  /// Used in email mode.
  final TextEditingController emailController = TextEditingController();

  // ── Form ──────────────────────────────────────────────────────────────────

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ── Phone-only ────────────────────────────────────────────────────────────

  final RxString phoneError = ''.obs;

  final Rx<CountryCode> selectedCountry = CountryCode(
    code: 'IN',
    dialCode: '+91',
    name: 'India',
  ).obs;

  ({int min, int max}) get _digitLengths {
    final code = selectedCountry.value.code?.toUpperCase() ?? '';
    return _countryDigitLengths[code] ?? (min: 6, max: 15);
  }

  List<TextInputFormatter> get phoneFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_digitLengths.max),
      ];

  String? validatePhone(String? value) {
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

  void onPhoneChanged(String value) {
    if (value.trim().isEmpty) {
      phoneError.value = '';
      return;
    }
    phoneError.value = validatePhone(value) ?? '';
  }

  void onCountryChanged(CountryCode countryCode) {
    selectedCountry.value = countryCode;
    phoneController.clear();
    phoneError.value = '';
  }

  // ── Email-only ────────────────────────────────────────────────────────────

  FormFieldValidator<String> get emailValidator => CommonValidators.compose([
        CommonValidators.required(message: 'validation_email_required'.tr),
        CommonValidators.email(message: 'validation_email'.tr),
      ]);

  // ── Continue ──────────────────────────────────────────────────────────────

  final _apiRepo = Get.find<ApiRepo>();
  final RxBool isLoading = false.obs;

  Future<void> handleContinue() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (isEmailMode) {
        final email = emailController.text.trim();
        await _apiRepo.sendOtpApi(email: email);
        Get.toNamed(
          AppRoutes.otpScreen,
          arguments: OtpArgs.email(email: email),
        );
      } else {
        final dialCode = selectedCountry.value.dialCode ?? '';
        final number = phoneController.text.trim();
        final fullPhone = '$dialCode$number';
        await _apiRepo.sendOtpApi(phone: fullPhone);
        Get.toNamed(
          AppRoutes.otpScreen,
          arguments: OtpArgs.phone(dialCode: dialCode, phone: number),
        );
      }

      AppSnackbar.success('OTP sent successfully');
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Social ────────────────────────────────────────────────────────────────

  final _socialAuth = Get.find<SocialAuthService>();

  final RxBool isAppleLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  Future<void> handleAppleSignUp() async {
    if (isAppleLoading.value || isGoogleLoading.value) return;

    isAppleLoading.value = true;
    try {
      final result = await _socialAuth.signInWithApple();
      result.fold(
        onSuccess: (user) {
          // TODO: send user.idToken to your backend, then navigate
          debugPrint('[SignUp] Apple user: ${user.uid}');
        },
        onFailure: (msg) => Get.snackbar('signup_failed'.tr, msg),
        onCancelled: () {},
      );
    } finally {
      isAppleLoading.value = false;
    }
  }

  Future<void> handleGoogleSignUp() async {
    if (isAppleLoading.value || isGoogleLoading.value) return;

    isGoogleLoading.value = true;
    try {
      final result = await _socialAuth.signInWithGoogle();
      result.fold(
        onSuccess: (user) {
          // TODO: send user.idToken to your backend, then navigate
          debugPrint('[SignUp] Google user: ${user.email}');
        },
        onFailure: (msg) => Get.snackbar('signup_failed'.tr, msg),
        onCancelled: () {},
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void navigateToLogin() => Get.back();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    mode = (args is SignUpArgs) ? args.mode : SignUpMode.phone;
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
