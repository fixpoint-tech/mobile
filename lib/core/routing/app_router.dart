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
import '../../features/profile/view/profile_container.dart';
import '../../features/profile/data/api_user_repository.dart';
import '../../core/models/app_user.dart';
import '../../core/services/auth_service.dart';
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
    RouteNames.home: (context) {
      // Route to appropriate home page based on user role
      final authService = AuthService.instance;
      final userRole = authService.currentUser?.role;

      if (userRole == null) {
        // Not authenticated, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // Route based on role
      switch (userRole) {
        case 'technician':
          return const TechnicianHomePage();
        case 'branch_manager':
          return const BranchManagerHomePage();
        case 'maintenance_executive':
          return const MaintenanceExecutiveHomePage();
        default:
          return const MaintenanceExecutiveHomePage();
      }
    },
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.signup: (context) => const SignUpPage(),
    RouteNames.forgotPassword: (context) => const ForgotPasswordPage(),
    RouteNames.tickets: (context) => const TicketListPage(),
    RouteNames.profile: (context) => const ProfileContainer(),
    RouteNames.editProfile: (context) => const EditProfilePage(),
    RouteNames.branchManagerHome: (context) => const BranchManagerHomePage(),
    RouteNames.maintenanceExecutiveHome: (context) =>
        const MaintenanceExecutiveHomePage(),
    RouteNames.technicianHome: (context) => const TechnicianHomePage(),
    RouteNames.reportNewIssue: (context) => const ReportNewIssuePage(),
    RouteNames.reportedIssues: (context) => const ReportedIssuesPage(),

    // Manage Network tabs — ME only
    RouteNames.gdms: (context) => _meOnly(context, const NetworkTabsPage(initialIndex: 0)),
    RouteNames.gpms: (context) => _meOnly(context, const NetworkTabsPage(initialIndex: 1)),
    RouteNames.outlets: (context) => _meOnly(context, const NetworkTabsPage(initialIndex: 2)),
    RouteNames.mes: (context) => _meOnly(context, const NetworkTabsPage(initialIndex: 3)),

    // About page removed

    // Help & Support page
    RouteNames.helpSupport: (context) => const HelpSupportPage(),

    // Notifications page
    RouteNames.notifications: (context) => const NotificationsPage(),
  };

  /// Returns [page] only for maintenance_executive; otherwise shows an access-denied screen.
  static Widget _meOnly(BuildContext context, Widget page) {
    final role = AuthService.instance.currentUser?.role;
    if (role == 'maintenance_executive') return page;
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: const Center(
        child: Text('This section is only accessible to Maintenance Executives.'),
      ),
    );
  }

  /// Handles undefined routes.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const UnknownRouteScreen());
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == RouteNames.chat) {
      return MaterialPageRoute(
        builder: (context) => const ChatPage(),
        settings: settings,
      );
    }
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
