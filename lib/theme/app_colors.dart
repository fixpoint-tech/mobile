import 'package:flutter/material.dart';

/// Global color tokens for the application
/// Based on Figma design system with proper semantic naming
class AppColors {
  AppColors._();

  // Primary scale - Main brand colors
  static const primary = Color(0xFFF8FDFF); // Very light blue background
  static const primary100 = Color(0xFFF2F2F2); // Light grey background

  // Secondary scale - Main interactive blue
  static const secondary = Color(
    0xFF3EA8D0,
  ); // Main blue (primary action color)
  static const secondary100 = Color(0xFF50B6DC); // Lighter blue variant
  static const secondaryLight = Color(0xFFD6F3FD); // Very light blue

  // Accent scale
  static const accent = Color(0xFFFF7489); // Pink/Red accent
  static const accent100 = Color(0xFFFFE4F2); // Light pink
  static const accent200 = Color(0xFF46BDF0); // Light blue accent
  static const accentError = Color(0xFFFF7489); // Error/critical state

  // Neutral & supportive
  static const grey = Color(0xFFD9D9D9); // Grey for unselected states
  static const white = Color(0xFFFFFFFF); // Pure white

  // Text colors
  static const textTitle = Color(0xFF292A2D); // Dark text for titles
  static const textPrimary = Color(0xFF373737); // Primary text
  static const textSecondary = Color(0xFF7B7B7B); // Secondary/hint text
  static const textDisabled = Color(0xFF979C9E); // Disabled text
  static const textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White text on colored backgrounds

  // Surface & background
  static const surface = Colors.white; // Card/surface backgrounds
  static const background = Colors.white; // Main background
  static const backgroundLight = Color(
    0xFFF8FDFF,
  ); // Alternate light background
  static const backgroundGrey = Color(0xFFF2F2F2); // Grey background

  // Borders & shadows
  static const shadow = Color(0x1A494949); // Shadow with 10% opacity
  static const divider = Color(0x14000000); // Divider with 8% opacity

  // Status colors
  static const success = Color(0xFF4CAF50); // Green for success states
  static const critical = Color(0xFFFF7489); // Red for critical/error states
}
