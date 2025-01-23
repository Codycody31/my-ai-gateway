import 'package:flutter/material.dart';
import 'package:my_ai_gateway/services/database.dart';
import 'package:my_ai_gateway/theme.dart';

class ThemeNotifier extends ChangeNotifier {
  late ThemeData lightTheme;
  late ThemeData darkTheme;

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    // Initialize themes
    final materialTheme = MaterialTheme(const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ));

    lightTheme = materialTheme.light();
    darkTheme = materialTheme.dark();

    // Load the user's theme preference
    _loadTheme();
  }

  void _loadTheme() async {
    _isDarkMode = await DatabaseService.instance.getConfig("is_dark_mode") == "1";
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await DatabaseService.instance.setConfig("is_dark_mode", _isDarkMode.toString());
    notifyListeners();
  }
}