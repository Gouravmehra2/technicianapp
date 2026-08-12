import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/location_permission_screen/location_permission_controller.dart';

class LocationPermissionBindings extends Bindings{
  @override
  void dependencies() {
   Get.lazyPut(() => LocationPermissionController());
  }

}