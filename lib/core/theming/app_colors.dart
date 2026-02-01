// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A3FCC);
  static const Color primaryVeryLight = Color(0xFFE8E6FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFFB3C6);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  static const Color error = Color(0xFFE53935);

  // Light Theme Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color border = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color overlay = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF3A3A3A);

  // Message Bubble Colors
  static const Color sentMessageBg = Color(0xFF6C63FF);
  static const Color sentMessageText = Colors.white;
  static const Color receivedMessageBg = Color(0xFFF0F0F0);
  static const Color receivedMessageText = Color(0xFF212121);
  static const Color messageBorder = Color(0xFFE8E8E8);
  static const Color messageTimestamp = Color(0xFF9E9E9E);

  // Dark Theme Message Bubbles
  static const Color darkSentMessageBg = Color(0xFF6C63FF);
  static const Color darkReceivedMessageBg = Color(0xFF2C2C2C);
  static const Color darkReceivedMessageText = Color(0xFFE0E0E0);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F7FF), Color(0xFFFFFFFF)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF8FA3)],
  );

  // Shadow Colors
  static Color primaryShadow = primary.withOpacity(0.3);
  static Color cardShadow = Colors.black.withOpacity(0.08);
  static Color darkCardShadow = Colors.black.withOpacity(0.3);

  // Status Colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFFA726);

  // Badge Colors
  static const Color badgeRed = Color(0xFFE53935);
  static const Color badgeBlue = Color(0xFF2196F3);
  static const Color badgeGreen = Color(0xFF4CAF50);
}
