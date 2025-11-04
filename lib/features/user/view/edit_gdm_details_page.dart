import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class EditGDMDetailsPage extends StatefulWidget {
  final String? gdmName;
  final String? gdmOutlet;

  const EditGDMDetailsPage({super.key, this.gdmName, this.gdmOutlet});

  @override
  State<EditGDMDetailsPage> createState() => _EditGDMDetailsPageState();
}

class _EditGDMDetailsPageState extends State<EditGDMDetailsPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  String? _selectedOutlet;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if available
    final nameParts = widget.gdmName?.split(' ') ?? ['', ''];
    _firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts[0] : '',
    );
    _lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _selectedOutlet = widget.gdmOutlet;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GDM profile updated successfully'),
        backgroundColor: AppColors.secondary,
      ),
    );

    Navigator.of(context).pop();
  }

  Future<void> _handleDeleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text(
          'Are you sure you want to delete this GDM? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentError),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GDM deleted successfully'),
          backgroundColor: AppColors.accentError,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit GDM\'s Details',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textTitle,
          ),
        ),
        elevation: 2,
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: AppColors.textTitle,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Bell with tiny blue badge
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
                      color: AppColors.accent200,
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
          // Soft background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondaryLight.withValues(alpha: 0.75),
                  AppColors.accent100.withValues(alpha: 0.55),
                ],
                stops: const [0.1, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              children: [
                const SizedBox(height: 12),

                // Avatar with add button
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 48,
                          color: AppColors.grey,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Handle image selection
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Input fields
                _FilledField(
                  controller: _firstNameController,
                  hintText: 'First name',
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _lastNameController,
                  hintText: 'Last name',
                  suffix: const Icon(
                    Icons.auto_fix_high,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _phoneController,
                  hintText: 'Phone number',
                  prefix: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentError,
                    ),
                    child: const Center(
                      child: Text(
                        'P',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _FilledField(controller: _emailController, hintText: 'Email'),
                const SizedBox(height: 12),

                // Outlet dropdown
                _OutletDropdown(
                  value: _selectedOutlet,
                  onChanged: (value) {
                    setState(() => _selectedOutlet = value);
                  },
                ),

                const SizedBox(height: 24),

                // Delete User button
                _DeleteButton(onPressed: _handleDeleteUser),

                const SizedBox(height: 16),

                // Update Profile button
                _GradientButton(
                  onPressed: _isLoading ? null : _handleUpdateProfile,
                  child: _isLoading
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
                            color: AppColors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded, filled input field
class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.controller,
    required this.hintText,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prefix badge (optional)
          if (prefix != null) ...[
            Padding(padding: const EdgeInsets.only(right: 10), child: prefix),
          ],

          // The editable text
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w400,
                color: AppColors.textTitle,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
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

          // Suffix (optional)
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

/// Outlet dropdown field
class _OutletDropdown extends StatelessWidget {
  const _OutletDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Name of the Outlet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textTitle,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w400,
            color: AppColors.textTitle,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Kottawa Outlet',
              child: Text('Kottawa Outlet'),
            ),
            DropdownMenuItem(value: 'Outlet2', child: Text('Outlet2')),
            DropdownMenuItem(value: 'Outlet3', child: Text('Outlet3')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Delete button
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: AppColors.accentError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton.icon(
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
        icon: const Icon(
          Icons.delete_outline,
          color: AppColors.accentError,
          size: 18,
        ),
        label: const Text(
          'Delete User',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.accentError,
          ),
        ),
      ),
    );
  }
}

/// Update Profile button
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
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
