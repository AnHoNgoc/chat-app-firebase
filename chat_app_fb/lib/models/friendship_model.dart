class FriendshipModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final bool isBlocked;
  final String? blockedBy;

  FriendshipModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.isBlocked = false,
    this.blockedBy,
  });

  /// Convert to Map (để lưu Firestore / DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'createdAt': createdAt.microsecondsSinceEpoch,
      'isBlocked': isBlocked,
      'blockedBy': blockedBy,
    };
  }

  /// Convert from Map (lấy từ Firestore / DB)
  static FriendshipModel fromMap(Map<String, dynamic> map) {
    return FriendshipModel(
      id: map['id'],
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
      createdAt: DateTime.fromMicrosecondsSinceEpoch(map['createdAt']),
      isBlocked: map['isBlocked'] ?? false,
      blockedBy: map['blockedBy'],
    );
  }

  /// copyWith để update 1 phần dữ liệu
  FriendshipModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
    bool? isBlocked,
    String? blockedBy,
  }) {
    return FriendshipModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }

  String getOtherUserId(String currentUSerId) {
    return currentUSerId == user1Id ? user2Id : user1Id;
  }

  bool isBlockedBy(String userId) {
    return isBlocked && blockedBy == userId;
  }
}