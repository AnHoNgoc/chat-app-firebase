import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/models/friend_request_model.dart';
import 'package:chat_app_fb/models/friendship_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:chat_app_fb/service/fire_store_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceived,
  friends,
  blocked
}

class UsersListController extends GetxController {

  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _error = ''.obs;

  final RxMap<String, UserRelationshipStatus> _userRelationships = <String, UserRelationshipStatus>{}.obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequests = <FriendRequestModel>[].obs;

  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  Map<String, UserRelationshipStatus> get userRelationships => _userRelationships;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationships();

    debounce(
      _searchQuery,
          (_) => _filterUsers(),
      time: Duration(milliseconds: 300),
    );
  }

  void _filterUsers() {

    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();


    if (query.isEmpty) {
      _filteredUsers.value = _users
          .where((user) => user.id != currentUserId)
          .toList();
    } else {
      _filteredUsers.value = _users.where((user) {
        final match = user.id != currentUserId &&
            (user.displayName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query));
        return match;
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    print("updateSearchQuery gọi từ controller: $hashCode, query: $query");
    _searchQuery.value = query;

  }

  void _loadUsers() async {
    _isLoading.value = true;

    _users.bindStream(_fireStoreService.getAllUsersStream());

    ever(_users, (List<UserModel> userList) {
      final currentUserId = _authController.user?.uid;
      final otherUsers = userList.where((user) => user.id != currentUserId).toList();

      if (_searchQuery.value.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        _filterUsers();
      }

      _isLoading.value = false;
    });
  }

  void _loadRelationships(){
    final currentUserId = _authController.user?.uid;

    if(currentUserId != null){
      _sentRequests.bindStream(
        _fireStoreService.getSentRequestsStream(currentUserId)
      );

      _receivedRequests.bindStream(
          _fireStoreService.getFriendRequestsStream(currentUserId)
      );

      _friendships.bindStream(
          _fireStoreService.getFriendsStream(currentUserId)
      );

      ever(_sentRequests, (_) => updateAllRelationshipsStatus());
      ever(_receivedRequests, (_) => updateAllRelationshipsStatus());
      ever(_friendships, (_) => updateAllRelationshipsStatus());
      ever(_users, (_) => updateAllRelationshipsStatus());
    }
  }

  void  updateAllRelationshipsStatus() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) return;

    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateRelationshipStatus (user.id);
        _userRelationships[user.id] = status;
      }
    }
  }

  UserRelationshipStatus _calculateRelationshipStatus(String userId) {
    final currentUserId = _authController.user?.uid;

    if(currentUserId == null) return UserRelationshipStatus.none;

    final friendship = _friendships.firstWhereOrNull(
        (f) =>
          (f.user1Id == currentUserId && f.user2Id == userId) ||
          (f.user1Id == userId && f.user2Id == currentUserId)
    );

    if (friendship != null) {
      if (friendship.isBlocked) {
        return UserRelationshipStatus.blocked;
      } else {
        return UserRelationshipStatus.friends;
      }
    }

    final sentRequest = _sentRequests.firstWhereOrNull(
        (r) => r.receiverId == userId && r.status == FriendRequestStatus.pending
    );

    if (sentRequest != null) {
      return UserRelationshipStatus.friendRequestSent;
    }

    final receiveRequest = _receivedRequests.firstWhereOrNull(
        (r) => r.senderId == userId && r.status == FriendRequestStatus.pending
    );

    if(receiveRequest != null) {
      return UserRelationshipStatus.friendRequestReceived;
    }
    return UserRelationshipStatus.none;
  }



  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> sendFriendRequest (UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if(currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,
          createdAt: DateTime.now()
        );

        _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
        await _fireStoreService.sendFriendRequest(request);
        Get.snackbar('Success', 'Friend Request Sent To ${user.displayName}');
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _error.value = e.toString();
      print("Error sending friend request: $e");
      Get.snackbar('Error', "Failed to send friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _sentRequests.firstWhereOrNull(
          (r) => r.receiverId == user.id && r.status == FriendRequestStatus.pending
        );

        if (request != null) {
          _userRelationships[user.id] = UserRelationshipStatus.none;
          await _fireStoreService.cancelFriendRequest(request.id);
          Get.snackbar('Success', "Friend Request Cancelled");
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
      _error.value = e.toString();
      print("Error cancelling friend request: $e");
      Get.snackbar('Error', "Failed to cancel friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future <void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _receivedRequests.firstWhereOrNull(
          (r) => r.senderId == user.id && r.status == FriendRequestStatus.pending
        );

        if (request != null) {
          _userRelationships[user.id] = UserRelationshipStatus.friends;
          await _fireStoreService.respondToFriendRequest(request.id, FriendRequestStatus.accepted);
          Get.snackbar('Success', "Friend Request Accepted");
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      print("Error accepting friend request: $e");
      Get.snackbar('Error', "Failed to accept friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future <void> declineFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _receivedRequests.firstWhereOrNull(
                (r) => r.senderId == user.id && r.status == FriendRequestStatus.pending
        );

        if (request != null) {
          _userRelationships[user.id] = UserRelationshipStatus.none;
          await _fireStoreService.respondToFriendRequest(request.id, FriendRequestStatus.declined);
          Get.snackbar('Success', "Friend Request Declined");
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      print("Error declining friend request: $e");
      Get.snackbar('Error', "Failed to decline friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null){
        final relationship = _userRelationships[user.id] ?? UserRelationshipStatus.none;
        if (relationship != UserRelationshipStatus.friends) {
          Get.snackbar('Info', "You can only chat with friend. Please send a friend request first.");
          return;
        }

        final chatId = await _fireStoreService.createOrGetChat(currentUserId, user.id);

        Get.toNamed(AppRoutes.chat, arguments: {'chatId' : chatId, 'otherUser': user});
      }
    } catch (e) {
      _error.value = e.toString();
      print("Error starting chat: $e");
      Get.snackbar('Error', "Failed to start chat");
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationshipStatus getUserRelationshipStatus (String userId) {
    return _userRelationships[userId] ?? UserRelationshipStatus.none;
  }

  String getRelationshipButtonText(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return 'Add Friend';
      case UserRelationshipStatus.friendRequestSent:
        return 'Request sent';
      case UserRelationshipStatus.friendRequestReceived:
        return 'Accept Request';
      case UserRelationshipStatus.friends:
        return 'Message';
      case UserRelationshipStatus.blocked:
        return 'Blocked';
    }
  }

  IconData getRelationshipButtonIcon(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Icons.person_add;
      case UserRelationshipStatus.friendRequestSent:
        return Icons.access_time;
      case UserRelationshipStatus.friendRequestReceived:
        return Icons.check;
      case UserRelationshipStatus.friends:
        return Icons.chat_bubble_outline;
      case UserRelationshipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipButtonColor(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Colors.blue;
      case UserRelationshipStatus.friendRequestSent:
        return Colors.orange;
      case UserRelationshipStatus.friendRequestReceived:
        return Colors.green;
      case UserRelationshipStatus.friends:
        return Colors.blue;
      case UserRelationshipStatus.blocked:
        return Colors.redAccent;
    }
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);
    switch (status) {
      case UserRelationshipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestSent:
        cancelFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestReceived:
        acceptFriendRequest(user);
        break;
      case UserRelationshipStatus.friends:
        startChat(user);
        break;
      case UserRelationshipStatus.blocked:
        Get.snackbar("Info", "You have blocked this user");
        break;
    }
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);

      if (difference.inMinutes <1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes} m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours} h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inHours} d ago';
      } else {
        return 'Last seen on ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void _clearError () {
    _error.value = '';
  }
}