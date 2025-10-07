import 'package:chat_app_fb/models/friend_request_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/fire_store_service.dart';
import 'auth_controller.dart';

class FriendRequestsController extends GetxController {

  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FriendRequestModel> _receiveRequest = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _sentRequest = <FriendRequestModel>[].obs;
  final RxMap <String, UserModel> _users = <String,UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedTabIndex = 0.obs;

  List<FriendRequestModel> get receiveRequest => _receiveRequest;
  List<FriendRequestModel> get sentRequest => _sentRequest;
  Map<String,UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error =>  _error.value;
  int get selectedTabIndex => _selectedTabIndex.value;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadFriendRequest();
  }

  void _loadFriendRequest(){
    final currentUserId = _authController.user?.uid;

    if(currentUserId != null) {
      _receiveRequest.bindStream(
        _fireStoreService.getFriendRequestsStream(currentUserId)
      );
      _sentRequest.bindStream(
        _fireStoreService.getSentRequestsStream(currentUserId)
      );
    }
  }

  void _loadUsers() {
    _users.bindStream(
      _fireStoreService.getAllUsersStream().map((userList) {
        Map<String, UserModel> userMap = {};
        for (var user in userList){
          userMap[user.id] = user;
        }
        return userMap;
      })
    );
  }

  void changeTab(int index){
    _selectedTabIndex.value = index;
  }

  UserModel? getUser(String userId){
    return _users[userId];
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.respondToFriendRequest(request.id, FriendRequestStatus.accepted);
      Get.snackbar("Success", "Friend request accepted");
    } catch (e) {
      _error.value = "Failed to accept friend request: $e";
    } finally {
      _isLoading.value = false;
    }
  }


  Future<void> declineFriendRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.respondToFriendRequest(request.id, FriendRequestStatus.declined);
      Get.snackbar("Success", "Friend request declined");
    } catch (e) {
      _error.value = "Failed to decline friend request: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.unBlockUser(_authController.user!.uid, userId);
      Get.snackbar("Success", "User unlocked successfully");
    } catch (e) {
      _error.value = "Failed to unblock: $e";
    } finally {
      _isLoading.value = false;
    }
  }

  String getRequestTimeText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String getStatusText(FriendRequestStatus status) {
    switch (status){
      case FriendRequestStatus.pending:
        return "Pending";
      case FriendRequestStatus.accepted:
        return "Accepted";
      case FriendRequestStatus.declined:
      return "Declined";
    }
  }

  Color getStatusColor(FriendRequestStatus status) {
    switch (status){
      case FriendRequestStatus.pending:
        return Colors.orange;
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.declined:
        return Colors.redAccent;
    }
  }

  void clearError (){
    _error.value = '';
  }
}