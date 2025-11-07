const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = onCall({ region: "us-central1" }, async (req) => {
    const { receiverId, title, messageText, chatRoomId, senderId } = req.data;

    if (!receiverId || !title || !messageText || !chatRoomId || !senderId) {
        throw new HttpsError("invalid-argument", "Missing required parameters");
    }

    // 1. Lấy token FCM mới nhất của người nhận
    const tokenQuery = await admin.firestore()
        .collection("tokens")
        .where("userId", "==", receiverId)
        .orderBy("updatedAt", "desc")
        .limit(1)
        .get();

    if (tokenQuery.empty) {
        throw new HttpsError("not-found", "Receiver FCM token not found");
    }

    const fcmToken = tokenQuery.docs[0].id;

    // 2. Lấy thông tin của người gửi (để build otherUser)
    const senderDoc = await admin.firestore()
        .collection("users")
        .doc(senderId)
        .get();

    if (!senderDoc.exists) {
        throw new HttpsError("not-found", "Sender user not found");
    }

    const otherUser = senderDoc.data(); // ✅ chính là user hiển thị khi mở chat

    // 3. Tạo nội dung thông báo
    const message = {
        token: fcmToken,
        notification: {
            title,
            body: messageText,
        },
        android: {
            priority: "high",
            notification: {
                channelId: "high_importance_channel",
                sound: "default",
            },
        },
        apns: {
            payload: {
                aps: {
                    sound: "default",
                    contentAvailable: true,
                },
            },
        },
        data: {
            chatRoomId,
            otherUser: JSON.stringify(otherUser), // ✅ gửi sang app
        },
    };

    try {
        await admin.messaging().send(message);
        return { success: true };
    } catch (err) {
        console.error("Error sending FCM message:", err);
        throw new HttpsError("internal", "Failed to send notification");
    }
});