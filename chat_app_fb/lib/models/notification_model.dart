enum NotificationType {
  friendRequest,
  friendRequestAccepted,
  friendRequestDeclined,
  newMessage,
  friendRemoved,
}
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  /// Convert to Map (lưu Firestore / DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.microsecondsSinceEpoch,
    };
  }

  /// Convert from Map (lấy từ Firestore / DB)
  static NotificationModel fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
      type: NotificationType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => NotificationType.friendRequest,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  /// copyWith để update 1 phần dữ liệu
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}