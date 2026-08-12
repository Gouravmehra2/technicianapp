import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Supported locales for the app.
enum AppLanguage { english, spanish }

class LanguageService extends GetxController {
  static LanguageService get to => Get.find<LanguageService>();

  static const _defaultLocale = Locale('en', 'US');
  static const _spanishLocale = Locale('es', 'ES');

  final Rx<AppLanguage> currentLanguage = AppLanguage.english.obs;

  /// Returns the active [Locale].
  Locale get locale =>
      currentLanguage.value == AppLanguage.english
          ? _defaultLocale
          : _spanishLocale;

  /// Switch to English.
  void setEnglish() {
    currentLanguage.value = AppLanguage.english;
    Get.updateLocale(_defaultLocale);
  }

  /// Switch to Spanish.
  void setSpanish() {
    currentLanguage.value = AppLanguage.spanish;
    Get.updateLocale(_spanishLocale);
  }

  /// Toggle between the two supported languages.
  void toggleLanguage() {
    if (currentLanguage.value == AppLanguage.english) {
      setSpanish();
    } else {
      setEnglish();
    }
  }

  /// Returns a human-readable label for the current language.
  String get currentLanguageLabel =>
      currentLanguage.value == AppLanguage.english ? 'English' : 'Español';

  /// Returns a human-readable label for the other (switchable) language.
  String get switchLanguageLabel =>
      currentLanguage.value == AppLanguage.english ? 'Español' : 'English';
}
