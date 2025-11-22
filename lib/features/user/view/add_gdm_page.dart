import 'package:flutter/material.dart';
import '../../../core/models/branch.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../../core/services/branch_service.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class AddGDMPage extends StatefulWidget {
  const AddGDMPage({super.key});

  @override
  State<AddGDMPage> createState() => _AddGDMPageState();
}

class _AddGDMPageState extends State<AddGDMPage> {
  final BranchManagerService _service = BranchManagerService();
  final BranchService _branchService = BranchService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  List<Branch> _outlets = [];
  Branch? _selectedOutlet;
  bool _isLoading = false;
  bool _isLoadingOutlets = true;

  @override
  void initState() {
    super.initState();
    _loadOutlets();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadOutlets() async {
    try {
      final outlets = await _branchService.getAllBranches();
      setState(() {
        _outlets = outlets;
        _isLoadingOutlets = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOutlets = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load outlets: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleAddUser() async {
    // Validate inputs
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
      await _service.createBranchManager(
        name: '$firstName $lastName',
        email: email,
        phone: phone.isNotEmpty ? phone : null,
        password: 'default123', // You might want to add a password field
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GDM added successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );

      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add GDM: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add a GDM',
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
                const SizedBox(height: 12),

                // Outlet dropdown
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isLoadingOutlets
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<Branch>(
                            value: _selectedOutlet,
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
                            items: _outlets.map((outlet) {
                              return DropdownMenuItem<Branch>(
                                value: outlet,
                                child: Text(outlet.name),
                              );
                            }).toList(),
                            onChanged: (Branch? value) {
                              setState(() => _selectedOutlet = value);
                            },
                          ),
                        ),
                ),

                const SizedBox(height: 32),

                // Add a User button
                CustomButton(
                  onPressed: _isLoading ? null : _handleAddUser,
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
                          'Add a User',
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
