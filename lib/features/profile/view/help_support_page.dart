import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../../../core/models/app_user.dart';
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
        child: FutureBuilder<AppUser>(
          future: MockUserRepository().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            final user = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryLight,
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      children: [
                        // Profile Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondaryLight,
                                  border: Border.all(
                                    color: AppColors.secondary,
                                    width: 3,
                                  ),
                                  image:
                                      user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(user.avatarUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child:
                                    user.avatarUrl == null ||
                                        user.avatarUrl!.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 32,
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hello! 👋',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColors.textTitle,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.roleTitle,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColors.secondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                                builder: (context) =>
                                    const VersionUpdatesPage(),
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
                                builder: (context) =>
                                    const ContactSupportPage(),
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

                        const SizedBox(height: 32),

                        // Quick Stats
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '24/7 Support Available',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textTitle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Our team is always ready to assist you',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatItem(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                  ),
                                  _StatItem(
                                    icon: Icons.phone_outlined,
                                    label: 'Phone',
                                  ),
                                  _StatItem(
                                    icon: Icons.chat_bubble_outline,
                                    label: 'Chat',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HelpOptionCard extends StatelessWidget {
  const _HelpOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
