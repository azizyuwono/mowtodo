import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display font (headings) - distinctive but calm
  static TextStyle displayLarge = GoogleFonts.raleway(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.raleway(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle displaySmall = GoogleFonts.raleway(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Body text - clean and readable
  static TextStyle bodyLarge = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: const Color(0xFF8B8B8B),
  );

  // Label text - for secondary information
  static TextStyle labelMedium = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle labelSmall = GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );
}
