import 'package:chat_app_fb/controllers/notification_controller.dart';
import 'package:chat_app_fb/views/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class NotificationView extends GetView<NotificationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 18.sp), // scale text
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, size: 24.r), // icon scale
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.getUnreadCount();
            return unreadCount > 0
                ? TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(fontSize: 14.sp),
              ),
            )
                : SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w), // padding scale
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final user = notification.data['senderId'] != null
                ? controller.getUser(notification.data['senderId'])
                : notification.data['userId'] != null
                ? controller.getUser(notification.data['userId'])
                : null;

            return NotificationItem(
              notification: notification,
              user: user,
              timeText: controller.getNotificationTimeText(notification.createdAt),
              icon: controller.getNotificationIcon(notification.type),
              iconColor: controller.getNotificationIconColor(notification.type),
              onTap: () => controller.handleNotificationTap(notification),
              onDelete: () => controller.deleteNotification(notification),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 50.r,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No notifications',
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                fontSize: 20.sp,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'When you receive friend requests, messages, or other updates, they will appear here',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}