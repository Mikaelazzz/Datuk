import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles using Plus Jakarta Sans font family
class AppTextStyles {
  // Display styles
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  // Heading styles
  static TextStyle headingLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headingMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headingSmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // Body styles
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w400,
  );

  // Label styles
  static TextStyle labelBold = GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );

  static TextStyle buttonText = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
}
