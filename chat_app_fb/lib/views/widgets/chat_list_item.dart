import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/models/chat_model.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/user_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final UserModel otherUser;
  final String lastMessageTime;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();
    final currentUserId = authController.user?.uid ?? '';
    final unreadCount = chat.getUnreadCount(currentUserId);

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showChatOptions(context, homeController),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppTheme.primaryColor,
                    child: otherUser.photoURL.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        otherUser.photoURL,
                        width: 56.w,
                        height: 56.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            otherUser.displayName.isNotEmpty
                                ? otherUser.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                        : Text(
                      otherUser.displayName.isNotEmpty
                          ? otherUser.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (otherUser.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherUser.displayName,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessageTime.isNotEmpty)
                          Text(
                            lastMessageTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: unreadCount > 0
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (chat.lastMessageSenderId == currentUserId) ...[
                                Icon(
                                  _getSeenStatusIcon(),
                                  size: 14.sp,
                                  color: _getSeenStatusColor(),
                                ),
                                SizedBox(width: 4.w),
                              ],
                              Expanded(
                                child: Text(
                                  chat.lastMessage ?? 'No message yet',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: unreadCount > 0
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondaryColor,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            margin: EdgeInsets.only(left: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              unreadCount > 99 ? '+99' : unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    if (chat.lastMessageSenderId == currentUserId) ...[
                      SizedBox(height: 2.h),
                      Text(
                        _getSeenStatusText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getSeenStatusColor(),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeenStatusIcon() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return Icons.done_all;
    } else {
      return Icons.done;
    }
  }

  Color _getSeenStatusColor() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return AppTheme.primaryColor;
    } else {
      return AppTheme.textSecondaryColor;
    }
  }

  String _getSeenStatusText() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return 'Seen';
    } else {
      return 'Delivered';
    }
  }

  void _showChatOptions(BuildContext context, HomeController homeController) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.deblur_outlined, color: AppTheme.errorColor),
              title: Text('Delete Chat'),
              subtitle: Text('This will delete that chat for you only'),
              onTap: () {
                Get.back();
                homeController.deleteChat(chat);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppTheme.primaryColor),
              title: Text('View Profile'),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
