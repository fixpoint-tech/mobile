import 'package:flutter/material.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/tickets/view/ticket_list_page.dart';
import '../../features/tickets/view/report_new_issue_page.dart';
import '../../features/tickets/view/reported_issues_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/home/view/branch_manager_home_page.dart';
import '../../features/home/view/maintenance_executive_home_page.dart';
import '../../features/home/view/technician_home_page.dart';
import '../../features/list_pages/views/network_tabs_page.dart';

class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String tickets = '/tickets';
  static const String branchManagerHome = '/branch-manager-home';
  static const String maintenanceExecutiveHome = '/maintenance-executive-home';
  static const String technicianHome = '/technician-home';
  static const String reportNewIssue = '/report-new-issue';
  static const String reportedIssues = '/reported-issues';

  // ✅ Added new route names for list pages
  static const String gdms = '/gdms';
  static const String gpms = '/gpms';
  static const String outlets = '/outlets';
  static const String mes = '/mes';
}

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.home: (context) => const HomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.tickets: (context) => const TicketListPage(),
    RouteNames.branchManagerHome: (context) => const BranchManagerHomePage(),
    RouteNames.maintenanceExecutiveHome: (context) => const MaintenanceExecutiveHomePage(),
    RouteNames.technicianHome: (context) => const TechnicianHomePage(),
    RouteNames.reportNewIssue: (context) => const ReportNewIssuePage(),
    RouteNames.reportedIssues: (context) => const ReportedIssuesPage(),

    // ✅ Added new routes for the tabbed list pages
    RouteNames.gdms: (context) => const NetworkTabsPage(initialIndex: 0),
    RouteNames.gpms: (context) => const NetworkTabsPage(initialIndex: 1),
    RouteNames.outlets: (context) => const NetworkTabsPage(initialIndex: 2),
    RouteNames.mes: (context) => const NetworkTabsPage(initialIndex: 3),
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

    // Fallback to home instead of showing 404 so app always boots to Home.
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
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

