import 'package:chat_app_fb/controllers/friends_controller.dart';
import 'package:chat_app_fb/controllers/user_controller.dart';
import 'package:chat_app_fb/controllers/users_list_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class MainController extends GetxController {

  final RxInt _currentIndex = 0.obs;
  final PageController pageController = PageController();

  int get currentIndex => _currentIndex.value;

  @override
  void onInit() {
    super.onInit();

    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FriendsController());
    Get.lazyPut(() => UsersListController());
    Get.lazyPut(() => UserController());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changeTabIndex (int index) {
    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }

  void onPageChanged (int index){
    _currentIndex.value = index;
  }

  int getUnreadCount() {
    try{
     final homeController = Get.find<HomeController>();
     return homeController.getTotalUnreadCount();

    } catch (e) {
      return 0;
    }
  }

  int getNotificationCount() {
    try{
      final homeController = Get.find<HomeController>();
      return homeController.getUnreadNotificationsCount();
    } catch (e) {
      return 0;
    }
  }
}