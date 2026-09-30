enum ChatMessageType { text, image, video }

class ChatMedia {
  final String url;
  final String key;
  final String mimeType;
  final int size;

  const ChatMedia({
    this.url = '',
    this.key = '',
    this.mimeType = '',
    this.size = 0,
  });

  factory ChatMedia.fromJson(Map<String, dynamic>? json) {
    return ChatMedia(
      url: json?['url']?.toString() ?? '',
      key: json?['key']?.toString() ?? '',
      mimeType: json?['mimeType']?.toString() ?? '',
      size: (json?['size'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String technicianId;
  final String senderId;
  final String senderRole;
  final String receiverId;
  final ChatMessageType messageType;
  final String text;
  final ChatMedia media;
  final List<String> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessageModel({
    this.id = '',
    this.technicianId = '',
    this.senderId = '',
    this.senderRole = '',
    this.receiverId = '',
    this.messageType = ChatMessageType.text,
    this.text = '',
    this.media = const ChatMedia(),
    this.readBy = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? createdAt;
    final type = json['messageType']?.toString().toLowerCase();

    return ChatMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      technicianId: json['technicianId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      messageType: ChatMessageType.values.firstWhere(
        (value) => value.name == type,
        orElse: () => ChatMessageType.text,
      ),
      text: json['text']?.toString() ?? '',
      media: ChatMedia.fromJson(json['media'] as Map<String, dynamic>?),
      readBy: (json['readBy'] as List<dynamic>?)?.map((value) => value.toString()).toList() ?? const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ChatHistoryModel {
  final List<ChatMessageModel> messages;
  final bool hasMore;

  const ChatHistoryModel({required this.messages, required this.hasMore});

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return ChatHistoryModel(
      messages: (data['messages'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList(),
      hasMore: data['hasMore'] as bool? ?? false,
    );
  }
}