import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Check if user is authenticated
    final authService = AuthService.instance;
    if (authService.isAuthenticated) {
      // User is logged in, go to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not logged in, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0ECFF), // Soft lavender at top
              Color(0xFFFFFEFD), // Near white in middle
              Color(0xFFE8F7FF), // Soft cyan at bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 330),

                  // Fixpoint Logo
                  Image.asset(
                    'assets/logo/fixpoint_logo.png',
                    width: 139,
                    height: 44,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 11),

                  // Description text
                  SizedBox(
                    width: 218,
                    child: Text(
                      'Smart Maintenance Platform \nfor Domino\'s Sri Lanka',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF999999),
                        height: 1.125,
                      ),
                    ),
                  ),

                  const SizedBox(height: 27),

                  // Loading bar with modern design
                  SizedBox(
                    width: 170,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF3EA8D0),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 327),

                  // Bottom logos section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Domino's logo
                      Image.asset(
                        'assets/logo/Dominos_Symbol.png',
                        width: 40,
                        height: 48,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(width: 16),

                      // Divider
                      Container(width: 1, height: 50, color: AppColors.grey),

                      const SizedBox(width: 15),

                      // FoodWorks logo
                      Image.asset(
                        'assets/logo/FoodWorks_logo.png',
                        width: 75,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 58),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
