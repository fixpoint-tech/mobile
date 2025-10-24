import 'package:flutter/material.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/tickets/view/ticket_list_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/profile/view/user_profile_page.dart';
import '../../features/profile/view/edit_profile_page.dart';
import '../../features/profile/data/user_repository.dart';
import '../../core/models/app_user.dart';

class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String tickets = '/tickets';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.home: (context) => const HomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.tickets: (context) => const TicketListPage(),
    RouteNames.profile: (context) => FutureBuilder<AppUser>(
      future: MockUserRepository().getCurrentUser(),
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
        );
      },
    ),
    RouteNames.editProfile: (context) => const EditProfilePage(),
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

    // Fallback to home page instead of showing 404
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
