import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/routing/app_router.dart';

/// Reusable user header widget
/// Shows user name, role, and notification icon
class UserHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onTap;

  const UserHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.avatarUrl,
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
            SizedBox(
              width: 48,
              height: 48,
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        // Add cache busting and error handling
                        cacheWidth: 96, // 2x for retina
                        cacheHeight: 96,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryLight,
                            ),
                            child: Icon(Icons.person, color: AppColors.secondary),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryLight,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryLight,
                      ),
                      child: Icon(Icons.person, color: AppColors.secondary),
                    ),
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
