import 'package:flutter/material.dart';

class AppFonts {
  static const String poppinsFont = "Poppins";
  static const String poppinsLight = "Poppins-Light";
  static const String poppinsMedium = "Poppins-Medium";
  static const String poppinsRegular = "Poppins-Regular.ttf";
  static const String poppinsSemiBold = "Poppins-SemiBold";
  static const String poppinsThin = "Poppins-Thin.ttf";

  // Light Theme Text Styles
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: TextStyle(fontFamily: poppinsSemiBold, fontSize: 32),
    headlineMedium: TextStyle(fontFamily: poppinsSemiBold, fontSize: 24),
    titleLarge: TextStyle(fontFamily: poppinsMedium, fontSize: 20),
    bodyLarge: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
    bodyMedium: TextStyle(fontFamily: poppinsRegular, fontSize: 14),
    labelSmall: TextStyle(fontFamily: poppinsRegular, fontSize: 12),
  );

  // Dark Theme Text Styles (Optional)
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: TextStyle(fontFamily: poppinsSemiBold, fontSize: 32, color: Colors.white),
    headlineMedium: TextStyle(fontFamily: poppinsSemiBold, fontSize: 24, color: Colors.white),
    titleLarge: TextStyle(fontFamily: poppinsMedium, fontSize: 20, color: Colors.white),
    bodyLarge: TextStyle(fontFamily: poppinsRegular, fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontFamily: poppinsRegular, fontSize: 14, color: Colors.white),
    labelSmall: TextStyle(fontFamily: poppinsRegular, fontSize: 12, color: Colors.white),
  );
}
