import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class NotificationService {

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseFunctions functions =
  FirebaseFunctions.instanceFor(region: 'us-central1');

  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';
  static const _channelDescription = 'Used for important notifications.';

  /// 🚀 Khởi tạo local notification + tạo channel (Android)
  static Future<void> initialize() async {

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!);
            final chatRoomId = data['chatRoomId'];
            final otherUserMap = data['otherUser'];
            if (chatRoomId != null && otherUserMap != null) {
              final otherUser = UserModel.fromMap(otherUserMap);
              handleNotificationClick(chatRoomId, otherUser);
            }
          } catch (e) {
            print('❌ Parse payload error: $e');
          }
        }
      },
    );

    // 🔔 Tạo notification channel cho Android 8.0+
    final android = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    ));
  }

  static void handleNotificationClick(String chatRoomId, UserModel otherUser) {
    navigatorKey.currentState?.pushNamed(
      AppRoutes.chat,
      arguments: {
        'chatId': chatRoomId,
        'otherUser': otherUser,
      },
    );
  }

  /// 🔔 Hiển thị local notification khi app đang foreground
  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }


  Future<void> saveFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _fireStore.collection('tokens').doc(token).set({
        'userId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Saved FCM token for user ${user.uid}");
    } catch (e) {
      print('❗ Failed to save FCM token: $e');
    }
  }


  Future<void> sendPushToUser({
    required String receiverId,        
    required String senderId,
    required String chatRoomId,
    required String title,
    required String messageText,
    String? messageType,
    Map<String, String>? extraData,
  }) async {
    try {
      final payload = {
        'receiverId': receiverId,
        'chatRoomId': chatRoomId,
        'title': title,
        'messageText': messageText,
        'messageType': messageType ?? 'text',
        'extraData': extraData ?? {},
        'senderId ': senderId
      };
      print('📨 Sending chat push with payload: $payload');

      // Gọi Firebase Cloud Function
      final callable = functions.httpsCallable('sendChatNotification');
      final result = await callable.call(payload);

      print('✅ Chat push sent successfully: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print('🔥 Firebase Function error: ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Failed to send chat push: $e');
      rethrow;
    }
  }
}