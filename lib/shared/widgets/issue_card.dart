import 'package:flutter/material.dart';
import '../../features/tickets/model/issue_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Reusable issue card widget used across all user home pages
/// Shows issue details with consistent styling
class IssueCard extends StatelessWidget {
  final IssueModel issue;
  final bool showCriticalBell;
  final String? criticality;

  const IssueCard({
    super.key,
    required this.issue,
    this.showCriticalBell = false,
    this.criticality,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chat');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Criticality Badge Row
            _buildTitleRow(),
            const SizedBox(height: 8),

            // Description
            _buildDescription(),
            const SizedBox(height: 12),

            // Bottom Row with location, issue number, time
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(child: Text(issue.title, style: AppTextStyles.heading3)),
              if (showCriticalBell) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: AppColors.critical,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildCriticalityBadge(),
      ],
    );
  }

  Widget _buildCriticalityBadge() {
    final badgeText = criticality ?? 'General';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(badgeText, style: AppTextStyles.badge),
    );
  }

  Widget _buildDescription() {
    return Text(
      issue.description ?? 'No description provided',
      style: AppTextStyles.bodySmall.copyWith(height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Location icon and branch name
        Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(
          issue.branch?.name ?? 'Unknown Branch',
          style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(width: 16),

        // Time icon and ago text
        const Icon(Icons.access_time, size: 16, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(
          _getTimeAgo(issue.createdAt),
          style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
        ),
        const Spacer(),

        // Profile picture - show assigned person if available
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.grey,
          child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
