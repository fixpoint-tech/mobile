import 'package:flutter/material.dart';
import '../../../core/models/technician.dart';
import '../../../core/services/technician_service.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/delete_button.dart';

class EditGPMDetailsPage extends StatefulWidget {
final int? technicianId;
final String? technicianName;
final String? specialization;

const EditGPMDetailsPage({
  super.key,
  this.technicianId,
  this.technicianName,
  this.specialization,
});

@override
State<EditGPMDetailsPage> createState() => _EditGPMDetailsPageState();
}

class _EditGPMDetailsPageState extends State<EditGPMDetailsPage> {
final TechnicianService _service = TechnicianService();
late final TextEditingController _firstNameController;
late final TextEditingController _lastNameController;
late final TextEditingController _phoneController;
late final TextEditingController _emailController;
late final TextEditingController _specializationController;
late final TextEditingController _addressController;

bool _isLoading = false;
bool _isLoadingData = false;
Technician? _technician;

@override
void initState() {
  super.initState();
  final nameParts = widget.technicianName?.split(' ') ?? ['', ''];
  _firstNameController = TextEditingController(
    text: nameParts.isNotEmpty ? nameParts[0] : '',
  );
  _lastNameController = TextEditingController(
    text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
  );
  _phoneController = TextEditingController();
  _emailController = TextEditingController();
  _specializationController = TextEditingController(text: widget.specialization);
  _addressController = TextEditingController();

  if (widget.technicianId != null) {
    _loadTechnicianData();
  }
}

Future<void> _loadTechnicianData() async {
  setState(() => _isLoadingData = true);

  try {
    final technician = await _service.getTechnicianById(widget.technicianId!);
    setState(() {
      _technician = technician;
      final nameParts = technician.name.split(' ');
      _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
      _lastNameController.text =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _phoneController.text = technician.phone ?? '';
      _emailController.text = technician.email;
      _specializationController.text = technician.specialization ?? '';
      _addressController.text = technician.address ?? '';
      _isLoadingData = false;
    });
  } catch (e) {
    if (mounted) {
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Technician data: ${e.toString()}'),
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
  _specializationController.dispose();
  _addressController.dispose();
  super.dispose();
}

Future<void> _handleUpdateProfile() async {
  if (widget.technicianId == null) return;

  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final email = _emailController.text.trim();
  
  if (firstName.isEmpty || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in required fields')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    await _service.updateTechnician(
      id: widget.technicianId!,
      name: '$firstName $lastName',
      email: email,
      phone: _phoneController.text.trim(),
      specialization: _specializationController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Technician updated successfully'), backgroundColor: AppColors.secondary),
    );
    Navigator.of(context).pop(true);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

Future<void> _handleDeleteUser() async {
  if (widget.technicianId == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Technician'),
      content: const Text('Are you sure you want to delete this Technician?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
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
      await _service.deleteTechnician(widget.technicianId!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

@override
Widget build(BuildContext context) {
  if (_isLoadingData) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Edit Technician Details'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_left),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondaryLight.withOpacity(0.75),
                AppColors.accent100.withOpacity(0.55),
              ],
            ),
          ),
        ),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.grey),
                  child: const Icon(Icons.person, size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(controller: _firstNameController, hintText: 'First name'),
              const SizedBox(height: 12),
              CustomTextField(controller: _lastNameController, hintText: 'Last name'),
              const SizedBox(height: 12),
              CustomTextField(controller: _emailController, hintText: 'Email'),
              const SizedBox(height: 12),
              CustomTextField(controller: _phoneController, hintText: 'Phone number'),
              const SizedBox(height: 12),
              CustomTextField(controller: _specializationController, hintText: 'Specialization'),
              const SizedBox(height: 12),
              CustomTextField(controller: _addressController, hintText: 'Address'),
              const SizedBox(height: 24),
              DeleteButton(onPressed: _handleDeleteUser, label: 'Delete Technician'),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: _isLoading ? null : _handleUpdateProfile,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}