import 'package:chat_app_fb/models/notification_model.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../service/fire_store_service.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;

  List<NotificationModel> get notifications => _notifications;
  Map<String, UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadUser();
  }

  void _loadNotifications(){
    final currentUserId = _authController.user?.uid;
    if(currentUserId != null) {
      _notifications.bindStream(_fireStoreService.getNotificationsStream(currentUserId));
    }
  }

  void _loadUser(){
    _users.bindStream(_fireStoreService.getAllUsersStream().map((userList){
     Map<String,UserModel> userMap = {};
     for (var user in userList){
       userMap[user.id] = user;
     }
     return userMap;
    }));
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> markAsRead(NotificationModel notification) async {
    try {
      if(!notification.isRead){
        await _fireStoreService.markNotificationAsRead(notification.id);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to mark  as read');
      print(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if(currentUserId != null){
        await _fireStoreService.markAllNotificationAsRead(currentUserId);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to mark all as read');
      print(e.toString());
    } finally  {
      _isLoading.value = false;
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      await _fireStoreService.deleteNotification(notification.id);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete notification');
      print(e.toString());
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    markAsRead(notification);

    switch(notification.type) {
      case NotificationType.friendRequest:
        Get.toNamed(AppRoutes.friendRequests);
        break;

      case NotificationType.friendRequestAccepted:
      case NotificationType.friendRequestDeclined:
        Get.toNamed(AppRoutes.friends);
        break;
      case NotificationType.newMessage:
        final userId = notification.data['userId'];
        if (userId != null) {
          final user = getUser(userId);
          if (user != null) {
            Get.toNamed(AppRoutes.chat, arguments: {
              'otherUser' : user
            });
          }
        }
        break;

      case NotificationType.friendRemoved:
        break;
    }
  }

  String getNotificationTimeText(DateTime createAt) {
    final now = DateTime.now();
    final difference = now.difference(createAt);

    if (difference.inMinutes <1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return 'Last seen ${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inHours} d ago';
    } else {
      return '${createAt.day}/${createAt.month}/${createAt.year}';
    }
 }

 IconData getNotificationIcon(NotificationType type) {
    switch(type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendRequestAccepted:
        return Icons.check_circle;
      case NotificationType.friendRequestDeclined:
        return Icons.cancel;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.friendRemoved:
        return Icons.person_remove;
    }
 }


  Color getNotificationIconColor(NotificationType type) {
    switch(type) {
      case NotificationType.friendRequest:
        return AppTheme.primaryColor;
      case NotificationType.friendRequestAccepted:
        return AppTheme.successColor;
      case NotificationType.friendRequestDeclined:
        return AppTheme.errorColor;
      case NotificationType.newMessage:
        return AppTheme.secondaryColor;
      case NotificationType.friendRemoved:
        return AppTheme.errorColor;
    }
  }

  int getUnreadCount() {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  void clearError() {
    _error.value = '';
  }


}