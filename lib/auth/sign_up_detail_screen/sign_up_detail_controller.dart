import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/auth/otp_screen/otp_controller.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/firebase_service.dart';

// ── Args ──────────────────────────────────────────────────────────────────────

/// Pass when navigating to SignUpDetailScreen after OTP verification.
///
/// Email flow (verified email pre-filled):
/// ```dart
/// Get.toNamed(
///   AppRoutes.signUpDetailScreen,
///   arguments: SignUpDetailArgs.email(verifiedEmail: 'user@example.com'),
/// );
/// ```
///
/// Phone flow (verified phone pre-filled):
/// ```dart
/// Get.toNamed(
///   AppRoutes.signUpDetailScreen,
///   arguments: SignUpDetailArgs.phone(dialCode: '+91', phone: '9876543210'),
/// );
/// ```
class SignUpDetailArgs {
  final OtpVerifyMode mode;
  final String verifiedEmail;
  final String dialCode;
  final String verifiedPhone;

  const SignUpDetailArgs._({
    required this.mode,
    this.verifiedEmail = '',
    this.dialCode = '',
    this.verifiedPhone = '',
  });

  factory SignUpDetailArgs.email({required String verifiedEmail}) =>
      SignUpDetailArgs._(
        mode: OtpVerifyMode.email,
        verifiedEmail: verifiedEmail,
      );

  factory SignUpDetailArgs.phone({
    required String dialCode,
    required String verifiedPhone,
  }) => SignUpDetailArgs._(
    mode: OtpVerifyMode.phone,
    dialCode: dialCode,
    verifiedPhone: verifiedPhone,
  );
}

// ── Controller ────────────────────────────────────────────────────────────────

class SignUpDetailController extends GetxController {
  // ── Controllers ───────────────────────────────────────────────────────────

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ── Form ──────────────────────────────────────────────────────────────────

  late GlobalKey<FormState> formKey;

  // ── State ─────────────────────────────────────────────────────────────────

  late OtpVerifyMode mode;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  /// Locally picked profile photo (shown in UI before upload).
  final Rx<File?> profileImage = Rx<File?>(null);

  bool get isEmailMode => mode == OtpVerifyMode.email;

  // ── Image picker ──────────────────────────────────────────────────────────

  final ImagePicker _picker = ImagePicker();

  Future<void> pickProfileImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────

  FormFieldValidator<String> get nameValidator => CommonValidators.compose([
    CommonValidators.required(message: 'Name is required'),
    CommonValidators.minLength(
      2,
      message: 'Name must be at least 2 characters',
    ),
  ]);

  FormFieldValidator<String> get emailValidator => CommonValidators.compose([
    CommonValidators.required(message: 'validation_email_required'.tr),
    CommonValidators.email(message: 'validation_email'.tr),
  ]);

  FormFieldValidator<String> get passwordValidator => CommonValidators.compose([
    CommonValidators.required(message: 'validation_password_required'.tr),
    CommonValidators.strongPassword(message: 'validation_password_strength'.tr),
  ]);

  FormFieldValidator<String> get confirmPasswordValidator =>
      CommonValidators.compose([
        CommonValidators.required(message: 'Confirm password is required'),
        CommonValidators.match(
          () => passwordController.text,
          message: 'validation_fields_no_match'.tr,
        ),
      ]);

  // ── Toggles ───────────────────────────────────────────────────────────────

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ── Submit ────────────────────────────────────────────────────────────────

  final _apiRepo = Get.find<ApiRepo>();

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Step 1 — upload profile photo if user picked one
      String? profilePhotoUrl;
      final imageFile = profileImage.value;
      if (imageFile != null) {
        final uploadResponse = await _apiRepo.uploadDocumentsApi(
          imageFile.path,
        );
        final data = uploadResponse.data;
        if (data is Map<String, dynamic>) {
          profilePhotoUrl =
              data['profilePhoto']?.toString() ??
              data['url']?.toString() ??
              data['path']?.toString();
        }
      }

      // Step 2 — complete-signup payload:
      // {
      //   "email":           "test@test.com",
      //   "phone":           "+911111111111",
      //   "name":            "John Doe",
      //   "password":        "secret123",
      //   "confirmPassword": "secret123",
      // }
      //
      // One of email / phone comes pre-filled (the verified identifier);
      // the other is what the user typed on this screen.
      final Map<String, dynamic> payload = {
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'name': nameController.text.trim(),
        'password': passwordController.text,
        'confirmPassword': confirmPasswordController.text,
        'image': profilePhotoUrl,
      };
      try {
        final firebase = FirebaseService.to;
        final deviceToken = firebase.token ?? await firebase.refreshToken();
        if (deviceToken != null && deviceToken.isNotEmpty) {
          payload['fcmTokens'] = deviceToken;
        }
      } catch (error) {
        debugPrint('[SignUp] FCM token unavailable: $error');
      }

      final registerResponse = await _apiRepo.registerApi(payload);

      // Persist the token returned by the register API so every subsequent
      // request (including upload-documents) sends Authorization: Bearer <token>
      final responseData = registerResponse.data;
      String? technicianId;
      if (responseData is Map<String, dynamic>) {
        final token =
            responseData['token']?.toString() ??
            responseData['accessToken']?.toString() ??
            responseData['data']?['token']?.toString();
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        // Extract technician _id for socket room subscription
        technicianId =
            responseData['_id']?.toString() ??
            responseData['id']?.toString() ??
            responseData['data']?['_id']?.toString() ??
            responseData['data']?['id']?.toString();
      }

      AppSnackbar.success('Account created successfully!', title: 'Welcome');

      final verificationStatus =
          (responseData['data']?['user']?['verificationStatus'] as String? ??
                  '')
              .toLowerCase();

      if (verificationStatus == 'approved') {
        // Already approved (edge case) → dashboard
        Get.offAllNamed(AppRoutes.dashboardScreen);
      } else if (verificationStatus.isEmpty ||
          verificationStatus == 'not-yet-started') {
        // Fresh account – docs never submitted → Step 1 overview
        Get.offAllNamed(AppRoutes.technicianDocOverviewScreen);
      } else {
        // Submitted but pending / rejected → Step 4 review
        Get.offAllNamed(AppRoutes.technicianUnderReviewScreen);
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Sign Up Failed');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void navigateToLogin() => Get.offAllNamed(AppRoutes.loginScreen);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();

    final args = Get.arguments;
    if (args is SignUpDetailArgs) {
      mode = args.mode;
      if (args.verifiedEmail.isNotEmpty) {
        emailController.text = args.verifiedEmail;
      }
      if (args.verifiedPhone.isNotEmpty) {
        // Pre-fill with full E.164 so the payload sends the complete number
        phoneController.text = '${args.dialCode}${args.verifiedPhone}';
      }
    } else {
      mode = OtpVerifyMode.email;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
