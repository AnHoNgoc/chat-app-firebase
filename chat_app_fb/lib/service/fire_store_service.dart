import 'package:chat_app_fb/models/chat_model.dart';
import 'package:chat_app_fb/models/friend_request_model.dart';
import 'package:chat_app_fb/models/friendship_model.dart';
import 'package:chat_app_fb/models/message_model.dart';
import 'package:chat_app_fb/models/notification_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllUsersStream(){
    return _fireStore.collection('users') // collection name
        .snapshots() // lấy stream real-time
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList()
    );
  }

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      await _fireStore.collection('friendRequests').doc(request.id).set(request.toMap());

      String notificationId = 'friend_request_${request.senderId}_${request.receiverId}_${DateTime.now().microsecondsSinceEpoch}';

      await createNotification(
        NotificationModel(
          id: notificationId,
          userId: request.receiverId,
          title: 'New Friend Request',
          body: 'You have received a new friend request',
          type: NotificationType.friendRequest,
          createdAt: DateTime.now()
        )
      );
    }catch(e){
      throw Exception("Failed To Send Friend Request: ${e.toString()}");
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try{
      DocumentSnapshot requestDoc = await _fireStore
          .collection('friendRequests')
          .doc(requestId)
          .get();
      if(requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>
        );

        await _fireStore.collection('friendRequests').doc(requestId).delete();

        await deleteNotificationsByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequest,
          request.senderId
        );
      }
    } catch (e) {
      throw Exception('Failed to cancel friend request: ${e.toString()}');
    }
  }

  Future<void> respondToFriendRequest(
      String requestId,
      FriendRequestStatus status,
  ) async {
    try {
      await _fireStore.collection('friendRequests').doc(requestId).update({
        'status':status.name,
        'respondedAt': DateTime.now().millisecondsSinceEpoch
      });

      DocumentSnapshot requestDoc = await _fireStore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (requestDoc.exists){
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String,dynamic>
        );

        if(status == FriendRequestStatus.accepted){
          await createFriendShip(request.senderId, request.receiverId);

          await createNotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Accepted',
              body: 'Your friend request has been accepted',
              type: NotificationType.friendRequestAccepted,
              data: {'userId': request.receiverId},
              createdAt: DateTime.now()
            )
          );

          await _removeNotificationForCancelledRequest(
            request.receiverId,
            request.senderId
          );
        } else if (status == FriendRequestStatus.declined){
          await createNotification(
              NotificationModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: request.senderId,
                  title: 'Friend Request Declined',
                  body: 'Your friend request has been declined',
                  type: NotificationType.friendRequestDeclined,
                  data: {'userId': request.receiverId},
                  createdAt: DateTime.now()
              )
          );

          await _removeNotificationForCancelledRequest(
              request.receiverId,
              request.senderId
          );
        }
      }
    } catch (e) {
      throw Exception('Failed To Respond Friend Request: ${e.toString()}');
    }
  }


  Stream<List<FriendRequestModel>> getFriendRequestsStream (String userId){
    return _fireStore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList()
        );
  }

  Stream<List<FriendRequestModel>> getSentRequestsStream (String userId){
    return _fireStore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (snapshot) => snapshot.docs
            .map((doc) => FriendRequestModel.fromMap(doc.data()))
            .toList()
    );
  }

  Future<FriendRequestModel?> getFriendRequest(String senderId, String receiverId) async {
    try {
      QuerySnapshot query = await _fireStore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId )
          .where('status', isEqualTo: 'pending')
          .get();

      if(query.docs.isNotEmpty) {
        return FriendRequestModel.fromMap(
          query.docs.first.data() as Map <String, dynamic>
        );
      }
      return null;
    }catch(e){
      throw Exception('Failed to get friend request: ${e.toString()}');
    }
  }

  Future<void> createFriendShip(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id,user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      FriendshipModel friendShip = FriendshipModel(
        id: friendShipId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now()
      );

      await _fireStore
      .collection('friendships')
      .doc(friendShipId)
      .set(friendShip.toMap());
    }catch(e){
      throw Exception('Failed to create friendship: ${e.toString()}');
    }
  }

  Future<void> removeFriendShip (String user1Id, String user2Id ) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .delete();

      await createNotification(
          NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: user2Id,
              title: 'Friend Removed',
              body: 'You are no longer friends',
              type: NotificationType.friendRequestDeclined,
              data: {'userId': user1Id},
              createdAt: DateTime.now()
          )
      );
    } catch (e) {
      throw Exception('Failed to remove friendships: ${e.toString()}');
    }
  }

  Future<void> blockUser (String blockerId, String blockedId) async {
    try {
      List<String> userIds = [blockerId, blockedId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .update({
        'isBlocked': true,
        'blockedBy' : blockerId
      });
    }catch (e) {
      throw Exception('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> unBlockUser (String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .update({
        'isBlocked': false,
        'blockedBy' : null
      });
    } catch (e) {
      throw Exception('Failed to unblock user: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getFriendsStream(String userId) {
    return _fireStore
        .collection("friendships")
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot1) async {
          QuerySnapshot snapshot2 = await _fireStore
              .collection("friendships")
              .where('user2Id', isEqualTo: userId)
              .get();

          List<FriendshipModel> friendships = [];

          for (var doc in snapshot1.docs){
            friendships.add(
              FriendshipModel.fromMap(doc.data() as Map<String, dynamic>),
            );
          }
          for (var doc in snapshot2.docs){
            friendships.add(
              FriendshipModel.fromMap(doc.data() as Map<String, dynamic>),
            );
          }
          return friendships.where((f) => !f.isBlocked).toList();
    });
  }

  Future<FriendshipModel?> getFriendships (String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .get();

      if (doc.exists){
        return FriendshipModel.fromMap(doc.data() as Map <String, dynamic>);
      }
      return null;
    } catch(e) {
      throw Exception('Failed to get friendship: ${e.toString()}');
    }
  }

  Future<bool> isUserBlocked (String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .get();
      if (doc.exists){
        FriendshipModel friendship = FriendshipModel.fromMap(
            doc.data() as Map <String, dynamic>
        );
        return friendship.isBlocked;
      }
      return false;
    } catch(e) {
      throw Exception('Failed to check if user is blocked: ${e.toString()}');
    }
  }

  Future<bool> isUnFriended (String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _fireStore
          .collection('friendships')
          .doc(friendShipId)
          .get();

      return !doc.exists || (doc.exists && doc.data() == null);
    } catch(e) {
      throw Exception('Failed to check if user is un friended: ${e.toString()}');
    }
  }

  Future<String> createOrGetChat(String userId1, String userId2) async{
    try {
      List<String> participants = [userId1, userId2];
      participants.sort();
      String chatId = '${participants[0]}_${participants[1]}';

      DocumentReference chatRef = _fireStore.collection('chats').doc(chatId);
      DocumentSnapshot chatDoc = await chatRef.get();

      if (!chatDoc.exists){
        ChatModel newChat =
        ChatModel(
            id: chatId,
            participants: participants,
            unreadCount: {userId1: 0, userId2: 0},
            deleteBy: {userId1: false, userId2: false},
            deleteAt: {userId1: null, userId2: null},
            lastSeenBy: {userId1: DateTime.now(), userId2: DateTime.now()},
            createAt: DateTime.now(),
            updateAt: DateTime.now()
        );

        await chatRef.set(newChat.toMap());
      } else {
        ChatModel existingChat = ChatModel.fromMap(
          chatDoc.data() as Map<String,dynamic>
        );
        if (existingChat.isDeleteBy(userId1)){
          await restoreChatForUser(chatId, userId1);
        }
        if (existingChat.isDeleteBy(userId2)){
          await restoreChatForUser(chatId, userId1);
        }
      }
      return chatId;
    } catch (e) {
      throw Exception('Failed to create or get chat: ${e.toString()}');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _fireStore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updateAt', descending: true)
        .snapshots()
        .map(
        (snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromMap(doc.data()))
            .where((chat) => !chat.isDeleteBy(userId))
            .toList()
    );
  }

  Future<void> updateChatLastMessage(String chatId, MessageModel message) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'lastMessage' : message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updateAt': DateTime.now().millisecondsSinceEpoch
      });
    }catch (e) {
      throw Exception('Failed to update chat last message: ${e.toString()}');
    }
  }

  Future<void> updateUserLastMessage(String chatId, String userId) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'lastSeenBy.$userId': DateTime.now().millisecondsSinceEpoch
      });
    }catch (e) {
      throw Exception('Failed to update last seen: ${e.toString()}');
    }
  }

  Future<void> updateUserLastSeen(String chatId, String userId) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'lastSeenBy.$userId': DateTime.now().millisecondsSinceEpoch
      });
    }catch (e) {
      throw Exception('Failed to update last seen: ${e.toString()}');
    }
  }

  Future<void> deleteChatForUser(String chatId, String userId) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
       'deleteBy.$userId': true,
        'deleteAt.$userId': DateTime.now().millisecondsSinceEpoch
      });
    }catch (e) {
      throw Exception('Failed to delete chat: ${e.toString()}');
    }
  }

  Future<void> restoreChatForUser(String chatId, String userId) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'deleteBy.$userId': false,
      });
    }catch (e) {
      throw Exception('Failed to restore chat: ${e.toString()}');
    }
  }

  Future<void> updateUnreadCount(
      String chatId,
      String userId,
      int count
  ) async {
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': count,
      });
    }catch (e) {
      throw Exception('Failed to update unread count: ${e.toString()}');
    }
  }

  Future<void> restoreUnreadCount(String chatId, String userId) async {
    print("Da doc tin nhan");
    try{
      await _fireStore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    }catch (e) {
      throw Exception('Failed to rest unread count: ${e.toString()}');
    }
  }

  //MESSAGE
  Future<void>  sendMessage(MessageModel message) async {
    try {
      await _fireStore
          .collection('message')
          .doc(message.id)
          .set(message.toMap());

      String chatId = await createOrGetChat(
        message.senderId,
        message.receiverId
      );

      await updateChatLastMessage(chatId, message);

      await updateUserLastMessage(chatId, message.senderId);

      DocumentSnapshot chatDoc = await _fireStore
          .collection('chats')
          .doc(chatId)
          .get();

      if (chatDoc.exists){
        ChatModel chat = ChatModel.fromMap(
          chatDoc.data() as Map<String, dynamic>
        );

        int currentUnread = chat.getUnreadCount(message.receiverId);

        await updateUnreadCount(chatId, message.receiverId, currentUnread +1);
      }
    } catch (e){
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Stream<List<MessageModel>> getMessagesStream (String userId1, String userId2) {
    return _fireStore.collection('message').where(
      'senderId' , whereIn: [userId1,userId2]
    ).snapshots()
        .asyncMap((snapshot) async {
          List<String> participants  = [userId1, userId2];
          participants.sort();
          String chatId = '${participants[0]}_${participants[1]}';

          DocumentSnapshot chatDoc = await _fireStore
              .collection('chats')
              .doc(chatId)
              .get();

          ChatModel? chat;
          if (chatDoc.exists){
            chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
          }

          List<MessageModel> messages = [];
          for (var doc in snapshot.docs) {
            MessageModel message = MessageModel.fromMap(doc.data());

            if ((message.senderId == userId1 && message.receiverId == userId2) ||
                (message.senderId == userId2 && message.receiverId == userId1)) {

              bool includeMessage = true;

              if (chat != null) {
                DateTime? currentUserDeleteAt = chat.getDeleteAt(userId1);
                if (currentUserDeleteAt != null &&
                  message.timestamp.isBefore(currentUserDeleteAt)) {
                  includeMessage = false;
                }
              }
              if (includeMessage) {
                messages.add(message);
              }
            }
          }

          messages.sort((a,b) => a.timestamp.compareTo(b.timestamp));
          return messages;
    });
  }

  Future<void> markMessageAsRead (String messageId) async {
    try {
      await _fireStore.collection('message').doc(messageId).update({
        'isRead': true
      });
    } catch (e) {
      throw Exception('Failed to mark message as read: ${e.toString()}');
    }
  }

  Future<void> deleteMessage (String messageId) async {
    try {
      await _fireStore.collection('message').doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message ${e.toString()}');
    }
  }

  Future<void> editMessage (String messageId, String newContent) async {
    try {
      await _fireStore.collection('message').doc(messageId).update({
        'content' : newContent,
        'isEdited' : true,
        'editedAt' : DateTime.now().millisecondsSinceEpoch
      });
    } catch (e) {
      throw Exception('Failed to edit message ${e.toString()}');
    }
  }

  Future<void> createNotification (NotificationModel notification) async {
    try {
      await _fireStore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _fireStore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
        (snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList()
    );
  }

  Future<void> markNotificationAsRead (String notificationId) async {
    try {
      await _fireStore.collection('notifications').doc(notificationId).update({
        'isRead' : true
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationAsRead (String userId) async {
    try {
      QuerySnapshot notifications = await _fireStore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead' , isEqualTo: false)
          .get();

          WriteBatch batch = _fireStore.batch();

          for (var doc in notifications.docs) {
            batch.update(doc.reference, {'isRead': true});
          }
          await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notification as read: ${e.toString()}');
    }
  }

  Future<void> deleteNotification (String notificationId) async {
    try {
      await _fireStore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification : ${e.toString()}');
    }
  }

  Future<void> deleteNotificationsByTypeAndUser (
    String userId,
    NotificationType type,
    String relatedUserId
  ) async {
    try {
      QuerySnapshot notifications = await _fireStore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead' , isEqualTo: type.name)
          .get();

      WriteBatch batch = _fireStore.batch();

      for (var doc in notifications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['data'] != null &&
            (data['data']['senderId'] == relatedUserId ||
                data['data']['userId'] == relatedUserId)) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  Future<void> _removeNotificationForCancelledRequest(String receiverId, String senderId) async {
    try {
      await deleteNotificationsByTypeAndUser(
        receiverId,
        NotificationType.friendRequest,
        senderId,
      );
    } catch (e){
      print("Error removing notification for cancelled request: $e");
    }
  }
}