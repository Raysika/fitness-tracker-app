// lib/common/color_extension.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class TColor {
  static Color get primaryColor1 => const Color(0xff92A3FD);
  static Color get primaryColor2 => const Color(0xff9DCEFF);

  static Color get secondaryColor1 => const Color(0xffC58BF2);
  static Color get secondaryColor2 => const Color(0xffEEA4CE);

  static List<Color> get primaryG => [primaryColor2, primaryColor1];
  static List<Color> get secondaryG => [secondaryColor2, secondaryColor1];

  // Static getters used when theme context is not available
  static Color get black => const Color(0xff1D1617);
  static Color get gray => const Color(0xff786F72);
  static Color get white => Colors.white;
  static Color get lightGray => const Color(0xffF7F8F8);

  // Context-aware color getters that respond to theme
  static Color blackColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? Colors.white : const Color(0xff1D1617);
  }

  static Color grayColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? const Color(0xffA5A5A5)
        : const Color(0xff786F72);
  }

  static Color whiteColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? const Color(0xff1E1E1E) : Colors.white;
  }

  static Color lightGrayColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode
        ? const Color(0xff2A2A2A)
        : const Color(0xffF7F8F8);
  }

  // Get appropriate background color based on theme
  static Color backgroundColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? const Color(0xff121212) : Colors.white;
  }

  // Get appropriate text color based on theme
  static Color textColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return themeProvider.isDarkMode ? Colors.white : const Color(0xff1D1617);
  }
}
