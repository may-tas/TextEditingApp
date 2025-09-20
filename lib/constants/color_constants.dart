import 'package:flutter/material.dart';

/// Centralized color constants for the Text Editing App
/// 
/// This class provides a single source of truth for all colors used throughout the application,
/// ensuring consistency and easy maintenance.
class ColorConstants {
  // Private constructor to prevent instantiation
  ColorConstants._();

  // ===== Background Colors =====
  /// Default dark gray background color
  static const Color backgroundDarkGray = Color(0xFF1A1A1A);
  
  /// Deep purple background color
  static const Color backgroundDeepPurple = Color(0xFF2E1065);
  
  /// Deep blue background color
  static const Color backgroundDeepBlue = Color(0xFF1E3A8A);
  
  /// Deep green background color
  static const Color backgroundDeepGreen = Color(0xFF166534);
  
  /// Deep brown/orange background color
  static const Color backgroundDeepBrown = Color(0xFF7C2D12);
  
  /// White background color
  static const Color backgroundWhite = Colors.white;

  /// List of all available background colors
  static const List<Color> backgroundColors = [
    backgroundDarkGray,
    backgroundDeepPurple,
    backgroundDeepBlue,
    backgroundDeepGreen,
    backgroundDeepBrown,
    backgroundWhite,
  ];

  // ===== Snackbar Colors =====
  /// Dark gray background for snackbars
  static const Color snackbarBackground = Color(0xFF3C3C3C);
  
  /// Success snackbar accent color (green)
  static const Color snackbarSuccess = Color(0xFF4CAF50);
  
  /// Info snackbar accent color (blue)
  static const Color snackbarInfo = Color(0xFF2196F3);
  
  /// Error snackbar accent color (red)
  static const Color snackbarError = Color(0xFFF44336);
  
  /// Snackbar text color (white)
  static const Color snackbarText = Colors.white;

  // ===== UI Element Colors =====
  /// Primary white color for UI elements
  static const Color uiWhite = Colors.white;
  
  /// Black color with opacity for shadows and overlays
  static const Color uiBlackOverlay = Colors.black; // Used with withAlpha/withValues
  
  /// Light gray for disabled buttons and light backgrounds
  static const Color uiGrayLight = gray100; // Semantic reference to gray100
  
  /// Medium gray for borders and dividers
  static const Color uiGrayMedium = gray300; // Semantic reference to gray300
  
  /// Dark gray for secondary text and icons
  static const Color uiGrayDark = gray600; // Semantic reference to gray600
  
  /// Blue accent color for selections and highlights
  static const Color uiBlueAccent = Colors.blueAccent;
  
  /// Black color for text (87% opacity)
  static const Color uiTextBlack = Colors.black87;

  /// Black color for icons (54% opacity) - equivalent to Colors.black54
  static const Color uiIconBlack = Color(0x8A000000);

  // Missing Gray[200] equivalent  
  static const Color gray200 = Color(0xFFEEEEEE);

  /// White color for check icons and selected states
  static const Color checkIconWhite = Color(0xFFFFF8F8);

  // ===== Highlight Colors =====
  /// Default yellow highlight color
  static const Color highlightYellow = Colors.yellow;
  
  /// Lime highlight color
  static const Color highlightLime = Colors.lime;
  
  /// Orange highlight color
  static const Color highlightOrange = Colors.orange;
  
  /// Light pink highlight color
  static const Color highlightPink = Color(0xFFF8BBD9); // pink[100] equivalent
  
  /// Light cyan highlight color
  static const Color highlightCyan = Color(0xFFB2EBF2); // cyan[100] equivalent

  /// List of all available highlight colors
  static const List<Color> highlightColors = [
    highlightYellow,
    highlightLime,
    highlightOrange,
    highlightPink,
    highlightCyan,
  ];

  // ===== App Specific Colors =====
  /// App title color on splash screen
  static const Color appTitleColor = Color(0xFF2C2C2C);
  
  /// Transparent color for overlays
  static const Color transparent = Colors.transparent;
  
  /// Background color tray overlay
  static const Color backgroundTrayOverlay = Color.fromARGB(163, 187, 223, 243);

  // ===== Dialog Colors =====
  /// Default dialog button color (blue)
  static const Color dialogButtonBlue = Colors.blue;
  
  /// Warning/orange color for dialog elements
  static const Color dialogWarningOrange = Colors.orange;
  
  /// White color for dialog elements
  static const Color dialogWhite = Colors.white;
  
  /// Black color for dialog text
  static const Color dialogTextBlack = Colors.black;
  
  /// Black color with 87% opacity for dialog text
  static const Color dialogTextBlack87 = Colors.black87;
  
  /// Red color for dialog elements
  static const Color dialogRed = Colors.red;
  
  /// Green color for dialog elements
  static const Color dialogGreen = Colors.green;
  
  /// Purple color for dialog elements
  static const Color dialogPurple = Colors.purple;
  
  /// Gray color for dialog elements
  static const Color dialogGray = Colors.grey;

  // ===== Specific Gray Shades (const-compatible) =====
  /// Gray shade 50 for backgrounds  
  static const Color gray50 = Color(0xFFFAFAFA);
  
  /// Gray shade 100 for light backgrounds
  static const Color gray100 = Color(0xFFF5F5F5);
  
  /// Gray shade 300 for borders
  static const Color gray300 = Color(0xFFE0E0E0);
  
  /// Gray shade 400 for borders and disabled elements
  static const Color gray400 = Color(0xFFBDBDBD);
  
  /// Gray shade 500 for secondary text
  static const Color gray500 = Color(0xFF9E9E9E);
  
  /// Gray shade 600 for secondary text and icons
  static const Color gray600 = Color(0xFF757575);
  
  /// Gray shade 700 for text
  static const Color gray700 = Color(0xFF616161);
  
  /// Gray shade 800 for dark text
  static const Color gray800 = Color(0xFF424242);

  /// List of available dialog colors for color picker
  static const List<Color> dialogColors = [
    dialogTextBlack,
    dialogRed,
    dialogGreen,
    dialogWarningOrange,
    dialogPurple,
    dialogButtonBlue,
  ];

  // ===== Text Colors =====
  /// Available text colors for font color picker
  static const List<Color> textColors = [
    uiWhite,
    dialogTextBlack,
    dialogRed,
    dialogButtonBlue,
    dialogGreen,
    dialogPurple,
    dialogWarningOrange,
  ];

  // ===== Helper Methods =====
  /// Get gray color with specific shade
  static Color? getGrayShade(int shade) {
    return Colors.grey[shade];
  }

  /// Get black color with alpha transparency
  static Color getBlackWithAlpha(int alpha) {
    return Colors.black.withAlpha(alpha);
  }

  /// Get black color with values transparency (new Flutter API)
  static Color getBlackWithValues({required double alpha}) {
    return Colors.black.withValues(alpha: alpha);
  }

  /// Get pink color with specific shade
  static Color? getPinkShade(int shade) {
    return Colors.pink[shade];
  }

  /// Get cyan color with specific shade
  static Color? getCyanShade(int shade) {
    return Colors.cyan[shade];
  }
}