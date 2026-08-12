import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_controller.dart';

class PaymentController extends GetxController {
  late ServiceModel service;
  late double total;

  final selectedMethod = ''.obs;
  final cashOnDelivery = false.obs;

  final List<Map<String, dynamic>> recommendedPayments = [
    {'label': 'Apple Pay UPI', 'icon': 'apple'},
    {'label': 'BHIM UPI', 'icon': 'bhim'},
    {'label': 'PayPal Payments', 'icon': 'paypal'},
  ];

  final List<String> banks = ['HDFC\nBank', 'HSBC\nBank', 'SBI\nBank', 'Axis\nBank', 'ICICI\nBank', 'IOB\nBank'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    service = args['service'] as ServiceModel;
    total = args['total'] as double;
  }

  void selectMethod(String method) => selectedMethod.value = method;

  void confirmPayment() {
    Get.toNamed(AppRoutes.bookingConfirmationScreen, arguments: {'service': service, 'total': total});
  }
}
