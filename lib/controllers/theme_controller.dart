// Theme Controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/utils/hive_database.dart';

class ThemeController extends GetxController {
  final HiveDatabase _hiveDatabase = Get.find<HiveDatabase>();
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() async {
    final savedTheme = await _hiveDatabase.getString('isDarkMode');
    isDarkMode.value = savedTheme == 'true';
    _updateAppTheme();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveTheme();
    _updateAppTheme();
  }

  void _saveTheme() {
    _hiveDatabase.saveString('isDarkMode', isDarkMode.value.toString());
  }

  void _updateAppTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
