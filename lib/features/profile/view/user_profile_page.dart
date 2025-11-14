import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.subtitle,
    this.handle,
    this.onBack,
    this.onAccountTap,
    this.onManageNetworkTap,
    this.onHelpTap,
    this.onAboutTap,
    this.onLogout,
    this.email,
    this.phone,
  });

  final String? avatarUrl;
  final String fullName;
  final String? subtitle; // e.g. "Branch Manager | Domino's Pizza - Kottawa"
  final String? handle; // e.g. "@nuwan"
  final String? email;
  final String? phone;
  final VoidCallback? onBack;
  final VoidCallback? onAccountTap;
  final VoidCallback? onManageNetworkTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Profile',
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
          onPressed:
              onBack ??
              () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      backgroundColor: const Color(0xFFF8FDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section with Profile Info
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.2),
                          width: 2,
                        ),
                        image: avatarUrl != null && avatarUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarUrl == null || avatarUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.secondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Text section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello!',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppColors.textTitle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Settings Cards
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _SettingCard(
                      icon: Icons.account_circle_outlined,
                      title: 'Account',
                      subtitle: 'Make changes to your account',
                      onTap:
                          onAccountTap ??
                          () =>
                              Navigator.of(context).pushNamed('/profile/edit'),
                    ),

                    const SizedBox(height: 12),

                    _SettingCard(
                      icon: Icons.shield_outlined,
                      title: 'Manage Network',
                      subtitle: 'gdms',
                      onTap:
                          onManageNetworkTap ??
                          () => Navigator.of(context).pushNamed('/gdms'),
                    ),

                    const SizedBox(height: 12),

                    _SettingCard(
                      icon: Icons.favorite_border,
                      title: 'Help & Support',
                      subtitle: 'Contact Support team',
                      onTap:
                          onHelpTap ??
                          () => Navigator.of(context).pushNamed('/help'),
                    ),

                    const SizedBox(height: 32),

                    // Log out button
                    Center(
                      child: TextButton(
                        onPressed: onLogout,
                        child: const Text(
                          'Log out',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ),
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

/// A card-based setting option matching the Help page design
class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              // Text content
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
              // Forward arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
