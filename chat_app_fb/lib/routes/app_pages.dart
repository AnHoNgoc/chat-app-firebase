import 'package:chat_app_fb/controllers/main_controller.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:chat_app_fb/views/auth/forgot_password_view.dart';
import 'package:chat_app_fb/views/auth/login_view.dart';
import 'package:chat_app_fb/views/auth/splash_view.dart';
import 'package:chat_app_fb/views/main/main_view.dart';
import 'package:chat_app_fb/views/profile/change_password_view.dart';
import 'package:chat_app_fb/views/profile/profile_view.dart';
import 'package:get/get.dart';

import '../views/auth/register_view.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordView()),
    GetPage(
        name: AppRoutes.main,
        page: () =>  MainView(),
        binding: BindingsBuilder(() {
          Get.put(MainController());
        })
    ),
  ];
}