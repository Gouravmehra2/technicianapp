import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/firebase_service.dart';

enum ChatMessageType { text, offer }

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? imagePath;
  final ChatMessageType type;
  final String? offerLabel;
  final String? offerValue;
  final RxnBool? actionTaken;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.imagePath,
    this.type = ChatMessageType.text,
    this.offerLabel,
    this.offerValue,
    this.actionTaken,
  });
}

class ChatSupportController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[
    ChatMessage(
      text: "Hello! I'm Marcus from the 1App Elite Support team. How can I assist you with your premium subscription today?",
      isUser: false,
      time: '10:25 AM',
    ),
    ChatMessage(
      text: "I noticed a discrepancy in my latest billing for the 'Expert Connect' service. Could you look into that?",
      isUser: true,
      time: '10:26 AM',
    ),
    ChatMessage(
      text: 'Of course. I see the transaction here. Are you referring to this specific invoice?',
      isUser: false,
      time: '10:27 AM',
      imagePath: 'assets/images/onboarding_image_1.png',
    ),
    ChatMessage(
      text: 'Yes, exactly. The extra fee seems incorrect.',
      isUser: true,
      time: '10:28 AM',
    ),
  ].obs;

  final RxBool isAgentTyping = true.obs;

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessage(text: text, isUser: true, time: _now()));
    messageController.clear();
    _scrollToBottom();
  }

  void sendCounterOffer() {
    final label = labelController.text.trim();
    final value = valueController.text.trim();
    if (label.isEmpty || value.isEmpty) return;

    messages.add(ChatMessage(
      text: '$label  \$$value',
      isUser: true,
      time: _now(),
      type: ChatMessageType.offer,
      offerLabel: label,
      offerValue: '\$$value',
    ));
    labelController.clear();
    valueController.clear();
    Get.back();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      messages.add(ChatMessage(
        text: 'Here is our revised offer:',
        isUser: false,
        time: _now(),
        type: ChatMessageType.offer,
        offerLabel: label,
        offerValue: '\$${(int.tryParse(value) ?? 0) + 10}',
        actionTaken: RxnBool(null),
      ));
      _scrollToBottom();
    });
  }

  void acceptOffer(ChatMessage msg) {
    msg.actionTaken?.value = true;
    messages.refresh();
  }

  void counterOffer(ChatMessage msg) {
    msg.actionTaken?.value = false;
    messages.refresh();
    showCounterOfferSheet();
  }

  void showCounterOfferSheet() => Get.bottomSheet(
        _CounterOfferSheet(controller: this),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  void onEndChat() {
    Get.toNamed(AppRoutes.supportThankYouScreen, arguments: 'chat');
  }

  String _now() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour < 12 ? 'AM' : 'PM'}';
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
  void onInit() {
    super.onInit();
    // Tell FirebaseService the chat screen is open so incoming chat
    // notifications are suppressed while the user can see the messages.
    try {
      FirebaseService.to.onChatScreenOpened(AppRoutes.chatSupportScreen);
    } catch (_) {}
  }

  @override
  void onClose() {
    // Re-enable chat notifications when the user leaves this screen.
    try {
      FirebaseService.to.onChatScreenClosed();
    } catch (_) {}
    messageController.dispose();
    labelController.dispose();
    valueController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class _CounterOfferSheet extends StatelessWidget {
  final ChatSupportController controller;
  const _CounterOfferSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Counter Offer',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.labelController,
            decoration: InputDecoration(
              labelText: 'Charge Name (e.g. Gas Charges)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.valueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (e.g. 49)',
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.sendCounterOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA5732F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: const Text(
                'Send Counter Offer',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
