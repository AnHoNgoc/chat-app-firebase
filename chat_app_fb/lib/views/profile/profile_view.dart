import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_fb/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileView extends GetView<UserController> {

  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    print(">>> ProfileView build() chạy với controller:");
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(fontSize: 18.sp, color: AppTheme.textPrimaryColor)),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, size: 20.sp, color: AppTheme.textPrimaryColor),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.toggleEditing,
            child: Text(
              controller.isEditing ? 'Cancel' : 'Edit',
              style: TextStyle(
                fontSize: 14.sp,
                color: controller.isEditing ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
            ),
          ))
        ],
      ),
      body: Obx(() {
        // Snackbar notifications
        if (controller.error.isNotEmpty) {
          Future.microtask(() {
            Get.snackbar("Error", controller.error,
                backgroundColor: AppTheme.errorColor,
                colorText: Colors.white);
            controller.clearError();
          });
        }
        if (controller.statusMessage.isNotEmpty) {
          Future.microtask(() {
            Get.snackbar("Success", controller.statusMessage,
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white);
            controller.clearStatusMessage();
          });
        }

        final user = controller.currentUser;
        if (user == null) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() {
                    final newPhotoURL = controller.newPhotoURL;
                    final hasNewPhoto = newPhotoURL != null && newPhotoURL.isNotEmpty;
                    return CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppTheme.primaryColor,
                      child: hasNewPhoto
                          ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: newPhotoURL,
                          width: 120.w,
                          height: 120.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.w,
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildDefaultAvatar(user),
                        ),
                      )
                          : user.photoURL.isNotEmpty
                          ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.photoURL,
                          width: 120.w,
                          height: 120.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.w,
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildDefaultAvatar(user),
                        ),
                      )
                          : _buildDefaultAvatar(user),
                    );
                  }),
                  if (controller.isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Obx(() {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.white, width: 2.w),
                              ),
                              child: IconButton(
                                onPressed: controller.isUploading ? null : controller.pickAndUploadAvatar,
                                icon: Icon(Icons.camera_alt, size: 20.sp, color: Colors.white),
                              ),
                            ),
                            if (controller.isUploading)
                              SizedBox(
                                width: 30.w,
                                height: 30.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  )),
              SizedBox(height: 4.h),
              Text(user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondaryColor,
                  )),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: user.isOnline
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8.w,
                      width: 8.w,
                      decoration: BoxDecoration(
                        color: user.isOnline
                            ? AppTheme.successColor
                            : AppTheme.textSecondaryColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      user.isOnline ? "Online" : "Offline",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: user.isOnline
                            ? AppTheme.successColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(controller.getJoinedData(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondaryColor,
                  )),
              SizedBox(height: 32.h),

              // Personal Info Card
              Obx(() => Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Text("Personal Information",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          )),
                      SizedBox(height: 20.h),
                      TextFormField(
                        controller: controller.displayNameController,
                        enabled: controller.isEditing,
                        decoration: InputDecoration(
                          labelText: "Display Name",
                          prefixIcon: Icon(Icons.person_outline, size: 20.sp, color: AppTheme.primaryColor),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: controller.emailController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined, size: 20.sp, color: AppTheme.primaryColor),
                          helperText: "Email can't be changed",
                        ),
                      ),
                      if (controller.isEditing) ...[
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ? null : controller.updateProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            child: controller.isLoading
                                ? SizedBox(
                              height: 20.w,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: Colors.white,
                              ),
                            )
                                : Text("Save Changes",
                                style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              )),

              SizedBox(height: 32.h),

              // Sign Out & Change Password
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.security, color: AppTheme.primaryColor, size: 22.sp),
                      title: Text("Change Password", style: TextStyle(fontSize: 14.sp)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                      onTap: () => Get.toNamed('/change-password'),
                    ),
                    Divider(height: 1.h, color: AppTheme.borderColor),
                    ListTile(
                      leading: Icon(Icons.logout, color: AppTheme.errorColor, size: 22.sp),
                      title: Text("Sign Out", style: TextStyle(fontSize: 14.sp)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Confirm Logout"),
                            content: const Text("Are you sure you want to sign out?"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel"),
                              ),
                              Obx(() => TextButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () async {
                                  await controller.signOut();
                                  if (!controller.isLoading) {
                                    Get.back();
                                    Get.offAllNamed(AppRoutes.login);
                                  }
                                },
                                child: controller.isLoading
                                    ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const Text(
                                  "Sign Out",
                                  style: TextStyle(color: AppTheme.errorColor),
                                ),
                              )),
                            ],
                          ),
                          barrierDismissible: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultAvatar(dynamic user) {
    return Text(
      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : "?",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32.sp),
    );
  }
}
