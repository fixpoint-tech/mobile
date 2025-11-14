import 'package:flutter/material.dart';
import '../../features/auth/view/splash_screen.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/signup_page.dart';
import '../../features/auth/view/forgot_password_page.dart';
import '../../features/tickets/view/ticket_list_page.dart';
import '../../features/tickets/view/report_new_issue_page.dart';
import '../../features/tickets/view/reported_issues_page.dart';
import '../../features/chat/view/pages/chat_box.dart';
import '../../features/profile/view/user_profile_page.dart';
import '../../features/profile/view/edit_profile_page.dart';
import '../../features/profile/data/api_user_repository.dart';
import '../../core/models/app_user.dart';
import '../../features/home/view/branch_manager_home_page.dart';
import '../../features/home/view/maintenance_executive_home_page.dart';
import '../../features/home/view/technician_home_page.dart';
import '../../features/list_pages/views/network_tabs_page.dart';
import '../../features/profile/view/help_support_page.dart';
import '../../features/notifications/view/notifications_page.dart';

class RouteNames {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String tickets = '/tickets';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String helpSupport = '/help';
  static const String branchManagerHome = '/branch-manager-home';
  static const String maintenanceExecutiveHome = '/maintenance-executive-home';
  static const String technicianHome = '/technician-home';
  static const String reportNewIssue = '/report-new-issue';
  static const String reportedIssues = '/reported-issues';
  static const String notifications = '/notifications';
  static const String gdms = '/gdms';
  static const String gpms = '/gpms';
  static const String outlets = '/outlets';
  static const String mes = '/mes';
}

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.splash: (context) => const SplashScreen(),
    RouteNames.home: (context) => const MaintenanceExecutiveHomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.signup: (context) => const SignUpPage(),
    RouteNames.forgotPassword: (context) => const ForgotPasswordPage(),
    RouteNames.tickets: (context) => const TicketListPage(),
    RouteNames.chat: (context) => const ChatPage(),
    RouteNames.profile: (context) => FutureBuilder<AppUser>(
      future: ApiUserRepository().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load profile')),
          );
        }
        final user = snapshot.data!;
        return UserProfilePage(
          fullName: user.fullName,
          subtitle: user.roleTitle,
          handle: '@${user.fullName.toLowerCase().split(' ').first}',
          email: user.email,
          phone: user.phone,
          onLogout: () async {
            // Show confirmation dialog
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

            if (shouldLogout == true && context.mounted) {
              // Clear any stored data (you can add SharedPreferences/SecureStorage here)
              // TODO: Clear auth tokens, user data, etc.

              // Navigate to login and clear navigation stack
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
            }
          },
        );
      },
    ),
    RouteNames.editProfile: (context) => const EditProfilePage(),
    RouteNames.branchManagerHome: (context) => const BranchManagerHomePage(),
    RouteNames.maintenanceExecutiveHome: (context) =>
        const MaintenanceExecutiveHomePage(),
    RouteNames.technicianHome: (context) => const TechnicianHomePage(),
    RouteNames.reportNewIssue: (context) => const ReportNewIssuePage(),
    RouteNames.reportedIssues: (context) => const ReportedIssuesPage(),

    // ✅ Added new routes for the tabbed list pages
    RouteNames.gdms: (context) => const NetworkTabsPage(initialIndex: 0),
    RouteNames.gpms: (context) => const NetworkTabsPage(initialIndex: 1),
    RouteNames.outlets: (context) => const NetworkTabsPage(initialIndex: 2),
    RouteNames.mes: (context) => const NetworkTabsPage(initialIndex: 3),

    // About page removed

    // Help & Support page
    RouteNames.helpSupport: (context) => const HelpSupportPage(),

    // Notifications page
    RouteNames.notifications: (context) => const NotificationsPage(),
  };

  /// Handles undefined routes.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const UnknownRouteScreen());
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    // Fallback to maintenance executive home page instead of showing 404
    return MaterialPageRoute(
      builder: (context) => const MaintenanceExecutiveHomePage(),
      settings: settings,
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: const Center(child: Text('Page Not Found')),
    );
  }
}
