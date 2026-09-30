import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/firebase_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/support_screen/model/chat_support_model.dart'
    as api;

enum ChatMessageType { text, offer }

bool isVideoFile(XFile file) {
  final mimeType = file.mimeType?.toLowerCase();
  if (mimeType != null && mimeType.startsWith('video/')) {
    return true;
  }

  final fileName = file.name.toLowerCase();
  final extension = fileName.contains('.') ? fileName.split('.').last : '';
  return {
    '3gp',
    'avi',
    'm4v',
    'mkv',
    'mov',
    'mp4',
    'mpeg',
    'webm',
    'wmv',
  }.contains(extension);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? imagePath;
  final ChatMessageType type;
  final String? offerLabel;
  final String? offerValue;
  final RxnBool? actionTaken;
  final String? messageId;
  final String? videoUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.imagePath,
    this.type = ChatMessageType.text,
    this.offerLabel,
    this.offerValue,
    this.actionTaken,
    this.messageId,
    this.videoUrl,
  });
}

class ChatSupportController extends GetxController {
  final ApiRepo _apiRepo = Get.find<ApiRepo>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isAgentTyping = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isLoading = true.obs;
  final Rxn<XFile> pendingMedia = Rxn<XFile>();

  final SocketService _socketService = SocketService.instance;
  late final String technicianId;
  Timer? _typingTimer;
  Timer? _agentTypingTimer;
  bool _hasSentTyping = false;
  void Function()? _onSocketConnected;
  void Function(dynamic)? _onChatMessageEvent;
  void Function(dynamic)? _onChatTypingEvent;

  void sendMessage() {
    final text = messageController.text.trim();
    final media = pendingMedia.value;
    if (media != null) {
      _sendMedia(media, text);
    } else if (text.isNotEmpty) {
      messageController.clear();
      _sendText(text);
    }
  }

