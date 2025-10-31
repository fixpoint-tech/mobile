import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class GettingStartedGuidePage extends StatelessWidget {
  const GettingStartedGuidePage({super.key});

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
          'Getting Started Guide',
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
          _GuideSection(
            title: '1. Welcome to Fixpoint',
            content:
                'Fixpoint is your comprehensive maintenance management platform for Domino\'s Sri Lanka. This app helps you manage maintenance requests, track issues, and coordinate with your team efficiently.',
          ),
          SizedBox(height: 24),
          _GuideSection(
            title: '2. Dashboard Overview',
            content:
                'Your home dashboard displays all active maintenance issues. Use the status filters (Open, In Progress, Done) to view specific categories. Tap on any issue card to view details and communicate with your team.',
          ),
          SizedBox(height: 24),
          _GuideSection(
            title: '3. Reporting Issues',
            content:
                'Branch Managers and Maintenance Executives can report new issues by tapping the + button at the bottom of the screen. Fill in the required details including title, description, priority, and location.',
          ),
          SizedBox(height: 24),
          _GuideSection(
            title: '4. Issue Communication',
            content:
                'Tap on any issue card to open the chat interface. Here you can communicate with assigned personnel, share updates, and track progress in real-time.',
          ),
          SizedBox(height: 24),
          _GuideSection(
            title: '5. Managing Your Profile',
            content:
                'Access your profile by tapping the profile icon. Here you can update your personal information, view your role, and access settings.',
          ),
          SizedBox(height: 24),
          _GuideSection(
            title: '6. Network Management',
            content:
                'View and manage GDMs, GPMs, Outlets, and Maintenance Executives through the Network section. Each tab provides detailed information about personnel and locations.',
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          content,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
