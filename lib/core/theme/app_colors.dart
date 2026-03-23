import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color charcoal = Color(0xFF2C3E50);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF1A1A1A);

  // Grays
  static const Color gray = Color(0xFF7F8C8D);
  static const Color darkGray = Color(0xFF95A5A6);
  static const Color mediumGray = Color(0xFFBDC3C7);
  static const Color lightGray = Color(0xFFE8EAED);
  static const Color softGray = Color(0xFFF5F5F5);

  // Legacy (keep for compatibility, map to grayscale)
  static const Color accent = nearBlack; // Used for buttons, focus states
  static const Color success = darkGray; // For completed todos
  static const Color error = nearBlack; // For error states

  // Semantic names for new colors
  static const Color hoverBackground = softGray;
  static const Color borderColor = lightGray;
  static const Color textPrimary = charcoal;
  static const Color textSecondary = gray;
}
