import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  Color primaryColor = Colors.brown;
  double fontSize = 16.0;
  String fontFamily = 'Roboto';


  ThemeData get currentTheme {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Cambiar modo oscuro/claro
  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }
  void setPrimaryColor(Color color) {
    primaryColor = color;
    notifyListeners();
  }


  void setFontSize(double size) {
    fontSize = size;
    notifyListeners();
  }


  void setFontFamily(String family) {
    fontFamily = family;
    notifyListeners();
  }
}
