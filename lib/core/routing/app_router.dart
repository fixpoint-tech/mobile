import 'package:flutter/material.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/tickets/view/ticket_list_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/chat/view/pages/chat_box.dart';

class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String tickets = '/tickets';
  static const String chat = '/chat';
}

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    RouteNames.home: (context) => const HomePage(),
    RouteNames.login: (context) => const LoginPage(),
    RouteNames.tickets: (context) => const TicketListPage(),
    RouteNames.chat: (context) => const ChatPage(),
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
