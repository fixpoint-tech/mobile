import 'package:flutter/material.dart';
import '../data/api_user_repository.dart';
import '../../../../core/models/app_user.dart';
import 'user_profile_page.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/routing/app_router.dart';

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  late Future<AppUser> _userFuture;
  final _repository = ApiUserRepository();

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void _refreshUser() {
    setState(() {
      _userFuture = _repository.getCurrentUser();
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await AuthService.instance.clearAuth();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshUser,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final user = snapshot.data!;
        
        return UserProfilePage(
          fullName: user.fullName,
          avatarUrl: user.avatarUrl,
          subtitle: user.roleTitle,
          handle: '@${user.fullName.toLowerCase().split(' ').first}',
          email: user.email,
          phone: user.phone,
          onAccountTap: () async {
            await Navigator.of(context).pushNamed(RouteNames.editProfile);
            // Refresh user data when returning from edit page
            _refreshUser();
          },
          onLogout: _handleLogout,
        );
      },
    );
  }
}
