import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? imagePath;
  final bool isTyping;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.imagePath,
    this.isTyping = false,
  });
}

class ChatSupportController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[
    const ChatMessage(
      text: "Hello! I'm Marcus from the 1App Elite Support team. How can I assist you with your premium subscription today?",
      isUser: false,
      time: '10:25 AM',
    ),
    const ChatMessage(
      text: "I noticed a discrepancy in my latest billing for the 'Expert Connect' service. Could you look into that?",
      isUser: true,
      time: '10:26 AM',
    ),
    const ChatMessage(
      text: 'Of course. I see the transaction here. Are you referring to this specific invoice?',
      isUser: false,
      time: '10:27 AM',
      imagePath: 'assets/images/onboarding_image_1.png',
    ),
    const ChatMessage(
      text: 'Yes, exactly. The extra fee seems incorrect.',
      isUser: true,
      time: '10:28 AM',
    ),
  ].obs;

  final RxBool isAgentTyping = true.obs;

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessage(
      text: text,
      isUser: true,
      time: _now(),
    ));
    messageController.clear();
    _scrollToBottom();
  }

  void onEndChat() {
    Get.toNamed(AppRoutes.supportThankYouScreen, arguments: 'chat');
  }

  String _now() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
