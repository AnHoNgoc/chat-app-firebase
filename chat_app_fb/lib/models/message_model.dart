enum MessageType {text}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final bool isEdited;
  final DateTime? editedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.isEdited = false,
    this.editedAt,
  });

  /// Convert to Map (để lưu Firestore / DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.microsecondsSinceEpoch,
      'isRead': isRead,
      'isEdited': isEdited,
      'editedAt': editedAt?.microsecondsSinceEpoch,
    };
  }

  /// Convert from Map (khi lấy từ Firestore / DB)
  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMicrosecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null
          ? DateTime.fromMicrosecondsSinceEpoch(map['editedAt'])
          : null,
    );
  }

  /// copyWith để update 1 phần dữ liệu
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}