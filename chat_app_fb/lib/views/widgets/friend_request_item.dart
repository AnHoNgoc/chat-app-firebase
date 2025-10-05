import 'package:chat_app_fb/models/friend_request_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendRequestItem extends StatelessWidget {

  final FriendRequestModel request;
  final UserModel user;
  final String timeText;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? statusText;
  final Color? statusColor;

  const FriendRequestItem({
    super.key,
    required this.request,
    required this.user,
    required this.timeText,
    required this.isReceived,
    this.onAccept,
    this.onDecline,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppTheme.primaryColor,
                  child: user.photoURL.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Image.network(
                      user.photoURL,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  )
                      : Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isReceived && request.status == FriendRequestStatus.pending) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDecline,
                      icon: Icon(Icons.close, size: 16.r),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.errorColor),
                        foregroundColor: AppTheme.errorColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      label: Text(
                        'Decline',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check, size: 16.r),
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      label: Text(
                        'Accept',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (!isReceived && statusText != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: statusColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor ?? AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(), size: 16.r, color: statusColor),
                    SizedBox(width: 6.w),
                    Text(
                      statusText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor ?? AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case FriendRequestStatus.accepted:
        return Icons.check_circle;
      case FriendRequestStatus.declined:
        return Icons.cancel;
      case FriendRequestStatus.pending:
      default:
        return Icons.hourglass_top;
    }
  }
}