  Future<void> _sendText(String text) async {
    if (isSending.value) return;
    isSending.value = true;
    if (_socketService.isConnected) {
      _socketService.emitWithAck('chat:send', {
        'technicianId': technicianId,
        'text': text,
      }, (_) => isSending.value = false);
      Future<void>.delayed(const Duration(seconds: 5), () {
        isSending.value = false;
      });
      return;
    }
    try {
      await _apiRepo.sendChatTextApi(technicianId: technicianId, text: text);
    } catch (error) {
      Get.snackbar('Chat', 'Unable to send message');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndSendMedia() async {
    final file = await _imagePicker.pickMedia();
    if (file == null || isSending.value) return;
    pendingMedia.value = file;
  }

  void removePendingMedia() {
    if (isSending.value) return;
    pendingMedia.value = null;
  }

  Future<void> _sendMedia(XFile file, String text) async {
    if (isSending.value) return;
    final type = isVideoFile(file) ? 'video' : 'image';

    isSending.value = true;
    try {
      await _apiRepo.sendChatMediaApi(
        technicianId: technicianId,
        filePath: file.path,
        messageType: type,
        contentType: file.mimeType,
        text: text.isEmpty ? null : text,
      );
      if (pendingMedia.value?.path == file.path) {
        pendingMedia.value = null;
        messageController.clear();
      }
    } catch (error) {
      Get.snackbar('Chat', error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSending.value = false;
    }
  }

  void onTyping(String value) {
    if (!_socketService.isConnected) return;

    _typingTimer?.cancel();
    if (value.trim().isEmpty) {
      _emitTyping(false);
      return;
    }

    if (!_hasSentTyping) _emitTyping(true);
    _typingTimer = Timer(const Duration(milliseconds: 900), () {
      _emitTyping(false);
    });
  }

  void _emitTyping(bool isTyping) {
    if (!_socketService.isConnected) return;
    _socketService.emit('chat:typing', {
      'technicianId': technicianId,
      'isTyping': isTyping,
    });
    _hasSentTyping = isTyping;
  }

  void sendCounterOffer() {
    final label = labelController.text.trim();
    final value = valueController.text.trim();
    if (label.isEmpty || value.isEmpty) return;

    messages.add(
      ChatMessage(
        text: '$label  \$$value',
        isUser: true,
        time: _now(),
        type: ChatMessageType.offer,
        offerLabel: label,
        offerValue: '\$$value',
      ),
    );
    labelController.clear();
    valueController.clear();
    Get.back();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      messages.add(
        ChatMessage(
          text: 'Here is our revised offer:',
          isUser: false,
          time: _now(),
          type: ChatMessageType.offer,
          offerLabel: label,
          offerValue: '\$${(int.tryParse(value) ?? 0) + 10}',
          actionTaken: RxnBool(null),
        ),
      );
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

  ChatMessage _toViewMessage(api.ChatMessageModel message) {
    final isUser =
        message.senderId == AuthService.to.user.value?.user?.id ||
        message.senderRole.toLowerCase() == 'technician';
    return ChatMessage(
      messageId: message.id,
      text: message.text,
      isUser: isUser,
      time: _formatTime(message.createdAt),
      imagePath: message.messageType == api.ChatMessageType.image
          ? message.media.url
          : null,
      videoUrl: message.messageType == api.ChatMessageType.video
          ? message.media.url
          : null,
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _apiRepo.getChatHistoryApi(
        technicianId: technicianId,
      );
      messages.assignAll(history.messages.map(_toViewMessage));
      await _apiRepo.markChatReadApi(technicianId);
      _scrollToBottom();
    } catch (_) {
      Get.snackbar('Chat', 'Unable to load chat history');
    } finally {
      isLoading.value = false;
    }
  }

  void _connectSocket() {
    _onSocketConnected = () {
      _socketService.emit('chat:join', technicianId);
    };
    _onChatMessageEvent = _onSocketMessage;
    _onChatTypingEvent = _onSocketTyping;
    _socketService.on('chat:message', _onChatMessageEvent!);
    _socketService.on('chat:typing', _onChatTypingEvent!);
    _socketService.addConnectionListener(_onSocketConnected!);
    _socketService.connectAndJoin(technicianId: technicianId);
    if (_socketService.isConnected) _onSocketConnected!();
  }

  void _onSocketMessage(dynamic payload) {
    final raw = payload is Map ? payload['message'] : null;
    if (raw is! Map) return;
    final message = api.ChatMessageModel.fromJson(
      Map<String, dynamic>.from(raw),
    );
    if (message.id.isNotEmpty &&
        messages.any((item) => item.messageId == message.id))
      return;
    messages.add(_toViewMessage(message));
    _scrollToBottom();
    if (!(_toViewMessage(message).isUser))
      _apiRepo.markChatReadApi(technicianId);
  }

  void _onSocketTyping(dynamic payload) {
    final event = _parseTypingPayload(payload);
    if (event == null) return;

    final eventTechnicianId = event['technicianId']?.toString() ?? '';
    final senderRole = event['senderRole']?.toString().toLowerCase() ?? '';
    if (eventTechnicianId.isNotEmpty && eventTechnicianId != technicianId)
      return;
    if (eventTechnicianId.isEmpty &&
        senderRole.isNotEmpty &&
        senderRole != 'admin')
      return;

    final isTyping = event['isTyping'] == true;
    _agentTypingTimer?.cancel();
    isAgentTyping.value = isTyping;
    if (isTyping) {
      _agentTypingTimer = Timer(const Duration(seconds: 3), () {
        isAgentTyping.value = false;
      });
    }
  }

  Map<String, dynamic>? _parseTypingPayload(dynamic payload) {
    dynamic value = payload;
    if (value is String) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        return null;
      }
    }
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    final nested = map['data'] ?? map['typing'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return map;
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
    technicianId = AuthService.to.user.value?.user?.id ?? '';
    if (technicianId.isNotEmpty) {
      _loadHistory();
      _connectSocket();
    } else {
      isLoading.value = false;
    }
    // Tell FirebaseService the chat screen is open so incoming chat
    // notifications are suppressed while the user can see the messages.
    try {
      FirebaseService.to.onChatScreenOpened(AppRoutes.chatSupportScreen);
    } catch (_) {}
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    _agentTypingTimer?.cancel();
    _emitTyping(false);
    if (technicianId.isNotEmpty && _socketService.isConnected) {
      _socketService.emit('chat:leave', technicianId);
    }
    if (_onSocketConnected != null) {
      _socketService.removeConnectionListener(_onSocketConnected!);
    }
    if (_onChatMessageEvent != null) {
      _socketService.off('chat:message', _onChatMessageEvent!);
    }
    if (_onChatTypingEvent != null) {
      _socketService.off('chat:typing', _onChatTypingEvent!);
    }
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
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Counter Offer',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.labelController,
            decoration: InputDecoration(
              labelText: 'Charge Name (e.g. Gas Charges)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.valueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (e.g. 49)',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.sendCounterOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA5732F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: const Text(
                'Send Counter Offer',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
