import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Reusable filter chip widget for status tabs
/// Used in all user home pages
class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryLight : AppColors.grey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.secondaryLight : AppColors.grey,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.chipSelected.copyWith(color: AppColors.secondary)
              : AppTextStyles.chipUnselected,
        ),
      ),
    );
  }
}
