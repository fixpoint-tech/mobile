import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'About App',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF292A2D), // Mobile/Black
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left, size: 30),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: Colors.white, // Figma spec: white background
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 90),

            // Logo (Figma spec: 139x44 at y:157)
            Center(
              child: Image.asset(
                'assets/logo/fixpoint_logo.png',
                width: 139,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // FixPoint – Smart Maintenance Platform (Figma spec: y:241, Outfit 14, 400, #444444)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                'FixPoint – Smart Maintenance Platform',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF444444),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 14),

            // 2025 Domino's Sri Lanka Maintenance Project (Figma spec: y:271, Outfit 14, 400, #444444)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 39),
              child: Text(
                "2025 Domino's Sri Lanka Maintenance Project",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF444444),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 34),

            // Version 1.0.0 tile (responsive)
            Container(
              height: 45,
              width: double.infinity,
              color: const Color(0xFFF2F2F2),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Color(0xFF444444),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Version  1.0.0',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF444444),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 9),

            // Check For Updates tile (Figma spec: 367x45 #F2F2F2 at y:385)
            InkWell(
              onTap: () {
                // TODO: Implement update check
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are using the latest version'),
                    backgroundColor: Color(0xFF3EA8D0),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 45,
                color: const Color(0xFFF2F2F2),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Color(0xFF444444),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Check For Updates',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 25,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 19),

            // Terms and Privacy links (responsive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 27,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terms of Services'),
                            backgroundColor: Color(0xFF3EA8D0),
                          ),
                        );
                      },
                      child: const Text(
                        'Terms of Services',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF3EA8D0),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy'),
                            backgroundColor: Color(0xFF3EA8D0),
                          ),
                        );
                      },
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF3EA8D0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
