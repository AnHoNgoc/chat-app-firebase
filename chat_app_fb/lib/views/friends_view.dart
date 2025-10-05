import 'package:chat_app_fb/controllers/friends_controller.dart';
import 'package:chat_app_fb/views/widgets/friend_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class FriendsView extends GetView<FriendsController> {

  @override
  Widget build(BuildContext context) {

    print(">>> FindPeople build() chạy với controller:");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Friends",
          style: TextStyle(fontSize: 18.sp),
        ),
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: controller.openFriendRequests,
            icon: Icon(Icons.person_add_alt_1, size: 24.r),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.5),
                  width: 1.w,
                ),
              ),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: "Search Friends",
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 22.r),
                suffixIcon: Obx(() {
                  return controller.searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: Icon(Icons.clear, size: 22.r),
                  )
                      : SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                  BorderSide(color: AppTheme.primaryColor, width: 2.w),
                ),
                filled: true,
                fillColor: AppTheme.cardColor,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshFriends,
              child: Obx(() {
                if (controller.isLoading && controller.friends.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.filteredFriends.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.filteredFriends.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final friend = controller.filteredFriends[index];
                    return FriendListItem(
                      friend: friend,
                      lastSeenText: controller.getLastSeenText(friend),
                      onTap: () => controller.startChat(friend),
                      onRemove: () => controller.removeFriend(friend),
                      onBlock: () => controller.blockedFriend(friend),
                    );
                  },
                );
              }),
            ),
          )
        ],
      ),
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
                Icons.people_outline,
                size: 50.r,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'No friends found'
                  : 'No friends yet',
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add friends to start chatting with them',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.searchQuery.isNotEmpty) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: controller.openFriendRequests,
                icon: Icon(Icons.person_search, size: 20.r),
                label: Text("View Friend Requests",
                    style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 20.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}