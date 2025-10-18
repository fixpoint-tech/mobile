import 'package:flutter/material.dart';
import '../../../shared/widgets/app_button.dart';
// Avoid importing app_router here to prevent circular imports; use literal routes.

class TicketListPage extends StatelessWidget {
  const TicketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tickets Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SecondaryButton(
              label: 'Go to Home',
              onPressed: () => Navigator.pushNamed(context, '/'),
              width: 160,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Go to Login',
              onPressed: () => Navigator.pushNamed(context, '/login'),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}
