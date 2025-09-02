import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {

  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;

  final RxBool _isOldPasswordHidden = true.obs;
  final RxBool _isNewPasswordHidden = true.obs;
  final RxBool _isConfirmPasswordHidden = true.obs;
  bool get isLoading => _isLoading.value;

  bool get isOldPasswordHidden => _isOldPasswordHidden.value;
  bool get isNewPasswordHidden => _isNewPasswordHidden.value;
  bool get isConfirmPasswordHidden => _isConfirmPasswordHidden.value;

  void toggleOldPasswordVisibility() {
    _isOldPasswordHidden.value = !_isOldPasswordHidden.value;
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordHidden.value = !_isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordHidden.value = !_isConfirmPasswordHidden.value;
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<String?> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return "Please fix the errors above";
    }

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      return "New password and confirmation do not match";
    }

    try {
      _isLoading.value = true;

      await _authService.changePassword(
        oldPassword,
        newPassword,
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back();
      return null;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      switch (e.code) {
        case 'wrong-password': // SDK cũ có thể trả về
        case 'invalid-credential': // SDK mới thường trả về
          return "Old password is incorrect.";
        case 'weak-password':
          return "New password is too weak.";
        case 'requires-recent-login':
          return "Please re-login and try again.";
        default:
          return "Failed to change password. Please try again.";
      }
    } catch (e, s) {
      print("Other exception: $e");
      print(s);
      return "Failed to change password. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }

}