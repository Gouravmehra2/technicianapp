import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class WalletController extends GetxController {
  final balance = 3124.50.obs;

  final transactions = [
    {'title': 'Added to Wallet', 'sub': 'UPI • 12 June 2026, 10:30 AM', 'amount': '+₹1,000.00', 'isCredit': true},
    {'title': 'Payment for Service', 'sub': '#SR-10023 • 12 June 2026', 'amount': '-₹750.00', 'isCredit': false},
    {'title': 'Added to Wallet', 'sub': 'UPI • 10 June 2026, 02:15 PM', 'amount': '+₹500.00', 'isCredit': true},
  ];

  void goToAddMoney() => Get.toNamed(AppRoutes.addMoneyScreen);
}
