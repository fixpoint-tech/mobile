import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
          'About App',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textTitle,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: AppColors.textTitle,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 90),

            // Logo (Figma spec: 139x44 at y:157)
            Center(
              child: Image.asset(
                'assets/logo/fixpoint_logo.png',
                width: 139,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // FixPoint – Smart Maintenance Platform
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                'FixPoint – Smart Maintenance Platform',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 14),

            // 2025 Domino's Sri Lanka Maintenance Project
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 39),
              child: Text(
                "2025 Domino's Sri Lanka Maintenance Project",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 34),

            // Version 1.0.0 tile
            Container(
              height: 45,
              width: double.infinity,
              color: AppColors.primary100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Version  1.0.0',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            // Check For Updates tile
            InkWell(
              onTap: () {
                // TODO: Implement update check
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are using the latest version'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 45,
                color: AppColors.primary100,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Check For Updates',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 25,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 19),

            // Terms and Privacy links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 27,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terms of Services'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                      child: const Text(
                        'Terms of Services',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
