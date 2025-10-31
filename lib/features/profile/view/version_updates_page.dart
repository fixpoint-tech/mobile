import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../theme/app_colors.dart';

class VersionUpdatesPage extends StatefulWidget {
  const VersionUpdatesPage({super.key});

  @override
  State<VersionUpdatesPage> createState() => _VersionUpdatesPageState();
}

class _VersionUpdatesPageState extends State<VersionUpdatesPage> {
  String _version = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

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
          'Version & Updates',
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
        children: [
          // Current Version Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Current Version',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v$_version (Build $_buildNumber)',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You are using the latest version',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Release Notes
          const Text(
            'Release Notes',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.textTitle,
            ),
          ),

          const SizedBox(height: 16),

          const _UpdateItem(
            version: '1.0.0',
            date: 'October 2025',
            features: [
              'Initial release of Fixpoint mobile app',
              'Issue reporting and tracking system',
              'Real-time chat communication',
              'Network management for GDMs, GPMs, Outlets, and MEs',
              'User profile management',
              'Role-based access control',
            ],
          ),

          const SizedBox(height: 16),

          const _UpdateItem(
            version: '0.9.0 Beta',
            date: 'September 2025',
            features: [
              'Beta testing phase',
              'Core functionality implementation',
              'UI/UX refinements',
              'Performance optimizations',
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateItem extends StatelessWidget {
  const _UpdateItem({
    required this.version,
    required this.date,
    required this.features,
  });

  final String version;
  final String date;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(
                'v$version',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textTitle,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
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
