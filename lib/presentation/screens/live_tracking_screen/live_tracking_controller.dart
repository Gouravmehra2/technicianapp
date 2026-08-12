import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class LiveTrackingController extends GetxController {
  late ServiceModel service;

  @override
  void onInit() {
    super.onInit();
    service = Get.arguments as ServiceModel;
  }

  void checkStatus() => Get.toNamed(AppRoutes.bookingStatusScreen, arguments: service);
}
