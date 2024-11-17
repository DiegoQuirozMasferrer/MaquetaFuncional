import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  Color primaryColor = Colors.brown;
  String fontFamily = 'Roboto';

  ThemeNotifier() {
    _loadPreferences();
  }

  ThemeData get currentTheme {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    _savePreferences();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    primaryColor = color;
    _savePreferences();
    notifyListeners();
  }

  void setFontFamily(String family) {
    fontFamily = family;
    _savePreferences();
    notifyListeners();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.brown.value);
    fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    notifyListeners();
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('primaryColor', primaryColor.value);
    await prefs.setString('fontFamily', fontFamily);
  }
}
