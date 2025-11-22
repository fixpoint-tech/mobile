import 'package:flutter/material.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/delete_button.dart';

class EditGPMDetailsPage extends StatefulWidget {
  final int? gpmId;
  final String? gpmName;
  final String? gpmOutlet;

  const EditGPMDetailsPage({
    super.key,
    this.gpmId,
    this.gpmName,
    this.gpmOutlet,
  });

  @override
  State<EditGPMDetailsPage> createState() => _EditGPMDetailsPageState();
}

class _EditGPMDetailsPageState extends State<EditGPMDetailsPage> {
  final BranchManagerService _service = BranchManagerService();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _isLoadingData = false;
  BranchManager? _gpm;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if available
    final nameParts = widget.gpmName?.split(' ') ?? ['', ''];
    _firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts[0] : '',
    );
    _lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Load full data if ID is provided
    if (widget.gpmId != null) {
      _loadGPMData();
    }
  }

  Future<void> _loadGPMData() async {
    setState(() => _isLoadingData = true);

    try {
      final gpm = await _service.getBranchManagerById(widget.gpmId!);
      setState(() {
        _gpm = gpm;
        final nameParts = gpm.name.split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
        _lastNameController.text =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _phoneController.text = gpm.phone ?? '';
        _emailController.text = gpm.email;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load GPM data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    if (widget.gpmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: No GPM ID provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.updateBranchManager(
        id: widget.gpmId!,
        name: '$firstName $lastName',
        email: email,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPM profile updated successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update GPM: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteUser() async {
    if (widget.gpmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: No GPM ID provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text(
          'Are you sure you want to delete this GPM? This action cannot be undone.',
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
      setState(() => _isLoading = true);

      try {
        await _service.deleteBranchManager(widget.gpmId!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPM deleted successfully'),
            backgroundColor: AppColors.accentError,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete GPM: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit GPM\'s Details',
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
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'First name',
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Last name',
                ),
                const SizedBox(height: 12),

                CustomTextField(
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

                CustomTextField(controller: _emailController, hintText: 'Email'),

                const SizedBox(height: 24),

                // Delete User button
                DeleteButton(onPressed: _handleDeleteUser, label: 'Delete User'),

                const SizedBox(height: 16),

                // Update Profile button
                CustomButton(
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
