import 'package:flutter/material.dart';
import '../data/user_repository.dart';
import '../../../core/models/app_user.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 17.42,
            color: Color(0xFF292A2D), // Mobile/Black
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left, size: 29),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<AppUser>(
          future: MockUserRepository().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Failed to load profile'));
            }
            final user = snapshot.data!;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Reduced top spacing to tighten layout per request
                const SizedBox(height: 24),

                // Divider removed per request
                const SizedBox(height: 10),

                // Profile card (slightly reduced left/right padding)
                Center(
                  child: Container(
                    width: 308.79,
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    padding: const EdgeInsets.all(15.49),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.68),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.0),
                          blurRadius: 43.56,
                          offset: const Offset(0, -3.87),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar (increased slightly)
                        Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
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
                              user.avatarUrl == null || user.avatarUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Color(0xFFD7D7D7),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Text section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Hello!" (slightly larger for readability)
                              const Text(
                                'Hello!',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Name (Figma spec: Outfit 18.39, 600)
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0,
                                  color: Color(0xFF000000),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Subtitle (Figma spec: Outfit 5.81, 400, #7B7B7B)
                              Text(
                                user.roleTitle,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 7.0,
                                  color: Color(0xFF7B7B7B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 90),

                // Help sections (reduced left padding)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HelpTile(
                        title: 'Getting started Guide',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Getting started Guide'),
                              backgroundColor: Color(0xFF3EA8D0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      _HelpTile(
                        title: 'FAQ',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('FAQ'),
                              backgroundColor: Color(0xFF3EA8D0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      _HelpTile(
                        title: 'Version & Updates',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Version & Updates'),
                              backgroundColor: Color(0xFF3EA8D0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      _HelpTile(
                        title: 'Contact Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contact Support'),
                              backgroundColor: Color(0xFF3EA8D0),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      _HelpTile(
                        title: 'Troubleshooting Tips',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Troubleshooting Tips'),
                              backgroundColor: Color(0xFF3EA8D0),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Title (Figma spec: Outfit 19.36, 500, #373737)
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
                fontSize: 19.36,
                color: Color(0xFF373737),
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Chevron right (Figma spec: 20.33x20.33)
          const Icon(
            Icons.chevron_right,
            size: 20.33,
            color: Color(0xFF373737),
          ),
        ],
      ),
    );
  }
}
