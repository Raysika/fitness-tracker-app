import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/color_extension.dart'; // Import the color extension

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: TColor.primaryColor1, // Use TColor for primary color
    colorScheme: ColorScheme.light(
      primary: TColor.primaryColor1,
      secondary: TColor.secondaryColor1,
      background: TColor.white,
      surface: TColor.lightGray,
      onPrimary: TColor.white,
      onSecondary: TColor.black,
      onBackground: TColor.black,
      onSurface: TColor.black,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: TColor.black, // Use TColor for text colors
      displayColor: TColor.black,
    ),
    scaffoldBackgroundColor: TColor.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TColor.primaryColor1, // Use TColor for button colors
        foregroundColor: TColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
  );
}
