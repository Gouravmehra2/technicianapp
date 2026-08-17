import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/location_manager.dart';
import 'package:technicianapp/core/services/location_service.dart';

class SplashController extends GetxController {
  final _apiRepo = Get.find<ApiRepo>();
  final RxString locationText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationIfGranted();
      Future.delayed(const Duration(seconds: 3), _navigate);
    });
  }

  Future<void> _fetchLocationIfGranted() async {
    final result = await LocationManager.to.fetchIfGranted();
    if (result == null || !result.success) return;

    locationText.value = result.address;
    LocationService.to.setLocation(
      address: result.address,
      lat: result.lat,
      lng: result.lng,
    );
  }

  Future<void> _navigate() async {
    final auth = AuthService.to;

    // Not logged in at all → go to onboarding/welcome
    if (!auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.onboardingScreen);
      return;
    }

    // Token present — fetch fresh profile from server so we always
    // route based on the real current verificationStatus, not stale cache.
    try {
      final response = await _apiRepo.getMeApi();
      final body = response.data as Map<String, dynamic>?;
      if (body != null) {
        final freshModel = UserModel.fromJson(body);
        // Persist the refreshed user so the rest of the app has up-to-date data
        await auth.saveSession(
          authToken: auth.token.value!,
          userData: freshModel,
        );
      }
    } catch (e) {
      debugPrint('[Splash] /me fetch failed — falling back to cached data: $e');
      // Continue with cached data rather than blocking the user
    }

    _routeByStatus(auth);
  }

  void _routeByStatus(AuthService auth) {
    if (auth.isTechnicianApproved) {
      // Fully approved → home screen
      Get.offAllNamed(AppRoutes.dashboardScreen);
    } else if (auth.isTechnicianPending || auth.isTechnicianRejected) {
      // Docs already submitted — under review or some rejected → review/status page
      Get.offAllNamed(AppRoutes.technicianUnderReviewScreen);
    } else {
      // Fresh account – docs never submitted → Step 1 overview
      Get.offAllNamed(AppRoutes.technicianDocOverviewScreen);
    }
  }
}
