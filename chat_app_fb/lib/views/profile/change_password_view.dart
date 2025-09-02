import 'package:chat_app_fb/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/change_password_controller.dart';
import '../../utils/app_validator.dart';


class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Center(
                child: Container(
                  width: 140.w,
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1), // màu nền
                    borderRadius: BorderRadius.circular(40.r)
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 80.sp,
                    color: AppTheme.primaryColor
                  ),
                ),
              ),

              SizedBox(height: 40.h),
              // Old Password
              Obx(() => TextFormField(
                controller: controller.oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(controller.isOldPasswordHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                      size: 18.sp,
                    ),
                    onPressed: controller.toggleOldPasswordVisibility,
                  ),
                ),
                obscureText: controller.isOldPasswordHidden,
                validator: AppValidator.validatePassword,
              )),
              SizedBox(height: 16.h),
              // New Password
              Obx(() => TextFormField(
                controller: controller.newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                  hintText: "Enter new password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isNewPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 18.sp,
                    ),
                    onPressed: controller.toggleNewPasswordVisibility,
                  ),
                ),
                obscureText: controller.isNewPasswordHidden,
                validator: (value) => AppValidator.validateNewPassword(
                  value,
                  controller.oldPasswordController.text,
                ),
              )),
              SizedBox(height: 16.h),
              // Confirm Password
              Obx(() => TextFormField(
                controller: controller.confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                  hintText: "Confirm new password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 18.sp,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
                obscureText: controller.isConfirmPasswordHidden,
                validator: (value) => AppValidator.validateConfirmPassword(
                  value,
                  controller.newPasswordController.text,
                ),
              )),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoading
                            ? null
                            : () async {
                          final result = await controller.changePassword();
                          print("Result: $result");
                          if (result == null) {
                            print("Chạy vào đây");
                            Get.snackbar(
                              "Success",
                              "Password changed successfully",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2), // 👈 giữ snackbar 2s
                            );
                          }else {
                            Get.snackbar(
                              "Error",
                              result,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: Icon(Icons.security_rounded, size: 20.sp , color: Colors.white,), // icon bảo mật
                        label: controller.isLoading
                            ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text("Change Password"),
                      )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}