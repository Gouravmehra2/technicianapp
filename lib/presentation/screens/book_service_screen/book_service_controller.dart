import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class BookServiceController extends GetxController {
  late ServiceModel service;

  final selectedDateIndex = 0.obs;

  final List<DateTime> dates =
  List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  final selectedDate = DateTime.now().obs;

  final double serviceFee = 10;
  final double taxesFees = 2;
  final double discount = 5;
  double get total => serviceFee + taxesFees - discount;

  @override
  void onInit() {
    selectedDate.value = dates.first;
    super.onInit();
    service = Get.arguments as ServiceModel;
  }

  void confirmAndBook() {
    Get.toNamed(AppRoutes.paymentOptionsScreen, arguments: {'service': service, 'total': total});
  }
}
