import 'package:chat_app_fb/controllers/chat_controller.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:chat_app_fb/views/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final String chatId;
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    chatId = Get.arguments?['chatId'] ?? '';

    if (!Get.isRegistered<ChatController>(tag: chatId)) {
      Get.put<ChatController>(ChatController(), tag: chatId);
    }
    controller = Get.find<ChatController>(tag: chatId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print(">>> Chat View  build() chạy với controller:");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.delete<ChatController>(tag: chatId);
            Get.back();
          },
          icon: Icon(Icons.arrow_back, size: 22.r),
        ),
        title: Obx(() {
          final otherUser = controller.otherUser;
          if (otherUser == null) return Text('Chat', style: TextStyle(fontSize: 16.sp));
          return Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppTheme.primaryColor,
                child: otherUser.photoURL.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    otherUser.photoURL,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child; // ảnh đã load xong ✅

                      // 🔹 đang tải ảnh → hiện vòng xoay nhỏ
                      return Center(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // 🔹 lỗi ảnh → fallback sang chữ cái đầu
                      return Center(
                        child: Text(
                          otherUser.displayName.isNotEmpty
                              ? otherUser.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      otherUser.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        color: otherUser.isOnline
                            ? AppTheme.successColor
                            : AppTheme.textSecondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          );
        }),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') controller.deleteChat();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: AppTheme.errorColor, size: 22.r),
                  title: Text('Delete Chat', style: TextStyle(fontSize: 14.sp)),
                  contentPadding: EdgeInsets.zero,
                ),
              )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMyMessage = controller.isMyMessage(message);
                  final showTime = index == 0 ||
                      controller.messages[index - 1].timestamp
                          .difference(message.timestamp)
                          .inMinutes
                          .abs() >
                          5;

                  return MessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                    showTime: showTime,
                    timeText:
                    controller.formatMessageTime(message.timestamp),
                    onLongPress: isMyMessage
                        ? () => _showMessageOptions(message)
                        : null,
                  );
                },
              );
            }),
          ),
          _buildMessageInput()
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        controller.onChatResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        controller.onChatPaused();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 20.w,
                          ),
                        ),
                        maxLines: null,
                        style: TextStyle(fontSize: 14.sp),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Obx(
                          () => Container(
                        decoration: BoxDecoration(
                          color: controller.isTyping
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: IconButton(
                          onPressed: controller.isSending
                              ? null
                              : controller.sendMessage,
                          icon: Icon(
                            Icons.send_rounded,
                            size: 22.r,
                            color: controller.isTyping
                                ? Colors.white
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
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
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.chat_outlined,
                size: 40.r,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Start the conversation',
              style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Send a message to get the chat started',
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

  void _showMessageOptions(dynamic message) {
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
            ListTile(
              leading:
              Icon(Icons.edit, color: AppTheme.primaryColor, size: 22.r),
              title: Text('Edit Message', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Get.back();
                _showEditDialog(message);
              },
            ),
            ListTile(
              leading:
              Icon(Icons.delete, color: AppTheme.errorColor, size: 22.r),
              title: Text('Delete Message', style: TextStyle(fontSize: 14.sp)),
              onTap: () {
                Get.back();
                _showDeleteDialog(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(dynamic message) {
    final editController = TextEditingController(text: message.content);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Message', style: TextStyle(fontSize: 16.sp)),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Enter new message',
            hintStyle: TextStyle(fontSize: 14.sp),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                controller.editMessage(message, editController.text.trim());
                Get.back();
              }
            },
            child: Text('Save', style: TextStyle(fontSize: 14.sp)),
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic message) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Message', style: TextStyle(fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete this message? This cannot be undone',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp))),
          TextButton(
            onPressed: () {
              controller.deleteMessage(message);
              Get.back();
            },
            child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
          )
        ],
      ),
    );
  }
}
