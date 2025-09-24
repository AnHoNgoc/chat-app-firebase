import 'dart:io';
import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/models/user_model.dart';
import 'package:chat_app_fb/service/user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;


class UserController extends GetxController {

  final UserService _userService = UserService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // State
  final RxString _newPhotoURL = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxBool _isUploading = false.obs;
  final RxString _error = ''.obs;
  final RxString _statusMessage = ''.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  // Getters
  String? get newPhotoURL => _newPhotoURL.value.isEmpty ? null : _newPhotoURL.value;
  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  bool get isUploading => _isUploading.value;
  String get error => _error.value;
  String get statusMessage => _statusMessage.value;
  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void updateCurrentUserStream(String uid) {
    _currentUser.bindStream(_userService.streamUser(uid));
  }

  void _loadUserData() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _currentUser.bindStream(_userService.streamUser(currentUserId));
      ever(_currentUser, (UserModel? user) {
        if (user != null) {
          displayNameController.text = user.displayName;
          emailController.text = user.email;
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;
    if (!_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
      _newPhotoURL.value = '';
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _statusMessage.value = '';

      final user = _currentUser.value;
      if (user == null) return;

      final data = {
        'displayName': displayNameController.text,
        if (newPhotoURL != null) 'photoURL': newPhotoURL!,
      };

      await _userService.updateUser(user.id, data);

      _newPhotoURL.value = '';
      _isEditing.value = false;
      _statusMessage.value = "Profile updated successfully";

    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authController.logout();
    } catch (e) {
      _error.value = "Failed to sign out: $e";
    }
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) return '';
    final date = user.createdAt;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  void clearError() => _error.value = '';
  void clearStatusMessage() => _statusMessage.value = '';

  Future<void> pickAndUploadAvatar() async {
    try {
      final user = _currentUser.value;
      if (user == null) return;

      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        _newPhotoURL.value = '';
        return;
      }

      final file = File(pickedFile.path);
      _isUploading.value = true;

      final fileName =
          "${user.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}";
      final storageRef = FirebaseStorage.instance.ref().child("avatars/$fileName");

      final uploadTask = await storageRef.putFile(file);
      final downloadURL = await uploadTask.ref.getDownloadURL();
      _newPhotoURL.value = downloadURL;

    } catch (e) {
      _error.value = "Failed to upload avatar: $e";
    } finally {
      _isUploading.value = false;
    }
  }
}