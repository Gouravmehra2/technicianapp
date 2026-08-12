import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/booking_status_screen/booking_status_controller.dart';

class BookingStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingStatusController());
  }
}
