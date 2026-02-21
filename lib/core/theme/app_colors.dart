import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color secondary = Color(0xFF6C63FF);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? darkCard : lightSurface;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static const Color primary = Color(0xFFFF6636);
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFE64A19);

  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkSurfaceVariant = Color(0xFF0F3460);
  static const Color darkCard = Color(0xFF1E1E1E);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF0F0F0);

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF707070);

  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  static const List<Color> chartColors = [
    Color(0xFFFF6636),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [darkSurface, darkSurfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
