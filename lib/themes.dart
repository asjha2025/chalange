import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F8A5A); // Dark Blue from logo
  static const Color accentColor = Color(0xFF4CAF50); // Green from leaves
  static const Color secondaryColor = Color(0xFF1565C0); // Light Blue
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color textColor = Color(0xFF000000); // Black

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
      bodyLarge: TextStyle(fontSize: 16, color: textColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
