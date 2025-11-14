import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/routing/app_router.dart';

/// Reusable user header widget
/// Shows user name, role, and notification icon
class UserHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onTap;

  const UserHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.onNotificationTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed(RouteNames.profile),
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondaryLight,
              child: Icon(Icons.person, color: AppColors.secondary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTextStyles.userName),
                Text(userRole, style: AppTextStyles.userRole),
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
      ),
    );
  }
}
