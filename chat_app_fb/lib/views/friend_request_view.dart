import 'package:chat_app_fb/controllers/friend_requests_controller.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:chat_app_fb/views/widgets/friend_request_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FriendRequestView extends GetView<FriendRequestsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Request'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor)
            ),
            child: Obx(() =>
              Row(
                children: [
                  Expanded(child: GestureDetector(
                    onTap: () => controller.changeTab(0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.selectedTabIndex == 0
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            color: controller.selectedTabIndex == 0
                              ? Colors.white
                              : AppTheme.textSecondaryColor
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Received (${controller.receiveRequest.length})',
                            style: TextStyle(
                              color: controller.selectedTabIndex == 0
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                        )
                      ),
                    )),

                  Expanded(child: GestureDetector(
                    onTap: () => controller.changeTab(1),
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: controller.selectedTabIndex == 1
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.send,
                                color: controller.selectedTabIndex == 1
                                    ? Colors.white
                                    : AppTheme.textSecondaryColor
                            ),
                            SizedBox(width: 8),
                            Text(
                                'Sent (${controller.sentRequest.length})',
                                style: TextStyle(
                                    color: controller.selectedTabIndex == 1
                                        ? Colors.white
                                        : AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ],
                        )
                    ),
                  )),
                ],
              )
            ),
          ),
          
          Expanded(child: Obx((){
            return IndexedStack(
              index: controller.selectedTabIndex,
              children: [
                _buildReceivedRequestsTab(),
                _buildSentRequestsTab(),
                Container()
              ],
            );
          })
          )
        ],
      )
    );
  }
  
  Widget _buildReceivedRequestsTab() {
    return Obx(() {
      if(controller.receiveRequest.isEmpty){
        return _buildEmptyState(
            icon: Icons.info_outline, 
            title: 'No Friend Requests',
            message: 'When someone sends you a friend request, it will appear here.'
        );
      } 
      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: controller.receiveRequest.length,
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemBuilder: (context, index) {
         final request = controller.receiveRequest[index];
         final sender = controller.getUser(request.senderId);
         if(sender == null){
           return SizedBox.shrink();
         }

         return FriendRequestItem(
           request: request,
           user: sender,
           timeText: controller.getRequestTimeText(request.createdAt),
           isReceived: true,
           onAccept: () => controller.acceptRequest(request),
           onDecline: () => controller.declineFriendRequest(request)
         );
        }
      );
    });
  }


  Widget _buildSentRequestsTab() {
    return Obx(() {
      if(controller.receiveRequest.isEmpty){
        return _buildEmptyState(
            icon: Icons.info_outline,
            title: 'No Sent Requests',
            message: 'Friend Requests you send will appear here.'
        );
      }
      return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: controller.sentRequest.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final request = controller.sentRequest[index];
            final receiver = controller.getUser(request.receiverId);
            if(receiver == null){
              return SizedBox.shrink();
            }

            return FriendRequestItem(
              request: request,
              user: receiver,
              timeText: controller.getRequestTimeText(request.createdAt),
              isReceived: false,
              statusText: controller.getStatusText(request.status),
              statusColor: controller.getStatusColor(request.status)
            );
          }
      );
    });
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50)
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Get.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),

      ),

    );
  }

}