
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

// CREATE USER
  Future<UserModel?> createUser(Map<String, dynamic> data) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: data["email"],
        password: data["password"],
      );
      final uid = userCredential.user!.uid;

      final user = UserModel(
        id: uid,
        email: data["email"],
        displayName: data["displayName"] ?? "",
        photoURL: "",
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _fireStore.collection('users').doc(uid).set({
        ...user.toMap(),
        'lastSeen': user.lastSeen.millisecondsSinceEpoch,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception("unknown-error");
    }
  }

  Future<UserModel> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      await _fireStore.collection('users').doc(uid).update({
        'isOnline': true,
      });

      final snapshot = await _fireStore.collection('users').doc(uid).get();
      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception("unknown-error");
    }
  }

// CHANGE PASSWORD
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      throw FirebaseAuthException(
        code: "user-not-found",
        message: "User not found.",
      );
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw e; // throw trực tiếp để bên trên xử lý
    } catch (e) {
      throw Exception("unknown-error");
    }
  }

// SEND PASSWORD RESET EMAIL
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e; // throw trực tiếp
    } catch (_) {
      throw Exception("unknown-error");
    }
  }

// LOGOUT
  Future<void> logoutUser() async {
    try {
      final uid = currentUserId;
      if (uid != null) {
        await _fireStore.collection('users').doc(uid).update({
          'isOnline': false,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception("logout-failed");
    }
  }
}