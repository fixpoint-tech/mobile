import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../theme/app_colors.dart';
import '../controller/profile_controller.dart';
import '../data/user_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileController _controller;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(repository: MockUserRepository());
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    final success = await _controller.updateProfile();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Failed to update profile'),
          backgroundColor: AppColors.accentError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.currentUser;

    // Show loading state while fetching user
    if (_controller.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error if user failed to load
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(_controller.errorMessage ?? 'Failed to load user'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 2,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // bell with tiny blue badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none),
                ),
                Positioned(
                  right: 10,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent200, // 46BDF0
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Soft rainbow/pastel background (Figma spec)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FDFF), // AppColors.primary
                  Color.fromRGBO(214, 243, 253, 0.75), // D6F3FD
                  Color.fromRGBO(255, 228, 242, 0.55), // FFE4F2
                ],
                stops: [0.1, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              children: [
                const SizedBox(height: 32),
                // Avatar + Name + Role (Figma: 80x80 avatar)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: user.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFFABABAB),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF181D27), // Primary black
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.roleTitle,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFFABABAB), // Gray / Dark
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Inputs - Figma specs: 45px height, 10px radius, 12px gaps
                _FilledField(
                  controller: _controller.firstNameController,
                  hintText: 'First name',
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _controller.lastNameController,
                  hintText: 'Last name',
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _controller.phoneController,
                  hintText: 'Phone number',
                  prefix: const _PrefixBadge(child: _FlagImage()),
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _controller.passwordController,
                  hintText: 'Password',
                  obscure: _obscure1,
                  suffix: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                      size: 14,
                      color: const Color(0xFF7B7B7B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _controller.confirmPasswordController,
                  hintText: 'Confirm password',
                  obscure: _obscure2,
                  suffix: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                      size: 14,
                      color: const Color(0xFF7B7B7B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _controller.extraFieldController,
                  hintText: _controller.extraFieldLabel,
                ),

                const SizedBox(height: 36),

                // Button (Figma spec: 41px height, solid color, 10px radius)
                _GradientButton(
                  onPressed: _controller.isLoading
                      ? null
                      : _handleUpdateProfile,
                  child: _controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded, filled input (Figma spec: 45px height, 10px radius, #F2F2F2)
class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.controller,
    required this.hintText,
    this.prefix,
    this.suffix,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45, // Figma spec: 45px height
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // Figma spec: #F2F2F2 (Primary-100)
        borderRadius: BorderRadius.circular(10), // Figma spec: 10px radius
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // prefix badge (optional)
          if (prefix != null) ...[
            Padding(padding: const EdgeInsets.only(right: 10), child: prefix),
          ],

          // the editable text
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF7B7B7B), // Figma spec
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),

          // suffix (optional) aligned inside the box
          if (suffix != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Center(child: suffix),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small rounded badge for phone prefix (Figma spec: 20x20 circular)
class _PrefixBadge extends StatelessWidget {
  const _PrefixBadge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Figma spec: 20x20 circular badge
    const size = 20.0;
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(child: child),
    );
  }
}

/// Flag image (Figma spec: 20x20 image)
class _FlagImage extends StatelessWidget {
  const _FlagImage();

  @override
  Widget build(BuildContext context) {
    // Figma spec: 20x20 image for flag
    return SvgPicture.asset(
      'assets/flags/lk.svg',
      width: 20,
      height: 20,
      fit: BoxFit.cover,
      placeholderBuilder: (context) =>
          const Icon(Icons.phone, size: 14, color: Color(0xFF7B7B7B)),
    );
  }
}

/// Button (Figma spec: 41px height, #3EA8D0 color, 10px radius)
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41, // Figma spec: 41px height
      decoration: BoxDecoration(
        color: const Color(0xFF3EA8D0), // Figma spec: #3EA8D0 (Secondary)
        borderRadius: BorderRadius.circular(10), // Figma spec: 10px radius
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(41),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: child,
      ),
    );
  }
}
