import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/auth/forgot_password_screen/forgot_password_controller.dart';
import 'package:technicianapp/auth/sign_up_screen/sign_up_controller.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/firebase_service.dart';
import 'package:technicianapp/core/services/social_auth_service.dart';

class EmailLoginController extends GetxController {
  // ── Controllers ───────────────────────────────────────────────────────────

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ── Form ──────────────────────────────────────────────────────────────────

  late GlobalKey<FormState> formKey;

  // ── Observables ───────────────────────────────────────────────────────────

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  // ── Password toggle ───────────────────────────────────────────────────────

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  // ── Validators ────────────────────────────────────────────────────────────

  FormFieldValidator<String> get emailValidator => CommonValidators.compose([
    CommonValidators.required(message: 'validation_email_required'.tr),
    CommonValidators.email(message: 'validation_email'.tr),
  ]);

  FormFieldValidator<String> get passwordValidator => CommonValidators.compose([
    CommonValidators.required(message: 'validation_password_required'.tr),
    CommonValidators.strongPassword(message: 'validation_password_strength'.tr),
  ]);

  // ── Login ─────────────────────────────────────────────────────────────────

  final _apiRepo = Get.find<ApiRepo>();
  final _authService = AuthService.to;

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      String? deviceToken;
      try {
        final firebase = FirebaseService.to;
        deviceToken = firebase.token ?? await firebase.refreshToken();
      } catch (error) {
        debugPrint('[EmailLogin] FCM token unavailable: $error');
      }

      final response = await _apiRepo.loginWithEmailApi(
        email: email,
        password: password,
        fcmToken: deviceToken,
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final userData = UserModel.fromJson(data);

      await _authService.saveSession(authToken: token, userData: userData);

      _navigateAfterLogin(userData);
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'login_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateAfterLogin(UserModel user) {
    if (user.isTechnicianApproved) {
      // Fully approved → home
      Get.offAllNamed(AppRoutes.dashboardScreen);
    } else if (user.hasNotStartedOnboarding) {
      // Fresh account – docs never submitted → Step 1 overview
      Get.offAllNamed(AppRoutes.technicianDocOverviewScreen);
    } else {
      // Docs submitted but pending / rejected / any other status → Step 4 review
      Get.offAllNamed(AppRoutes.technicianUnderReviewScreen);
    }
  }

  // ── Social ────────────────────────────────────────────────────────────────

  final _socialAuth = Get.find<SocialAuthService>();

  final RxBool isAppleLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  Future<void> handleAppleLogin() async {
    if (isAppleLoading.value || isGoogleLoading.value) return;

    isAppleLoading.value = true;
    try {
      final result = await _socialAuth.signInWithApple();
      result.fold(
        onSuccess: (user) {
          // TODO: send user.idToken to backend, then navigate
          debugPrint('[EmailLogin] Apple user: ${user.uid}');
        },
        onFailure: (msg) => AppSnackbar.error(msg, title: 'sign_in_failed'.tr),
        onCancelled: () {},
      );
    } finally {
      isAppleLoading.value = false;
    }
  }

  Future<void> handleGoogleLogin() async {
    if (isAppleLoading.value || isGoogleLoading.value) return;

    isGoogleLoading.value = true;
    try {
      final result = await _socialAuth.signInWithGoogle();
      result.fold(
        onSuccess: (user) {
          // TODO: send user.idToken to backend, then navigate
          debugPrint('[EmailLogin] Google user: ${user.email}');
        },
        onFailure: (msg) => AppSnackbar.error(msg, title: 'sign_in_failed'.tr),
        onCancelled: () {},
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void navigateToForgotPassword() => Get.toNamed(
    AppRoutes.forgotPasswordScreen,
    arguments: ForgotPasswordArgs.email(prefillEmail: ''),
  );

  void navigateToSignUp() =>
      Get.toNamed(AppRoutes.signUpScreen, arguments: SignUpArgs.email());

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
