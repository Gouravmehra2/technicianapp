import 'dart:io';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/pages/app_pages.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/dio_client/dio_client.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/firebase_service.dart';
import 'package:technicianapp/core/services/language_service.dart';
import 'package:technicianapp/core/services/location_manager.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/social_auth_service.dart';
import 'package:technicianapp/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  handleDeviceOrientation();
  await _registerServices();
  runApp(
      const MyApp()

  );
  // DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => const MyApp(),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        // builder: DevicePreview.appBuilder,
        defaultTransition:
            Platform.isIOS ? Transition.cupertino : Transition.native,
        transitionDuration: const Duration(milliseconds: 500),
        getPages: AppPages.getPages,
        initialRoute: AppRoutes.splashScreen,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Inter'),
        // ── Localisation ──────────────────────────────────────────────────────
        translations: AppTranslations(),
        locale: Get.find<LanguageService>().locale,
        fallbackLocale: const Locale('en', 'US'),
      ),
    );
  }
}

void handleDeviceOrientation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}

Future<void> _registerServices() async {
  Get.putAsync(() => SocialAuthService().init(), permanent: true);
  Get.put(LanguageService(), permanent: true);
  Get.put(LocationService(), permanent: true);
  Get.put(LocationManager(), permanent: true);

  // Firebase — initialised before everything else so FCM is ready early.
  await Get.putAsync(() => FirebaseService().init(), permanent: true);

  // Network layer
  final dioClient = Get.put(DioClient(), permanent: true);
  Get.put(ApiRepo( dioClient), permanent: true);

  // Auth — awaited so SplashController can read isLoggedIn synchronously
  await Get.putAsync(() => AuthService().init(), permanent: true);
}