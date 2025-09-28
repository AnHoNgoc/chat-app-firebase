import 'package:chat_app_fb/controllers/chat_controller.dart';
import 'package:chat_app_fb/controllers/friend_requests_controller.dart';
import 'package:chat_app_fb/controllers/friends_controller.dart';
import 'package:chat_app_fb/controllers/main_controller.dart';
import 'package:chat_app_fb/controllers/notification_controller.dart';
import 'package:chat_app_fb/controllers/users_list_controller.dart';
import 'package:chat_app_fb/routes/app_routes.dart';
import 'package:chat_app_fb/views/auth/forgot_password_view.dart';
import 'package:chat_app_fb/views/auth/login_view.dart';
import 'package:chat_app_fb/views/auth/splash_view.dart';
import 'package:chat_app_fb/views/chat_view.dart';
import 'package:chat_app_fb/views/find_people_view.dart';
import 'package:chat_app_fb/views/friend_request_view.dart';
import 'package:chat_app_fb/views/friends_view.dart';
import 'package:chat_app_fb/views/home_view.dart';
import 'package:chat_app_fb/views/main/main_view.dart';
import 'package:chat_app_fb/views/notification_view.dart';
import 'package:chat_app_fb/views/profile/change_password_view.dart';
import 'package:chat_app_fb/views/profile/profile_view.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
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
    GetPage(
        name: AppRoutes.chat,
        page: () =>  ChatView(),
        binding: BindingsBuilder(() {
          Get.put(ChatController());
        })
    ),

    GetPage(
        name: AppRoutes.home,
        page: () =>  HomeView(),
        binding: BindingsBuilder(() {
          Get.put(HomeController());
        })
    ),
    GetPage(
        name: AppRoutes.userList,
        page: () =>  FindPeopleView(),
        binding: BindingsBuilder(() {
          Get.put(UsersListController());
        })
    ),
    GetPage(
        name: AppRoutes.friends,
        page: () =>  FriendsView(),
        binding: BindingsBuilder(() {
          Get.put(FriendsController());
        })
    ),
    GetPage(
        name: AppRoutes.friendRequests,
        page: () =>  FriendRequestView(),
        binding: BindingsBuilder(() {
          Get.put(FriendRequestsController());
        })
    ),
    GetPage(
        name: AppRoutes.notifications,
        page: () =>  NotificationView(),
        binding: BindingsBuilder(() {
          Get.put(NotificationController());
        })
    ),
  ];
}