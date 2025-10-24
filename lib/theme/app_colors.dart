import 'package:flutter/material.dart';

/// Global color tokens generated from Figma palette
class AppColors {
  AppColors._();

  // Primary scale
  static const primary = Color(0xFFF8FDFF);
  static const primary100 = Color(0xFFF2F2F2);

  // Secondary scale (your main blue set)
  static const secondary = Color(0xFF3EA8D0);
  static const secondary100 = Color(0xFF50B6DC);
  static const secondaryLight = Color(0xFFD6F3FD);

  // Accent scale
  static const accent100 = Color(0xFFFFE4F2);
  static const accent200 = Color(0xFF46BDF0);

  // Neutral & supportive
  static const grey = Color(0xFFD9D9D9);
  static const accentError = Color(0xFFFF7489);

  // Text
  static const textTitle = Color(0xFF292A2D);
  static const textPrimary = Color(0xFF373737);
  static const textSecondary = Color(0xFF7B7B7B);
  static const textDisabled = Color(0xFF979C9E);

  // Surface
  static const surface = Colors.white;
  static const background = Colors.white;

  // Shadow / divider
  static const shadow = Color(0x1A494949);
  static const divider = Color(0x14000000);
}
