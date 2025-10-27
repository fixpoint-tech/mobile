import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(BuildContext context) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.secondary,
      onPrimary: Colors.white,
      secondary: AppColors.accent200,
      onSecondary: Colors.white,
      error: AppColors.accentError,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      tertiary: AppColors.secondaryLight,
      onTertiary: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(context),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textTitle,
        elevation: 2,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.surface,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.secondary,
        textColor: AppColors.textPrimary,
      ),

      dividerColor: AppColors.divider,
    );
  }
}
