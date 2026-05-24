import 'package:flutter/material.dart';
import '../../../core/models/branch.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../../core/services/branch_service.dart';
import '../../../theme/app_colors.dart';

class EditOutletPage extends StatefulWidget {
  final int? outletId;
  final String? outletName;
  final String? outletAddress;

  const EditOutletPage({
    super.key,
    this.outletId,
    this.outletName,
    this.outletAddress,
  });

  @override
  State<EditOutletPage> createState() => _EditOutletPageState();
}

class _EditOutletPageState extends State<EditOutletPage> {
  final BranchService _service = BranchService();
  final BranchManagerService _managerService = BranchManagerService();
  late final TextEditingController _outletNameController;
  late final TextEditingController _cityNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  List<BranchManager> _managers = [];
  BranchManager? _selectedManager;
  bool _isLoadingManagers = true;
  bool _isLoading = false;
  bool _isLoadingData = false;
  Branch? _outlet;

  @override
  void initState() {
    super.initState();
    _outletNameController = TextEditingController(text: widget.outletName);
    _cityNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController(text: widget.outletAddress);

    if (widget.outletId != null) {
      _loadOutletData();
    }
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    try {
      final managers = await _managerService.getAllBranchManagers();
      if (!mounted) return;
      setState(() {
        _managers = managers;
        _isLoadingManagers = false;
      });
      _syncSelectedManager();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingManagers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load managers: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _syncSelectedManager() {
    final outletManagerId = _outlet?.managerId;
    if (outletManagerId == null || _managers.isEmpty) return;
    for (final manager in _managers) {
      if (manager.profileId == outletManagerId || manager.id == outletManagerId) {
        if (mounted) {
          setState(() {
            _selectedManager = manager;
          });
        } else {
          _selectedManager = manager;
        }
        break;
      }
    }
  }

  Future<void> _loadOutletData() async {
    setState(() => _isLoadingData = true);

    try {
      final outlet = await _service.getBranchById(widget.outletId!);
      setState(() {
        _outlet = outlet;
        _outletNameController.text = outlet.name;
        _addressController.text = outlet.location;
        _isLoadingData = false;
      });
      _syncSelectedManager();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load outlet data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _outletNameController.dispose();
    _cityNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (widget.outletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: No outlet ID provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final outletName = _outletNameController.text.trim();
    final address = _addressController.text.trim();

    if (outletName.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a branch manager'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedManager?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected manager is invalid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedManager?.profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected manager profile is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      BranchManager? previousManager;
      for (final manager in _managers) {
        if (manager.profileId == _outlet?.managerId ||
            manager.id == _outlet?.managerId) {
          previousManager = manager;
          break;
        }
      }

      await _service.updateBranch(
        id: widget.outletId!,
        name: outletName,
        location: address,
        managerId: _selectedManager!.profileId,
      );

      if (previousManager?.id != null &&
          previousManager!.id != _selectedManager!.id) {
        await _managerService.updateBranchManager(
          id: previousManager!.id!,
          clearBranch: true,
        );
      }

      await _managerService.updateBranchManager(
        id: _selectedManager!.id!,
        branchId: widget.outletId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outlet updated successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update outlet: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRemoveOutlet() async {
    if (widget.outletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: No outlet ID provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Outlet'),
        content: const Text(
          'Are you sure you want to remove this outlet? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentError),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      try {
        await _service.deleteBranch(widget.outletId!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outlet removed successfully'),
            backgroundColor: AppColors.accentError,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove outlet: ${e.toString()}'),
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
    final availableManagers = _managers
        .where((m) => m.profileId != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add an Outlet',
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

                // Domino's logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/features/list_pages/widgets/dominoz-logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Input fields
                _FilledField(
                  controller: _outletNameController,
                  hintText: 'Outlet Name',
                ),
                const SizedBox(height: 12),

                _FilledField(
                  controller: _cityNameController,
                  hintText: 'City Name',
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

                _FilledField(
                  controller: _addressController,
                  hintText: 'Address',
                ),

                const SizedBox(height: 12),

                _ManagerDropdown(
                  isLoading: _isLoadingManagers,
                  managers: availableManagers,
                  value: _selectedManager,
                  onChanged: (value) {
                    setState(() => _selectedManager = value);
                  },
                ),

                const SizedBox(height: 24),

                // Remove Outlet button
                _RemoveButton(onPressed: _handleRemoveOutlet),

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
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;

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
        ],
      ),
    );
  }
}

/// Branch manager dropdown field
class _ManagerDropdown extends StatelessWidget {
  const _ManagerDropdown({
    required this.isLoading,
    required this.managers,
    required this.value,
    required this.onChanged,
  });

  final bool isLoading;
  final List<BranchManager> managers;
  final BranchManager? value;
  final ValueChanged<BranchManager?> onChanged;

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
              child: DropdownButton<BranchManager>(
                value: value,
                hint: const Text(
                  'Select Branch Manager',
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
                items: managers.map((manager) {
                  return DropdownMenuItem<BranchManager>(
                    value: manager,
                    child: Text(manager.displayName),
                  );
                }).toList(),
                onChanged: managers.isEmpty ? null : onChanged,
              ),
            ),
    );
  }
}

/// Remove Outlet button
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

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
          'Remove Outlet',
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
