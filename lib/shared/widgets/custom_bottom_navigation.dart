import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable bottom navigation bar widget
/// Shows light blue bar with optional plus button
class CustomBottomNavigation extends StatelessWidget {
  final bool showAddButton;
  final VoidCallback? onAddTap;

  const CustomBottomNavigation({
    super.key,
    this.showAddButton = true,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: showAddButton
          ? Center(
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: AppColors.white, size: 22),
                ),
              ),
            )
          : const SizedBox(), // Empty for technician
    );
  }
}
