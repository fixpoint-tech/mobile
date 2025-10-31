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
  });

  final String? avatarUrl;
  final String fullName;
  final String? subtitle; // e.g. "Branch Manager | Domino's Pizza - Kottawa"
  final String? handle; // e.g. "@nuwan"
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
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'Profile',
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
          onPressed:
              onBack ??
              () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Profile card with shadow (Figma: fram container)
            Container(
              // reduce horizontal margin so card expands left/right
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.symmetric(
                horizontal: 15.5,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 44,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar (Figma spec: 55.17 x 55.17)
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
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
                            size: 28,
                            color: AppColors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(width: 17),
                  // Text section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Hello!"
                        const Text(
                          'Hello!',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w400,
                            fontSize: 13.55,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Name
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.39,
                            color: AppColors.textTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          // Subtitle
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w400,
                              fontSize: 12.58,
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

            const SizedBox(height: 32),

            // Setting tiles (expanded horizontally)
            Padding(
              // reduce horizontal padding so tiles use more width
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                    subtitle: 'Make changes to your account',
                    onTap:
                        onAccountTap ??
                        () => Navigator.of(context).pushNamed('/profile/edit'),
                  ),
                  const SizedBox(height: 21),
                  _SettingTile(
                    icon: Icons.shield_outlined,
                    title: 'Manage Network',
                    subtitle: 'gdms',
                    onTap:
                        onManageNetworkTap ??
                        () => Navigator.of(context).pushNamed('/gdms'),
                  ),
                  const SizedBox(height: 21),
                  _SettingTile(
                    icon: Icons.favorite_border,
                    title: 'Help & Support',
                    subtitle: 'Contact Support team',
                    onTap:
                        onHelpTap ??
                        () => Navigator.of(context).pushNamed('/help'),
                  ),
                  const SizedBox(height: 21),
                  _SettingTile(
                    icon: Icons.article_outlined,
                    title: 'About App',
                    subtitle: 'Find all the contacts here',
                    onTap:
                        onAboutTap ??
                        () => Navigator.of(context).pushNamed('/about'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 160),

            // Log out
            Center(
              child: TextButton(
                onPressed: onLogout,
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.49,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Icon(icon, size: 23, color: AppColors.accent200),
          const SizedBox(width: 24),
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    fontSize: 19.36,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  // Subtitle
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w300,
                      fontSize: 12.58,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Chevron right
          const Icon(
            Icons.chevron_right,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
