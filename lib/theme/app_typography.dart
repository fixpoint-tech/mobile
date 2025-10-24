import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography derived from Figma Text Styles
/// - Heading: Outfit Regular, 96px
/// - Body: Outfit Regular, 96px
/// - Text: Outfit Medium, 13px / 19.5 line height
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(BuildContext context) {
    return TextTheme(
      // Headings — large titles (Figma: 96)
      displayLarge: GoogleFonts.outfit(
        fontSize: 96,
        fontWeight: FontWeight.w400,
        color: AppColors.textTitle,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 96,
        fontWeight: FontWeight.w400,
        color: AppColors.textTitle,
      ),

      // Body — large text blocks (Figma: 96)
      bodyLarge: GoogleFonts.outfit(
        fontSize: 96,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),

      // Text — normal UI / paragraph / label text (Figma: 13, Medium)
      bodyMedium: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textSecondary,
      ),

      // Labels / buttons / small captions
      labelMedium: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
