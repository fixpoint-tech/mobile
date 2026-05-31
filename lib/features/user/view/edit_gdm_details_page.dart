import 'package:flutter/material.dart';
import '../../../core/models/branch.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_service.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/delete_button.dart';

class EditGDMDetailsPage extends StatefulWidget {
  final int? gdmId;
  final String? gdmName;
  final String? gdmOutlet;

  const EditGDMDetailsPage({
    super.key,
    this.gdmId,
    this.gdmName,
    this.gdmOutlet,
  });

  @override
  State<EditGDMDetailsPage> createState() => _EditGDMDetailsPageState();
}

class _EditGDMDetailsPageState extends State<EditGDMDetailsPage> {
  final BranchManagerService _service = BranchManagerService();
  final BranchService _branchService = BranchService();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  List<Branch> _outlets = [];
  Branch? _selectedOutlet;
  bool _isLoadingOutlets = true;
  bool _isLoading = false;
  bool _isLoadingData = false;
  BranchManager? _gdm;

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
    _selectedOutlet = null;

    // Load full data if ID is provided
    if (widget.gdmId != null) {
      _loadGDMData();
    }

    _loadOutlets();
  }

  Future<void> _loadOutlets() async {
    try {
      final outlets = await _branchService.getAllBranches();
      if (!mounted) return;
      setState(() {
        _outlets = outlets;
        _isLoadingOutlets = false;
      });
      _syncSelectedOutlet();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOutlets = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load outlets: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _syncSelectedOutlet() {
    final outletId = _gdm?.branchId;
    if (outletId == null || _outlets.isEmpty) return;
    for (final outlet in _outlets) {
      if (outlet.id == outletId) {
        if (mounted) {
          setState(() {
            _selectedOutlet = outlet;
          });
        } else {
          _selectedOutlet = outlet;
        }
        break;
      }
    }
  }

  Future<void> _loadGDMData() async {
    setState(() => _isLoadingData = true);

    try {
      final gdm = await _service.getBranchManagerById(widget.gdmId!);
      setState(() {
        _gdm = gdm;
        final nameParts = gdm.name.split(' ');
        _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
        _lastNameController.text =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _phoneController.text = gdm.phone ?? '';
        _emailController.text = gdm.email;
        _isLoadingData = false;
      });
      _syncSelectedOutlet();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load GDM data: ${e.toString()}'),
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
    if (widget.gdmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: No GDM ID provided'),
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

    if (_selectedOutlet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an outlet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedOutlet?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected outlet is invalid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final previousBranchId = _gdm?.branchId;

      final updatedManager = await _service.updateBranchManager(
        id: widget.gdmId!,
        name: '$firstName $lastName',
        email: email,
        phone: phone.isNotEmpty ? phone : null,
        branchId: _selectedOutlet!.id,
      );

      if (updatedManager.profileId == null) {
        throw Exception('GDM profile is missing');
      }

      await _branchService.updateBranch(
        id: _selectedOutlet!.id!,
        managerId: updatedManager.profileId,
      );

      if (previousBranchId != null && previousBranchId != _selectedOutlet!.id) {
        await _branchService.updateBranch(
          id: previousBranchId,
          clearManager: true,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GDM profile updated successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update GDM: ${e.toString()}'),
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
    if (widget.gdmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: No GDM ID provided'),
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
      setState(() => _isLoading = true);

      try {
        await _service.deleteBranchManager(widget.gdmId!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GDM deleted successfully'),
            backgroundColor: AppColors.accentError,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete GDM: ${e.toString()}'),
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
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'First name',
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Last name',
                  suffix: const Icon(
                    Icons.auto_fix_high,
                    size: 18,
                    color: AppColors.secondary,
                  ),
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
                const SizedBox(height: 12),

                // Outlet dropdown
                _OutletDropdown(
                  isLoading: _isLoadingOutlets,
                  outlets: _outlets,
                  value: _selectedOutlet,
                  onChanged: (value) {
                    setState(() => _selectedOutlet = value);
                  },
                ),

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

/// Outlet dropdown field
class _OutletDropdown extends StatelessWidget {
  const _OutletDropdown({
    required this.isLoading,
    required this.outlets,
    required this.value,
    required this.onChanged,
  });

  final bool isLoading;
  final List<Branch> outlets;
  final Branch? value;
  final ValueChanged<Branch?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<Branch>(
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
                items: outlets.map((outlet) {
                  return DropdownMenuItem<Branch>(
                    value: outlet,
                    child: Text(outlet.name),
                  );
                }).toList(),
                onChanged: outlets.isEmpty ? null : onChanged,
              ),
            ),
    );
  }
}
