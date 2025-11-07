import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../service/notification_service.dart';


class FirebaseApi {

  FirebaseApi._internal(); // private constructor
  static final FirebaseApi instance = FirebaseApi._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
      provisional: false,
    );

    _fcmToken = await _firebaseMessaging.getToken();
    print('🔑 FCM Token: $_fcmToken');

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      print('🔄 FCM Token refreshed: $_fcmToken');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await NotificationService().saveFcmToken(newToken);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      final chatRoomId = data['chatRoomId'];

      // Đang ở màn chat và đúng phòng chat → không hiện notification
      if (Get.currentRoute == AppRoutes.chat && Get.arguments?['chatId'] == chatRoomId) {
        return;
      }

      NotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 onMessageOpenedApp TRIGGERED');
      final data = message.data;
      final chatRoomId = data['chatRoomId'];
      final otherUserString = data['otherUser'];
      if (chatRoomId != null && otherUserString != null) {
        final otherUserMap = jsonDecode(otherUserString);
        final otherUser = UserModel.fromMap(otherUserMap);
        NotificationService.handleNotificationClick(chatRoomId, otherUser);
      }
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      print('🔍 Checking getInitialMessage...');

      if (message != null) {
        final data = message.data;
        final chatRoomId = data['chatRoomId'];
        final otherUserString = data['otherUser'];
        if (chatRoomId != null && otherUserString != null) {
          final otherUserMap = jsonDecode(otherUserString);
          final otherUser = UserModel.fromMap(otherUserMap);
          NotificationService.handleNotificationClick(chatRoomId, otherUser);
        }
      }
    });

  }

  String? get fcmToken => _fcmToken;
}