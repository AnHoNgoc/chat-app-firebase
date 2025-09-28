import 'package:chat_app_fb/controllers/users_list_controller.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final UsersListController controller;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final relationshipStatus =
      controller.getUserRelationshipStatus(user.id);

      if (relationshipStatus == UserRelationshipStatus.friends) {
        return SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textSecondaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildActionButton(relationshipStatus),
                  if (relationshipStatus ==
                      UserRelationshipStatus.friendRequestReceived) ...[
                    SizedBox(height: 4.h),
                    OutlinedButton.icon(
                      onPressed: () =>
                          controller.declineFriendRequest(user),
                      label: Text(
                        "Decline",
                        style: TextStyle(fontSize: 10.sp),
                      ),
                      icon: Icon(Icons.close, size: 14.sp),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 4.w,
                        ),
                        minimumSize: Size(0, 24.h),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(
            controller.getRelationshipButtonIcon(status),
            size: 16.sp,
          ),
          label: Text(
            controller.getRelationshipButtonText(status),
            style: TextStyle(fontSize: 12.sp),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipButtonColor(status),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            minimumSize: Size(0, 32.h),
          ),
        );

      case UserRelationshipStatus.friendRequestSent:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: controller
                    .getRelationshipButtonColor(status)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: controller.getRelationshipButtonColor(status),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getRelationshipButtonIcon(status),
                    color: controller.getRelationshipButtonColor(status),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    controller.getRelationshipButtonText(status),
                    style: TextStyle(
                      color: controller.getRelationshipButtonColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            ElevatedButton.icon(
              onPressed: () => _showCancelRequestDialog(),
              icon: Icon(Icons.cancel_outlined, size: 14.sp),
              label: Text(
                "Cancel",
                style: TextStyle(fontSize: 10.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                minimumSize: Size(0, 24.h),
              ),
            ),
          ],
        );

      case UserRelationshipStatus.friendRequestReceived:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(
            controller.getRelationshipButtonIcon(status),
            size: 16.sp,
          ),
          label: Text(
            controller.getRelationshipButtonText(status),
            style: TextStyle(fontSize: 12.sp),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipButtonColor(status),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            minimumSize: Size(0, 32.h),
          ),
        );

      case UserRelationshipStatus.blocked:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            border: Border.all(color: AppTheme.errorColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: AppTheme.errorColor, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                "Blocked",
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );

      case UserRelationshipStatus.friends:
        return SizedBox.shrink();
    }
  }

  void _showCancelRequestDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          "Cancel Friend Request",
          style: TextStyle(fontSize: 16.sp),
        ),
        content: Text(
          "Are you sure you want to cancel the friend request to ${user.displayName}",
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Keep Request", style: TextStyle(fontSize: 12.sp)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelFriendRequest(user);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child:
            Text("Cancel Request", style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}
