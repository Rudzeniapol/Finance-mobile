import 'package:flutter/material.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    fontFamily: "PoppinsRegular",
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      surface: Color(0xff262626),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: "PoppinsBold", color: Colors.white),
      displayMedium: TextStyle(fontFamily: "PoppinsBold", color: Colors.white),
      displaySmall: TextStyle(fontFamily: "PoppinsBold", color: Colors.white),
      headlineLarge:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
      headlineMedium:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
      headlineSmall:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
      bodyLarge: TextStyle(fontFamily: "PoppinsLight", color: Colors.white),
      bodyMedium: TextStyle(fontFamily: "PoppinsLight", color: Colors.white),
      bodySmall: TextStyle(fontFamily: "PoppinsLight", color: Colors.white),
      titleLarge: TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
      titleMedium: TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
      titleSmall: TextStyle(fontFamily: "PoppinsMedium", color: Colors.white),
    ),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    fontFamily: "PoppinsRegular",
    scaffoldBackgroundColor: const Color(0xffF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xffF5F5F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontFamily: "PoppinsBold", color: Colors.black87),
      displayMedium:
          TextStyle(fontFamily: "PoppinsBold", color: Colors.black87),
      displaySmall:
          TextStyle(fontFamily: "PoppinsBold", color: Colors.black87),
      headlineLarge:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
      headlineMedium:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
      headlineSmall:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
      bodyLarge:
          TextStyle(fontFamily: "PoppinsLight", color: Colors.black87),
      bodyMedium:
          TextStyle(fontFamily: "PoppinsLight", color: Colors.black87),
      bodySmall:
          TextStyle(fontFamily: "PoppinsLight", color: Colors.black87),
      titleLarge:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
      titleMedium:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
      titleSmall:
          TextStyle(fontFamily: "PoppinsMedium", color: Colors.black87),
    ),
  );
}
