// home_page.dart
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/home_controller.dart';

import 'package:sahiyar_club/controllers/theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final ThemeController themeController = Get.find<ThemeController>();

    final List<TabItem> items = [
      const TabItem(icon: Icons.pie_chart, title: 'Dashboard'),
      const TabItem(icon: Icons.badge, title: 'Create Pass'),
      const TabItem(icon: Icons.list, title: 'My Passes'),
      const TabItem(icon: Icons.account_box, title: 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            homeController.titles[homeController.currentIndex.value],
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Obx(() => homeController.getCurrentPage()),
      bottomNavigationBar: Obx(() {
        final isDark = themeController.isDarkMode.value;

        return BottomBarInspiredFancy(
          pad: 7,
          bottom: 30,
          items: items,
          backgroundColor: Theme.of(context).colorScheme.surface,
          color:
              isDark
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  : Colors.grey[600]!,
          colorSelected: Colors.amber[600]!,
          indexSelected: homeController.currentIndex.value,
          onTap: (index) => homeController.changeTab(index),
          animated: true,

          paddingVertical: 8, // Reduced vertical padding
          styleIconFooter: StyleIconFooter.divider,
          titleStyle: TextStyle(
            fontSize: 11, // Smaller font size
            fontWeight: FontWeight.w600,
            color:
                isDark
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                    : Colors.grey[600]!,
          ),
          iconSize: 22, // Slightly smaller icons
        );
      }),
    );
  }
}
