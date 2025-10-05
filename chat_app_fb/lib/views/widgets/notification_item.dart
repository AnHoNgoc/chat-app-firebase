import 'package:chat_app_fb/models/notification_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationItem extends StatelessWidget {

  final NotificationModel notification;
  final UserModel? user;
  final String timeText;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    this.user,
    required this.timeText,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead
          ? null
          : AppTheme.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 15.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          )
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getNotificationBody(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      timeText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondaryColor,
                  size: 20.sp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationBody() {
    String body = notification.body;
    if (user != null) {
      switch (notification.type) {
        case NotificationType.friendRequest:
          body = '${user!.displayName} sent you a friend request';
          break;
        case NotificationType.friendRequestAccepted:
          body = '${user!.displayName} accepted your friend request';
          break;
        case NotificationType.friendRequestDeclined:
          body = '${user!.displayName} declined your friend request';
          break;
        case NotificationType.newMessage:
          body = '${user!.displayName} sent you a message';
          break;
        case NotificationType.friendRemoved:
          body = 'You are no longer friends with ${user!.displayName}';
          break;
      }
    }
    return body;
  }
}
