import 'package:get/get.dart';
import 'job_controller.dart';
import 'job_filter_controller.dart';
import 'job_detail_controller.dart';
import 'job_send_quote_controller.dart';

class JobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobController>(() => JobController());
  }
}

class JobFilterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobFilterController>(() => JobFilterController());
  }
}

class JobDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobDetailController>(() => JobDetailController());
  }
}

class JobSendQuoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobSendQuoteController>(() => JobSendQuoteController());
  }
}
