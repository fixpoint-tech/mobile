import 'package:flutter/material.dart';
// imports for repository/user model removed because this page no longer shows the profile card
import '../../../theme/app_colors.dart';
import 'getting_started_guide_page.dart';
import 'faq_page.dart';
import 'version_updates_page.dart';
import 'contact_support_page.dart';
import 'troubleshooting_tips_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF292A2D),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: const Color(0xFF292A2D),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: const Color(0xFFF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section (profile card removed)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: const SizedBox.shrink(),
              ),

              const SizedBox(height: 8),

              // Help Options Grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Grid of help options
                    _HelpOptionCard(
                      icon: Icons.rocket_launch_outlined,
                      title: 'Getting Started',
                      subtitle: 'Learn the basics',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const GettingStartedGuidePage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _HelpOptionCard(
                      icon: Icons.help_outline_rounded,
                      title: 'FAQs',
                      subtitle: 'Quick answers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _HelpOptionCard(
                      icon: Icons.system_update_outlined,
                      title: 'Version & Updates',
                      subtitle: 'What\'s new',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VersionUpdatesPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _HelpOptionCard(
                      icon: Icons.support_agent_outlined,
                      title: 'Contact Support',
                      subtitle: 'We\'re here to help',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactSupportPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _HelpOptionCard(
                      icon: Icons.build_outlined,
                      title: 'Troubleshooting',
                      subtitle: 'Fix common issues',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TroubleshootingTipsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpOptionCard extends StatelessWidget {
  const _HelpOptionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Icon(icon, color: AppColors.secondary, size: 28),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textTitle,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
