import 'package:chat_app_fb/controllers/friend_requests_controller.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:chat_app_fb/views/widgets/friend_request_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FriendRequestView extends GetView<FriendRequestsController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friend Request',
          style: TextStyle(fontSize: 18.sp),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTab(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: controller.selectedTabIndex == 0
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 20.r,
                            color: controller.selectedTabIndex == 0
                                ? Colors.white
                                : AppTheme.textSecondaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Received (${controller.receiveRequest.length})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: controller.selectedTabIndex == 0
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTab(1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: controller.selectedTabIndex == 1
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send,
                            size: 20.r,
                            color: controller.selectedTabIndex == 1
                                ? Colors.white
                                : AppTheme.textSecondaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Sent (${controller.sentRequest.length})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: controller.selectedTabIndex == 1
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: controller.selectedTabIndex,
                children: [
                  _buildReceivedRequestsTab(),
                  _buildSentRequestsTab(),
                  Container(),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsTab() {
    return Obx(() {
      if (controller.receiveRequest.isEmpty) {
        return _buildEmptyState(
          icon: Icons.info_outline,
          title: 'No Friend Requests',
          message:
          'When someone sends you a friend request, it will appear here.',
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.receiveRequest.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final request = controller.receiveRequest[index];
          final sender = controller.getUser(request.senderId);
          if (sender == null) return SizedBox.shrink();

          return FriendRequestItem(
            request: request,
            user: sender,
            timeText: controller.getRequestTimeText(request.createdAt),
            isReceived: true,
            onAccept: () => controller.acceptRequest(request),
            onDecline: () => controller.declineFriendRequest(request),
          );
        },
      );
    });
  }

  Widget _buildSentRequestsTab() {
    return Obx(() {
      if (controller.sentRequest.isEmpty) {
        return _buildEmptyState(
          icon: Icons.info_outline,
          title: 'No Sent Requests',
          message: 'Friend Requests you send will appear here.',
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.sentRequest.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final request = controller.sentRequest[index];
          final receiver = controller.getUser(request.receiverId);
          if (receiver == null) return SizedBox.shrink();

          return FriendRequestItem(
            request: request,
            user: receiver,
            timeText: controller.getRequestTimeText(request.createdAt),
            isReceived: false,
            statusText: controller.getStatusText(request.status),
            statusColor: controller.getStatusColor(request.status),
          );
        },
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                icon,
                size: 40.r,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: Get.textTheme.bodyMedium?.copyWith(
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