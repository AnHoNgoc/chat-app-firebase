import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _fireStore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> streamUser(String uid) {
    try {
      return _fireStore
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) => doc.exists && doc.data() != null
          ? UserModel.fromMap(doc.data()!)
          : null);
    } catch (e) {
      return Stream.error("stream-user-failed");
    }
  }

  /// Cập nhật thông tin user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _fireStore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception("update-user-failed");
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

}