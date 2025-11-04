import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class TroubleshootingTipsPage extends StatelessWidget {
  const TroubleshootingTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'Troubleshooting Tips',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 17.42,
            color: AppColors.textTitle,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 29,
            color: AppColors.textTitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _TroubleshootingSection(
            title: 'App Not Loading',
            icon: Icons.refresh,
            tips: [
              'Check your internet connection',
              'Close and restart the app',
              'Clear app cache from device settings',
              'Ensure you have the latest version installed',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Login Issues',
            icon: Icons.login,
            tips: [
              'Verify your email and password are correct',
              'Check if Caps Lock is enabled',
              'Use the "Forgot Password" option to reset',
              'Ensure your account is active',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Issues Not Displaying',
            icon: Icons.visibility_off,
            tips: [
              'Pull down to refresh the issue list',
              'Check if you have the correct status filter selected',
              'Verify your role permissions',
              'Ensure you are connected to the network',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Cannot Submit Issue',
            icon: Icons.error_outline,
            tips: [
              'Fill in all required fields',
              'Check your internet connection',
              'Ensure issue title is not empty',
              'Verify location/branch is selected',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Chat Not Working',
            icon: Icons.chat_bubble_outline,
            tips: [
              'Check your internet connection',
              'Refresh the chat by pulling down',
              'Verify you have access to this issue',
              'Close and reopen the chat screen',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Profile Not Updating',
            icon: Icons.person_outline,
            tips: [
              'Ensure all required fields are filled',
              'Check your internet connection',
              'Verify image size is under 5MB',
              'Try saving again after a few moments',
            ],
          ),
          SizedBox(height: 24),
          _TroubleshootingSection(
            title: 'Slow Performance',
            icon: Icons.speed,
            tips: [
              'Close other apps running in background',
              'Clear app cache from device settings',
              'Check available storage on device',
              'Restart your device',
              'Update to the latest app version',
            ],
          ),
          SizedBox(height: 24),
          _TipCard(
            icon: Icons.help_outline,
            title: 'Still Having Issues?',
            description:
                'If the problem persists, please contact our support team. We\'re here to help!',
            actionText: 'Contact Support',
          ),
        ],
      ),
    );
  }
}

class _TroubleshootingSection extends StatelessWidget {
  const _TroubleshootingSection({
    required this.title,
    required this.icon,
    required this.tips,
  });

  final String title;
  final IconData icon;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textTitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionText,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help/contact-support');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
