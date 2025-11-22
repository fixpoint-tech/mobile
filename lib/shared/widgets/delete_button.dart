import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: AppColors.accentError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(41),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        icon: const Icon(
          Icons.delete_outline,
          color: AppColors.accentError,
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.accentError,
          ),
        ),
      ),
    );
  }
}
