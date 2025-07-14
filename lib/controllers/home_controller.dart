import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/pages/pass_list_page.dart';
import 'package:sahiyar_club/screens/home/create_pass_screen.dart';
import 'package:sahiyar_club/screens/home/dashboard_screen.dart';
import 'package:sahiyar_club/screens/home/profile_screen.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  final List<Widget> pages = [
    DashboardScreen(),
    CreatePassScreen(),
    PassListPage(),
    ProfileScreen(),
  ];

  final List<String> titles = [
    'Dashboard',
    'Create Pass',
    'My Passes',
    'Profile',
  ];

  // Add method to get current page widget
  Widget getCurrentPage() {
    return pages[currentIndex.value];
  }
}
