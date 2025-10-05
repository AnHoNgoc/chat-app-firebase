 import 'package:chat_app_fb/controllers/auth_controller.dart';
import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:chat_app_fb/utils/app_validator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      final errorMessage = await _authController.loginUser(data);

      if (errorMessage != null) {
        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w), // responsive padding
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Center(
                  child: SizedBox(
                    width: 300.w,
                    height: 200.w,
                    child: Lottie.asset(
                      'assets/animation/login.json', // đường dẫn file Lottie trong project
                      fit: BoxFit.cover,
                      repeat: true, // lặp lại animation
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  "Welcome Back!",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Sign in to continue chatting with friend & family",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.email_outlined, size: 20.sp),
                    hintText: "Enter your email",
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidator.validateEmail,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                    hintText: "Enter your password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: AppValidator.validatePassword,
                ),
                SizedBox(height: 24.h),
                Obx(() {
                  return _authController.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h), // padding theo ScreenUtil
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 16.h),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.forgotPassword);
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.borderColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "OR",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.borderColor)),
                  ],
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        "Sign Up",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

