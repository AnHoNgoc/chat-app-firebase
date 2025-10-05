import 'package:chat_app_fb/models/message_model.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../service/fire_store_service.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final Uuid _uuid = Uuid();

  ScrollController? _scrollController;
  ScrollController get scrollController{
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  final RxList<MessageModel> _messages = <MessageModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _otherUSer = Rx<UserModel?>(null);
  final RxString _chatId = ''.obs;
  final RxBool _isTyping = false.obs;
  final RxBool _isChatActive = false.obs;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String get error => _error.value;
  UserModel? get otherUser => _otherUSer.value;
  String get chatId => _chatId.value;
  bool get isTyping => _isTyping.value;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    messageController.addListener(_onMessageChanged);
  }

  @override
  void onReady() {
    super.onReady();
    _isChatActive.value = true;
  }

  @override
  void onClose() {
    _isChatActive.value = false;
    super.onClose();
  }

  void _initializeChat() {
    final arguments = Get.arguments;
    if(arguments != null){
      _chatId.value = arguments['chatId'] ?? '';
      _otherUSer.value = arguments['otherUser'];
      _loadMessages();
      print("Đã gọi trong controller");
    }
  }

  void _loadMessages() {
    final currentUserId = _authController.user?.uid;
    final otherUserId = _otherUSer.value?.id;

    if (currentUserId != null && otherUserId != null) {
      _isLoading.value = true;

      _messages.bindStream(
          _fireStoreService.getMessagesStream(currentUserId, otherUserId)
      );

      ever(_messages, (List<MessageModel> messageList) {
        _isLoading.value = false;
        if (_isChatActive.value) {
          _markUnreadMessagesAsRead(messageList);
        }
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(_scrollController != null && _scrollController!.hasClients){
        _scrollController!.animateTo(
            _scrollController!.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut
        );
      }
    });
  }

  Future<void> _markUnreadMessagesAsRead(List<MessageModel> messageList) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    try {
      // 1. Lọc các message chưa đọc
      final unreadMessages = messageList.where((message) =>
      message.receiverId == currentUserId &&
          message.senderId != currentUserId &&
          !message.isRead
      ).toList();

      if (unreadMessages.isEmpty) return;

      // 2. Đánh dấu tin nhắn đã đọc
      for (var message in unreadMessages) {
        await _fireStoreService.markMessageAsRead(message.id);
      }

      // 3. Đánh dấu thông báo liên quan đã đọc
      // for (var message in unreadMessages) {
      //   print("Tin nhắn đã đọc");
      //   await _fireStoreService.markNotificationAsRead(message.id);
      // }

      // 4. Reset unreadCount trong ChatModel
      if (_chatId.value.isNotEmpty) {
        print('Calling restoreUnreadCount with chatId: ${_chatId.value}, userId: $currentUserId');
        await _fireStoreService.restoreUnreadCount(_chatId.value, currentUserId);
      }

      // 5. Update lastSeen
      if (_chatId.value.isNotEmpty) {
        await _fireStoreService.updateUserLastSeen(_chatId.value, currentUserId);
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }


  Future <void> deleteChat() async {
    try {
      final currentUserId = _authController.user?.uid;
      if(currentUserId == null || _chatId.value.isEmpty) return;

      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Chat'),
          content: Text('Are you sure you want to delete this chat? This action cannot be undone'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel')
            ),
            TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: Text('Delete')
            ),
          ],
        ),
      );

      if(result == true){
        _isLoading.value = true;
        await _fireStoreService.deleteChatForUser(_chatId.value, currentUserId);

        Get.delete<ChatController>(tag: _chatId.value);
        Get.back();
        Get.snackbar('Success', 'Chat Deleted');
      }
    } catch (e){
      _error.value = e.toString();
      print(e);
      Get.snackbar('Error', 'Failed to delete chat');
    } finally {
      _isLoading.value = false;
    }
  }

  void _onMessageChanged() {
    _isTyping.value = messageController.text.isNotEmpty;
  }

  Future<void> sendMessage() async {
    final currentUSerId = _authController.user?.uid;
    final otherUserId = _otherUSer.value?.id;
    final content = messageController.text.trim();
    messageController.clear();

    if(currentUSerId == null || otherUserId == null || content.isEmpty){
      Get.snackbar('Error', 'You cannot send messages to this user');
      return;
    }
    if(await _fireStoreService.isUnFriended(currentUSerId, otherUserId)){
      Get.snackbar('Error', 'You cannot send messages to this user as you are not friends');
      return;
    }

    try {
      _isSending.value = true;

      final message = MessageModel(
        id: _uuid.v4(),
        senderId: currentUSerId,
        receiverId: otherUserId,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now()
      );

      await _fireStoreService.sendMessage(message);
      _isTyping.value = false;
      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'You cannot send message');
      print(e);
    } finally {
      _isSending.value = false;
    }
  }



  void onChatResumed(){
    _isChatActive.value = true;
    _markUnreadMessagesAsRead(_messages);
  }

  void onChatPaused(){
    _isChatActive.value = false;
  }

  Future<void> deleteMessage(MessageModel message) async {
    try {
      await _fireStoreService.deleteMessage(message.id);
      Get.snackbar('Success', 'Message Delete');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message');
      print(e);
    }
  }

  Future<void> editMessage(MessageModel message, String newContent) async {
    try {
      await _fireStoreService.editMessage(message.id, newContent);
      Get.snackbar('Success', 'Message Edited');
    } catch (e) {
      Get.snackbar('Error', 'Failed to edit message');
      print(e);
    }
  }

  bool isMyMessage(MessageModel message){
    return message.senderId == _authController.user?.uid;
  }

  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes <1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} ';
    } else if (difference.inDays < 7) {
      final days =['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void clearError() {
    _error.value = '';
  }
}