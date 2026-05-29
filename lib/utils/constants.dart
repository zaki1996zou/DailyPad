import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F7CFF);
  static const Color secondary = Color(0xFF6C63FF);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF1F2937);
  static const Color lightSecondaryText = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkPrimaryText = Color(0xFFF9FAFB);
  static const Color darkSecondaryText = Color(0xFFA1A1AA);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color completed = Color(0xFF9CA3AF);

  static const Color categoryPersonal = Color(0xFF4F7CFF);
  static const Color categoryWork = Color(0xFF6C63FF);
  static const Color categoryStudy = Color(0xFF14B8A6);
  static const Color categoryIdeas = Color(0xFFF59E0B);
  static const Color categoryShopping = Color(0xFFEC4899);

  static const Color priorityLow = Color(0xFF22C55E);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);
}

class AppStrings {
  AppStrings._();

  static const String appName = 'DailyPad';
  static const String supportEmail = 'support@dailypad.app';
  static const String appDescription =
      'DailyPad is a simple offline notes and tasks organizer designed to help '
      'you write ideas, manage daily tasks, and keep everything organized on '
      'your iPhone. Everything stays on your device — no account required.';
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double button = 12;
  static const double chip = 20;
}
