import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_assets/app_assets.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_auth_header.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      imagePath: AppAssets.authBackgroundImage,
      body: _LogoutPanel(),
    );
  }
}

class _LogoutPanel extends StatelessWidget {
  final _apiRepo = Get.find<ApiRepo>();

  Future<void> _logout() async {
    try {
      await _apiRepo.logoutApi();
    } catch (error) {
      debugPrint('[Logout] API request failed: $error');
    } finally {
      SocketService.instance.close();
      await AuthService.to.clearSession();
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Logout icon ──────────────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ────────────────────────────────────────────────
          Text(
            'Logout',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.blackShade1,
            ),
          ),
          const SizedBox(height: 8),

          // ── Subtitle ─────────────────────────────────────────────
          Text(
            'Are you sure you want to\nlogout from your account?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.coolGrayText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── Logout button ─────────────────────────────────────────
          CommonButton(
            label: 'Logout',
            onTap: _logout,
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),

          // ── Cancel button ─────────────────────────────────────────
          CommonButton(
            label: 'Cancel',
            onTap: () => Get.back(),
            backgroundColor: Colors.white,
            foregroundColor: AppColor.blackShade1,
            border: Border.all(color: AppColor.brownAccentPrimary, width: 1.4),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
