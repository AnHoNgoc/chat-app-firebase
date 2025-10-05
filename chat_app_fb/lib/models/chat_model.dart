import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> deleteBy;
  final Map<String, DateTime?> deleteAt;
  final Map<String, DateTime?> lastSeenBy;
  final DateTime createAt;
  final DateTime updateAt;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.deleteBy = const {},
    this.deleteAt = const {},
    this.lastSeenBy = const {},
    required this.createAt,
    required this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'deleteBy': deleteBy,
      'deleteAt': deleteAt.map(
            (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'lastSeenBy': lastSeenBy.map(
            (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'createAt': createAt.millisecondsSinceEpoch,
      'updateAt': updateAt.millisecondsSinceEpoch,
    };
  }

  static ChatModel fromMap(Map<String, dynamic> map) {
    // Xử lý lastSeenBy
    Map<String, DateTime?> lastSeenMap = {};
    if (map['lastSeenBy'] != null) {
      final rawLastSeen = Map<String, dynamic>.from(map['lastSeenBy']);
      lastSeenMap = rawLastSeen.map(
            (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
        ),
      );
    }

    // Xử lý deleteAt
    Map<String, DateTime?> deleteAtMap = {};
    if (map['deleteAt'] != null) {
      final rawDeleteAt = Map<String, dynamic>.from(map['deleteAt']);
      deleteAtMap = rawDeleteAt.map(
            (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
        ),
      );
    }

    return ChatModel(
      id: map['id'] ?? "",
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : (map['lastMessageTime'] as Timestamp).toDate())
          : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      deleteBy: Map<String, bool>.from(map['deleteBy'] ?? {}),
      deleteAt: deleteAtMap,
      lastSeenBy: lastSeenMap,
      createAt: DateTime.fromMillisecondsSinceEpoch(map['createAt']),
      updateAt: DateTime.fromMillisecondsSinceEpoch(map['updateAt']),
    );
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? deleteBy,
    Map<String, DateTime?>? deleteAt,
    Map<String, DateTime?>? lastSeenBy,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      deleteBy: deleteBy ?? this.deleteBy,
      deleteAt: deleteAt ?? this.deleteAt,
      lastSeenBy: lastSeenBy ?? this.lastSeenBy,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  String getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  bool isDeleteBy(String userId) {
    return deleteBy[userId] ?? false;
  }

  DateTime? getDeleteAt(String userId) {
    return deleteAt[userId];
  }

  DateTime? getLastSeenBy(String userId) {
    return lastSeenBy[userId];
  }

  bool isMessageSeen(String currentUserId, String otherUserId){
    if (lastMessageSenderId == currentUserId){
      final otherUserLastSeen = getLastSeenBy(otherUserId);
      if(otherUserLastSeen != null && lastMessageTime != null){
        return otherUserLastSeen.isAfter(lastMessageTime!) ||
            otherUserLastSeen.isAtSameMomentAs(lastMessageTime!);
      }
    }
    return false;
  }
}