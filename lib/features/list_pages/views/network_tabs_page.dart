// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web; // web hash syncing
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/app_router.dart';
import '../../user/view/add_gdm_page.dart';
import '../../user/view/add_gpm_page.dart';
import '../../user/view/add_outlet_page.dart';
import '../../user/view/add_me_page.dart';
import 'gdms_tab_content.dart';
import 'gpms_tab_content.dart';
import 'outlets_tab_content.dart';
import 'mes_tab_content.dart';

class NetworkTabsPage extends StatefulWidget {
  const NetworkTabsPage({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<NetworkTabsPage> createState() => _NetworkTabsPageState();
}

class _NetworkTabsPageState extends State<NetworkTabsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // 🎨 Figma palette
  static const Color cPrimaryCard = Color(0xFF50B6DC); // operational card + FAB
  static const Color cSelectedPill = Color(0xFF3EA8D0);
  static const Color cPillBg = Color(0xFFEFF3F6);
  static const Color cFooter = Color(0xFFD6F3FD);
  static const Color cHello = Color(0xFF1B1B1B);

  // count chip
  static const Color cCountBg = Color(0xFFEEE9FF);
  static const Color cCountText = Color(0xFF5F33E1);

  static const Map<int, String> _routes = {
    0: RouteNames.gdms,
    1: RouteNames.gpms,
    2: RouteNames.outlets,
    3: RouteNames.mes,
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _pushHashFor(_tab.index);
      setState(() {}); // refresh pills + section title on swipe
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _pushHashFor(_tab.index),
    );
  }

  void _pushHashFor(int index) {
    if (!kIsWeb) return;
    final desired = '#${_routes[index]}';
    if (web.window.location.hash != desired) {
      web.window.history.pushState(null, '', desired);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF9FCFF), Color(0xFFE7F5FF)],
    );

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: bg),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _Header(helloColor: cHello),
              const SizedBox(height: 12),
              const _OperationalCard(color: cPrimaryCard),
              const SizedBox(height: 10),

              // Tabs (left-aligned, wrap content width)
              _TabPills(
                controller: _tab,
                selectedColor: cSelectedPill,
                backgroundColor: cPillBg,
              ),

              // Section title + count chip
              _SectionTitle(
                title: _titleForTab(_tab.index),
                count: _countForTab(_tab.index),
                chipBg: cCountBg,
                chipText: cCountText,
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    GDMsTabContent(),
                    GPMsTabContent(),
                    OutletsTabContent(),
                    MEsTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Footer + FAB (circular)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterDockedFab(
        color: cPrimaryCard,
        onPressed: () {
          // Navigate to appropriate add page based on current tab
          switch (_tab.index) {
            case 0: // GDMs
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddGDMPage()),
              );
              break;
            case 1: // GPMs
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddGPMPage()),
              );
              break;
            case 2: // Outlets
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddOutletPage()),
              );
              break;
            case 3: // MEs
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddMEPage()),
              );
              break;
          }
        },
      ),
      bottomNavigationBar: const _CurvedFooter(
        height: 70,
        background: cFooter,
        notchRadius: 32,
      ),
    );
  }

  static String _titleForTab(int i) {
    switch (i) {
      case 0:
        return 'Guest delight Managers';
      case 1:
        return 'General Purpose Mechanics';
      case 2:
        return "Domino’s Outlets";
      case 3:
        return 'Maintenance Executives';
      default:
        return '';
    }
  }

  static String _countForTab(int i) {
    switch (i) {
      case 0:
        return '52';
      case 1:
        return '10';
      case 2:
        return '6';
      case 3:
        return '2';
      default:
        return '0';
    }
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.helloColor});
  final Color helloColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: _NetworkBlue.k,
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello!',
                style: TextStyle(
                  fontSize: 12,
                  color: helloColor, // #1B1B1B
                  fontWeight: FontWeight.w600, // slightly bolder per Figma
                ),
              ),
              const Text(
                'Induwara Ranasinghe',
                style: TextStyle(
                  fontSize: 18, // +1pt vs before
                  fontWeight: FontWeight.w700, // name is clearly bold in Figma
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications), // filled bell like Figma
            color: Colors.black, // solid black
            iconSize: 22,
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Operational Card
// -----------------------------------------------------------------------------
class _OperationalCard extends StatelessWidget {
  const _OperationalCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Network',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Edit, Update, and Maintain Key Entities',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tabs (left aligned, natural width)
// -----------------------------------------------------------------------------
class _TabPills extends StatefulWidget {
  const _TabPills({
    required this.controller,
    required this.selectedColor,
    required this.backgroundColor,
  });

  final TabController controller;
  final Color selectedColor;
  final Color backgroundColor;

  @override
  State<_TabPills> createState() => _TabPillsState();
}

class _TabPillsState extends State<_TabPills> {
  void _listener() => setState(() {});
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabs = ['GDMs', 'GPMs', 'Outlets', 'MEs'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: List.generate(tabs.length, (index) {
          final selected = widget.controller.index == index;
          return GestureDetector(
            onTap: () => widget.controller.animateTo(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? widget.selectedColor : widget.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Section Title + Count Chip (purple spec)
// -----------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.count,
    required this.chipBg,
    required this.chipText,
  });

  final String title;
  final String count;
  final Color chipBg;
  final Color chipText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: chipText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Footer + FAB
// -----------------------------------------------------------------------------
class _CurvedFooter extends StatelessWidget {
  const _CurvedFooter({
    required this.height,
    required this.background,
    required this.notchRadius,
  });

  final double height;
  final Color background;
  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _FooterPainter(
          background: background,
          notchRadius: notchRadius,
        ),
      ),
    );
  }
}

class _FooterPainter extends CustomPainter {
  _FooterPainter({required this.background, required this.notchRadius});
  final Color background;
  final double notchRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = background;
    final path = Path();
    final r = notchRadius;
    final cx = size.width / 2;

    path
      ..moveTo(0, 8)
      ..quadraticBezierTo(0, 0, 8, 0)
      ..lineTo(cx - r * 1.5, 0)
      ..cubicTo(cx - r, 0, cx - r, r, cx, r)
      ..cubicTo(cx + r, r, cx + r, 0, cx + r * 1.5, 0)
      ..lineTo(size.width - 8, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FooterPainter old) =>
      old.background != background || old.notchRadius != notchRadius;
}

class _CenterDockedFab extends StatelessWidget {
  const _CenterDockedFab({required this.color, this.onPressed});
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      elevation: 6,
      backgroundColor: color,
      onPressed: onPressed ?? () {},
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}

class _NetworkBlue {
  static const k = Color(0xFF50B6DC);
}
