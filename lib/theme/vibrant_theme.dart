import 'package:flutter/material.dart';

class VibrantTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFFFF6F00); // Vibrant orange
  static const Color primaryLight = Color(0xFFFF9E40);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color secondaryColor = Color(0xFF03A9F4); // Complementary blue
  static const Color backgroundColor = Color(0xFFFBE9E7); // Light orange tint
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Colors.black87;
  static const Color onSurface = Colors.black87;
  static const Color onError = Colors.white;

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle headlineText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: onBackground,
  );

  static const TextStyle titleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onBackground,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: onBackground,
  );

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: const ColorScheme(
        primary: primaryColor,
        primaryContainer: primaryDark,
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFB3E5FC),
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: onPrimary,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onBackground: onBackground,
        onError: onError,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardTheme(
        color: surfaceColor,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(onPrimary),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: headlineText,
        displayMedium: headlineText,
        displaySmall: headlineText,
        titleLarge: titleText,
        titleMedium: titleText,
        titleSmall: titleText,
        bodyLarge: bodyText,
        bodyMedium: bodyText,
        bodySmall: bodyText,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFFF6F00)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  // Custom extensions
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}