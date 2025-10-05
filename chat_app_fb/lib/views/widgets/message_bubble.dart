import 'package:chat_app_fb/models/message_model.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;
  final bool showTime;
  final String timeText;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.showTime,
    required this.timeText,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTime) ...[
          SizedBox(height: 16.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ] else
          SizedBox(height: 4.h),
        Row(
          mainAxisAlignment:
          isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMyMessage) ...[
              SizedBox(width: 0.w),
            ],
            Flexible(
              child: GestureDetector(
                onLongPress: onLongPress,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isMyMessage ? AppTheme.primaryColor : AppTheme.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: isMyMessage ? Radius.circular(20.r) : Radius.circular(4.r),
                      bottomRight: isMyMessage ? Radius.circular(4.r) : Radius.circular(20.r),
                    ),
                    border: isMyMessage
                        ? null
                        : Border.all(color: AppTheme.borderColor, width: 1.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8.r,
                        offset: Offset(0.w, 2.h),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isMyMessage
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                      if (message.isEdited) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Edited',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isMyMessage
                                ? Colors.white.withOpacity(0.7)
                                : AppTheme.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                            fontSize: 12.sp,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            if (isMyMessage) ...[
              SizedBox(width: 8.w),
              _buildMessageStatus(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMessageStatus() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Icon(
        message.isRead ? Icons.done_all : Icons.done,
        size: 16.r,
        color: message.isRead
            ? AppTheme.primaryColor
            : AppTheme.textSecondaryColor,
      ),
    );
  }
}
