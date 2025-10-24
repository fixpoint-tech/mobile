import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable user header widget
/// Shows user name, role, and notification icon
class UserHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onNotificationTap;

  const UserHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: AppTextStyles.userName,
              ),
              Text(
                userRole,
                style: AppTextStyles.userRole,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: onNotificationTap ?? () {},
          ),
        ],
      ),
    );
  }
}
