import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/controllers/home_controller.dart';
import 'package:chat_app_fb/controllers/main_controller.dart';
import 'package:chat_app_fb/views/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class HomeView extends GetView<HomeController> {

  @override
  Widget build(BuildContext context) {

    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, authController),
      body: Column(
        children: [
          _buildSearchBar(),
          Obx(() => controller.isSearching && controller.searchQuery.isNotEmpty
              ? _buildSearchResults()
              : _buildQuickFilters()),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshChats,
              child: Obx(() {
                if (controller.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.chats.isEmpty) {
                  if (controller.isSearching && controller.searchQuery.isNotEmpty) {
                    return _buildNoSearchResults();
                  } else if (controller.activeFilter != 'All') {
                    return _buildNoFilterResults();
                  } else  {
                    return _buildEmptyState();
                  }
                }
                return _buildChatsList();
              }),
            ),
          )
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AuthController authController) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textSecondaryColor,
      elevation: 0,
      title: Obx(() =>
          Text(controller.isSearching ? 'Search Results' : 'Message')),
      automaticallyImplyLeading: false,
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryColor,
      ),
      actions: [
        Obx(() => controller.isSearching
            ? IconButton(
          onPressed: controller.clearSearch,
          icon: Icon(Icons.clear_rounded, size: 20.sp),
        )
            : _buildNotificationButton())
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Obx(() {
      final unreadNotifications = controller.getUnreadNotificationsCount();

      return Container(
        margin: EdgeInsets.only(right: 8.w),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: controller.openNotifications,
                icon: Icon(Icons.notifications_outlined, size: 22.sp),
                splashRadius: 20.r,
              ),
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 6.w,
                top: 6.h,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white, width: 1.5.w),
                  ),
                  constraints: BoxConstraints(
                      minHeight: 16.h,
                      minWidth: 16.w
                  ),
                  child: Text(
                    unreadNotifications > 99
                        ? '99+'
                        : unreadNotifications.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 15.w, 12.h),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(12.r)),
        child: TextField(
          onChanged: controller.onSearchChanged,
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
              hintText: 'Search conversation...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15.sp),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[500],
                size: 20.sp,
              ),
              suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                  ? IconButton(
                  onPressed: controller.clearSearch,
                  icon: Icon(Icons.clear_rounded,
                      color: Colors.grey[500], size: 18.sp))
                  : SizedBox.shrink()),
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w)),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => _buildFilterChip(
                'All', () => controller.setFilter('All'),
                controller.activeFilter == 'All')),
            SizedBox(width: 8.w),
            Obx(() => _buildFilterChip(
                'Unread (${controller.getUnreadCount()})',
                    () => controller.setFilter('Unread'),
                controller.activeFilter == 'Unread')),
            SizedBox(width: 8.w),
            Obx(() => _buildFilterChip(
                'Recent (${controller.getRecentCount()})',
                    () => controller.setFilter('Recent'),
                controller.activeFilter == 'Recent')),
            SizedBox(width: 8.w),
            Obx(() => _buildFilterChip(
                'Active (${controller.getActiveCount()})',
                    () => controller.setFilter('Active'),
                controller.activeFilter == 'Active')),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 18.w, 8.h),
      child: Row(
        children: [
          Obx(() => Text(
            'Found ${controller.filteredChats.length} result${controller.filteredChats.length == 1 ? '' : 's'}',
            style: TextStyle(
                fontSize: 14.sp, color: AppTheme.textSecondaryColor),
          )),
          Spacer(),
          TextButton(
              onPressed: controller.clearSearch,
              child: Text(
                'Clear',
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ))
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          )),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'No conversation found',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor),
              ),
              SizedBox(height: 8.h),
              Obx(() => Text(
                'No result for "${controller.searchQuery}"',
                style: TextStyle(color: AppTheme.textSecondaryColor),
                textAlign: TextAlign.center,
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFilterResults() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          )),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getFilterIcon(controller.activeFilter),
                  size: 64.sp, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'No ${controller.activeFilter.toLowerCase()} conversations',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor),
              ),
              SizedBox(height: 8.h),
              Text(
                _getFilterEmptyMessage(controller.activeFilter),
                style: TextStyle(color: AppTheme.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => controller.setFilter('All'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r))),
                child: Text('Show All Conversations'),
              )
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Unread':
        return Icons.mark_email_unread_outlined;
      case 'Recent':
        return Icons.schedule_outlined;
      case 'Active':
        return Icons.trending_up_outlined;
      default:
        return Icons.filter_list_outlined;
    }
  }

  String _getFilterEmptyMessage(String filter) {
    switch (filter) {
      case 'Unread':
        return 'All your conversations are up to date';
      case 'Recent':
        return 'No conversations from the last 3 days';
      case 'Active':
        return 'No conversations from the last week';
      default:
        return 'No conversation found';
    }
  }

  Widget _buildChatsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          if (!controller.isSearching || controller.searchQuery.isEmpty)
            _buildChatHeader(),
          Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: controller.isSearching ? 16.h : 8.h,
                  horizontal: 16.w,
                ),
                itemCount: controller.chats.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1.h, color: Colors.grey[200], indent: 72.w),
                itemBuilder: (context, index) {
                  final chat = controller.chats[index];
                  final otherUser = controller.getOtherUser(chat);

                  if (otherUser == null) {
                    return SizedBox.shrink();
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: ChatListItem(
                        chat: chat,
                        otherUser: otherUser,
                        lastMessageTime: controller
                            .formatLastMessageTime(chat.lastMessageTime),
                        onTap: () => controller.openChat(chat)),
                  );
                },
              ))
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            String title = 'Recent Chats';
            switch (controller.activeFilter) {
              case 'Unread':
                title = 'Unread Messages';
                break;
              case 'Recent':
                title = 'Recent Messages';
                break;
              case 'Active':
                title = 'Active Messages';
                break;
            }

            return Text(
              title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor),
            );
          }),
          Row(
            children: [
              if (controller.activeFilter != 'All')
                TextButton(
                  onPressed: controller.clearAllFilters,
                  child: Text(
                    'Clear Filter',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            )),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyStateIcon(),
                SizedBox(height: 24.h),
                _buildEmptyStateText(),
                SizedBox(height: 24.h),
                _buildEmptyStateActions()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcon() {
    return Container(
      width: 140.w,
      height: 140.w,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ]),
          borderRadius: BorderRadius.circular(70.r)),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        size: 64.sp,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyStateText() {
    return Column(
      children: [
        Text(
          'No conversation yet',
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor),
        ),
        SizedBox(height: 8.h),
        Text(
          'Connect with friends and start meaningful conversations',
          style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textSecondaryColor,
              height: 1.4),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12.r,
                offset: Offset(0, 4.h))
          ]),
      child: FloatingActionButton.extended(
        onPressed: () {
          final mainController = Get.find<MainController>();
          mainController.changeTabIndex(1);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: Icon(Icons.chat_rounded, size: 30.sp),
        label: Text(
          'New Chat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildEmptyStateActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(2);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r))),
            icon: Icon(Icons.person_search_rounded, size: 20.sp),
            label: Text(
              'Find People',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(1);
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r))),
            icon: Icon(Icons.people_alt_rounded, size: 20.sp),
            label: Text(
              'View Friends',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}