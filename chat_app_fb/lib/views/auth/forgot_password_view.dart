import 'package:chat_app_fb/utils/app_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/forgot_password_controller.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: controller.goBackLogin,
                      icon: Icon(Icons.arrow_back, size: 24.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Forgot Password",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.only(left: 56.w),
                  child: Text(
                    "Enter your email to receive a password reset link",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                ),
                SizedBox(height: 60.h),
                Center(
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 50.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Obx(() {
                  if (controller.emailSent) {
                    return _buildEmailSentContent(controller);
                  } else {
                    return _buildEmailForm(controller);
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ForgotPasswordController controller) {
    return Column(
      children: [
        // Email input
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email Address",
            prefixIcon: Icon(Icons.email_outlined, size: 20.sp),
            hintText: "Enter your email address",
          ),
          validator: AppValidator.validateEmail,
        ),
        SizedBox(height: 32.h),

        // Button with loader & icon
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              alignment: Alignment.center,
            ),
            onPressed: controller.isLoading
                ? null
                : () async {
              await controller.sentPasswordResetEmail();
            },
            icon: controller.isLoading
                ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(Icons.send, size: 20.sp),
            label: Text(
              controller.isLoading ? "Sending..." : "Send Reset Link",
              style: TextStyle(fontSize: 14.sp, height: 1.2),
            ),
          ),
        )),

        SizedBox(height: 32.h),

        // Sign In link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Remember your password? ",
              style: Theme.of(Get.context!)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14.sp),
            ),
            GestureDetector(
              onTap: controller.goBackLogin,
              child: Text(
                "Sign In",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),

        Obx(() {

          if (controller.emailSent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                "Success",
                "Password reset email sent to ${controller.emailController.text}",
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green,
              );
              controller.resetEmailSent(); // reset flag
            });
          }

          // Error snackbar
          if (controller.error.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                "Error",
                controller.error,
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                colorText: Colors.redAccent,
              );
              controller.clearError();
            });
          }

          return SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildEmailSentContent(ForgotPasswordController controller) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                size: 60.sp,
                color: AppTheme.successColor,
              ),
              SizedBox(height: 16.h),
              Text(
                "Email Sent!",
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                    fontSize: 20.sp,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                "We've sent a password reset link to:",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                controller.emailController.text,
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              Text(
                "Check your email and follow the instructions to reset your password",
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.resentEmail,
            icon: Icon(Icons.refresh, size: 20.sp),
            label: Text("Resend Email", style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.goBackLogin,
            icon: Icon(Icons.arrow_back, size: 20.sp),
            label: Text("Back To Sign In", style: TextStyle(fontSize: 14.sp)),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.sp,
                color: AppTheme.secondaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Didn't receive the email? Check your spam folder or try again",
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.secondaryColor,
                      ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
