import 'dart:async';

import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/models/friendship_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:chat_app_fb/service/fire_store_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {

  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;

  StreamSubscription? _friendshipsSubscriptions;
  List<FriendshipModel> get friendships => _friendships.toList();
  List<UserModel> get friends => _friends;
  List<UserModel> get filteredFriends => _filteredFriends;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadFriends();

    debounce(
      _searchQuery,
        (_) => _filterFriends(),
      time: Duration(milliseconds: 300)
    );
  }

  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();

    if(query.isEmpty){
      _filteredFriends.value = _friends;
    } else {
      _filteredFriends.value = _friends.where((friend) {
        return friend.displayName.toLowerCase().contains(query) ||
            friend.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  @override
  void onClose() {
    _friendshipsSubscriptions?.cancel();
    super.onClose();
  }

  void _loadFriends() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _isLoading.value = true;

      _friendshipsSubscriptions?.cancel();
      _friendshipsSubscriptions = _fireStoreService.getFriendsStream(currentUserId)
          .listen((friendshipList) async {
        _friendships.value = friendshipList;
        await _loadFriendDetails(currentUserId, friendshipList);
        _isLoading.value = false;
      });
    }
  }


  Future<void> _loadFriendDetails(
      String currentUserId,
      List<FriendshipModel> friendshipList
      ) async {

    final friendIds = friendshipList.map((f) => f.getOtherUserId(currentUserId)).toList();

    if (friendIds.isEmpty) {
      _friends.clear();
      _filteredFriends.clear();
      return;
    }

    // bindStream realtime từ Firestore
    _friends.bindStream(
        _fireStoreService.getUsersByIdsStream(friendIds)
    );

    // Khi _friends thay đổi, cập nhật filteredFriends
    ever<List<UserModel>>(_friends, (_) => _filterFriends());
  }


  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    final currentUserId = _authController.user?.uid;
    if(currentUserId != null){
      _loadFriends();
    }
  }

  Future<void> removeFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
       AlertDialog(
         title: Text("Remove Friend"),
         content: Text("Are you sure you want to remove ${friend.displayName} from your friend? "),
         actions: [
           TextButton(
             onPressed: () => Get.back(result: false),
             child: Text("Cancel")
           ),
           TextButton(
               onPressed: () => Get.back(result: true),
               style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
               child: Text("Remove")
           ),
         ],
       )
      );

      if (result == true) {
        final currentUSerId = _authController.user?.uid;
        if (currentUSerId != null) {
          await _fireStoreService.removeFriendShip(currentUSerId, friend.id);
          Get.snackbar(
            "Success",
            '${friend.displayName} has been removed from your friends.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: Duration(seconds: 4)
          );
        }
      }
    } catch(e) {
      Get.snackbar(
          "Error",
         'Failed to remove friend',
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: Duration(seconds: 4)
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> blockedFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
          AlertDialog(
            title: Text("Remove Friend"),
            content: Text("Are you sure you want to block ${friend.displayName} from your friend? "),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel")
              ),
              TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: Text("Block")
              ),
            ],
          )
      );

      if (result == true) {
        final currentUSerId = _authController.user?.uid;
        if (currentUSerId != null) {
          await _fireStoreService.blockUser(currentUSerId, friend.id);
          Get.snackbar(
              "Success",
              '${friend.displayName} has been blocked.',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
              duration: Duration(seconds: 4)
          );
        }
      }
    } catch(e) {
      Get.snackbar(
          "Error",
          'Failed to block friend',
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: Duration(seconds: 4)
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if(currentUserId != null) {
        Get.toNamed(
          AppRoutes.chat,
          arguments: {
            'chatId': null,
            'otherUser': friend,
            'isNewChat': true
          }
        );
      }
    } catch (e) {
      Get.snackbar(
          "Error",
          'Failed to start chat',
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: Duration(seconds: 4)
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
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
        return 'Last seen ${difference.inDays} d ago';
      } else {
        return 'Last seen on ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void openFriendRequests() {
    Get.toNamed(AppRoutes.friendRequests);
  }

  void clearError() {
    _error.value = '';
  }
}
