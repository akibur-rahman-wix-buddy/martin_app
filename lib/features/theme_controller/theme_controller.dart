import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/db_helper.dart';

class ThemeController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // RxBool to track theme mode (false = Light, true = Dark)
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // Load the saved theme mode from SQLite
  Future<void> _loadTheme() async {
    int mode = await _dbHelper.getThemeMode();
    isDarkMode.value = mode == 1;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Toggle theme mode and update SQLite
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    await _dbHelper.setThemeMode(isDarkMode.value ? 1 : 0);
  }
}
