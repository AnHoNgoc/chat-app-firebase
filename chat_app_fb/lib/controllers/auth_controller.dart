import 'package:chat_app_fb/controllers/user_controller.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../service/auth_service.dart';
import '../service/user_service.dart';

class AuthController extends GetxController {
  
  final AuthService _authService = AuthService();
  final UserService _userService  = UserService();
  Rx<User?> get userRx => _user;
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = "".obs;
  final RxBool _isInitialized = false.obs;
  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) async {
    if (user == null) {
      _userModel.value = null; // reset khi logout
      // không điều hướng ở đây
    } else {
      // Bind stream UserModel từ Firestore
      _userModel.bindStream(_userService.streamUser(user.uid));

      // Cập nhật UserController nếu tồn tại
      if (Get.isRegistered<UserController>()) {
        final uc = Get.find<UserController>();
        uc.updateCurrentUserStream(user.uid);
      }
      // không điều hướng ở đây
    }

    if (!_isInitialized.value) {
      _isInitialized.value = true;
    }
  }


  void checkInitialAuthState(){
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null){
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
    _isInitialized.value = true;
  }

  Future<String?> registerUser(Map<String, dynamic> data) async {
    _isLoading.value = true;
    try {
      final userModel = await _authService.createUser(data);

      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.login);
        return null; // success
      } else {
        return "Failed to create user. Please try again.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "This email is already registered.";
        case 'weak-password':
          return "Password is too weak.";
        case 'invalid-email':
          return "Invalid email format.";
        default:
          return "Registration failed. Please try again.";
      }
    } catch (e) {
      return "Registration failed. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> loginUser(Map<String, dynamic> data) async {
    _isLoading.value = true;
    try {
      final userModel = await _authService.loginUser(
        data["email"],
        data["password"],
      );

      _userModel.value = userModel;
      Get.offAllNamed(AppRoutes.main);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return "Incorrect email or password.";
        case 'invalid-email':
          return "Invalid email format.";
        default:
          return "Login failed. Please try again.";
      }
    } catch (e) {
      return "Login failed. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }

  // CHANGE PASSWORD
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading.value = true;
    try {
      await _authService.changePassword(oldPassword, newPassword);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          return "Old password is incorrect.";
        case 'weak-password':
          return "New password is too weak.";
        default:
          return "Password change failed. Please try again.";
      }
    } catch (e) {
      return "Password change failed. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }

// RESET PASSWORD
  Future<String?> resetPassword(String email) async {
    _isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "This email is not registered.";
        case 'invalid-email':
          return "Invalid email format.";
        default:
          return "Failed to send reset email. Please try again.";
      }
    } catch (e) {
      return "Failed to send reset email. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }

// LOGOUT
  Future<String?> logout() async {
    _isLoading.value = true;
    try {
      await _authService.logoutUser();
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
      return null; // success
    } catch (e) {
      return "Logout failed. Please try again.";
    } finally {
      _isLoading.value = false;
    }
  }
}