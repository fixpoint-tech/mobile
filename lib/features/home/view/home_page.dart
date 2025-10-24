import 'package:flutter/material.dart';
import '../../../shared/widgets/app_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SecondaryButton(
              label: 'Go to Login',
              onPressed: () => Navigator.pushNamed(context, '/login'),
              width: 160,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Go to Tickets',
              onPressed: () => Navigator.pushNamed(context, '/tickets'),
              width: 160,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Go to Chat',
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}
