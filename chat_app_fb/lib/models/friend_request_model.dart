enum FriendRequestStatus {pending, accepted, declined}
class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? message;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.message,
  });

  /// Convert to Map (để lưu Firestore / DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name , // Lưu dạng string: "pending", "accepted", "rejected"
      'createdAt': createdAt.microsecondsSinceEpoch,
      'respondedAt': respondedAt?.microsecondsSinceEpoch,
      'message': message,
    };
  }

  static FriendRequestModel fromMap(Map<String, dynamic> map) {
    return FriendRequestModel(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      status: FriendRequestStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.fromMicrosecondsSinceEpoch(map['createdAt']),
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMicrosecondsSinceEpoch(map['respondedAt'])
          : null,
      message: map['message'],
    );
  }

  /// copyWith (để update trạng thái hoặc message)
  FriendRequestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }
}