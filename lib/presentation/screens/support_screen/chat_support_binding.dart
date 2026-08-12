import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/support_screen/chat_support_controller.dart';

class ChatSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatSupportController());
  }
}
