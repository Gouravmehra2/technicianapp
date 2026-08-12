import 'package:get/get.dart';
import 'package:technicianapp/translations/en.dart';
import 'package:technicianapp/translations/es.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en,
        'es_ES': es,
      };
}
