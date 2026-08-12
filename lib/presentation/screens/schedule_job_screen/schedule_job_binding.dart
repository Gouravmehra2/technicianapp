import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleJobController>(() => ScheduleJobController());
  }
}
