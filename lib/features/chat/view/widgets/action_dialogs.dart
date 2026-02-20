import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../theme/app_colors.dart';

/// Dialog for assigning a GPM (Technician) to an issue
class AssignGPMDialog extends StatefulWidget {
  final Function(Technician technician) onAssign;

  const AssignGPMDialog({super.key, required this.onAssign});

  @override
  State<AssignGPMDialog> createState() => _AssignGPMDialogState();
}

class _AssignGPMDialogState extends State<AssignGPMDialog> {
  List<Technician> _technicians = [];
  Technician? _selectedTechnician;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTechnicians() async {
    try {
      final technicians = await UserService.instance.getTechnicians();
      if (mounted) {
        setState(() {
          _technicians = technicians;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Assign a GPM',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Assign the task to the General Purpose Mechanic',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown for selecting GPM
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _technicians.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined, size: 32, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              'No technicians available',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Technician>(
                        value: _selectedTechnician,
                        isExpanded: true,
                        hint: Text(
                          'Suggest a GPM',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        items: _technicians.map((technician) {
                          return DropdownMenuItem<Technician>(
                            value: technician,
                            child: Text(
                              technician.name,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTechnician = value;
                            if (value != null) {
                              _nameController.text = value.name;
                            }
                          });
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // Name text field
            TextField(
              controller: _nameController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.grey),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedTechnician == null
                        ? null
                        : () {
                            widget.onAssign(_selectedTechnician!);
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.grey,
                    ),
                    child: Text(
                      'Assign',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for getting outside support (Third Party)
class GetOutsideSupportDialog extends StatefulWidget {
  final Function(ThirdParty thirdParty) onAssign;

  const GetOutsideSupportDialog({super.key, required this.onAssign});

  @override
  State<GetOutsideSupportDialog> createState() => _GetOutsideSupportDialogState();
}

class _GetOutsideSupportDialogState extends State<GetOutsideSupportDialog> {
  List<ThirdParty> _thirdParties = [];
  ThirdParty? _selectedThirdParty;
  bool _isLoading = true;
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThirdParties();
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadThirdParties() async {
    try {
      final thirdParties = await UserService.instance.getThirdParties();
      if (mounted) {
        setState(() {
          _thirdParties = thirdParties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Get Outside Support',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Assign a third party service provider to this issue',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown for selecting Third Party
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _thirdParties.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.business_outlined, size: 32, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text(
                              'No service providers available',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ThirdParty>(
                        value: _selectedThirdParty,
                        isExpanded: true,
                        hint: Text(
                          'Select a service provider',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                        items: _thirdParties.map((thirdParty) {
                          return DropdownMenuItem<ThirdParty>(
                            value: thirdParty,
                            child: Text(
                              thirdParty.organization,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedThirdParty = value;
                            if (value != null) {
                              _organizationController.text = value.organization;
                              _contactController.text = value.contactPerson ?? '';
                            }
                          });
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            // Organization text field
            TextField(
              controller: _organizationController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Organization',
                labelStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Contact Person text field
            TextField(
              controller: _contactController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Contact Person',
                labelStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.grey),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedThirdParty == null
                        ? null
                        : () {
                            widget.onAssign(_selectedThirdParty!);
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: AppColors.grey,
                    ),
                    child: Text(
                      'Assign',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for closing an issue
class CloseIssueDialog extends StatefulWidget {
  final Function(String? description, XFile? imageFile) onClose;

  const CloseIssueDialog({super.key, required this.onClose});

  @override
  State<CloseIssueDialog> createState() => _CloseIssueDialogState();
}

class _CloseIssueDialogState extends State<CloseIssueDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Close Issue',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Close the issue and finish the maintenance process',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Description text field
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Upload Image button
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedImage == null ? 'Upload Image' : 'Image Selected',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: _selectedImage == null 
                              ? AppColors.textSecondary 
                              : AppColors.secondary,
                          fontWeight: _selectedImage == null 
                              ? FontWeight.w400 
                              : FontWeight.w500,
                        ),
                      ),
                      Icon(
                        _selectedImage == null ? Icons.upload : Icons.check_circle,
                        size: 20,
                        color: _selectedImage == null 
                            ? AppColors.textSecondary 
                            : AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final description = _descriptionController.text.trim().isEmpty
                            ? null
                            : _descriptionController.text.trim();
                        widget.onClose(description, _selectedImage);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Finish',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for suggesting an outside party (for technicians)
class SuggestOutsidePartyDialog extends StatefulWidget {
  final Function(String description, String suggestedParty) onSuggest;

  const SuggestOutsidePartyDialog({super.key, required this.onSuggest});

  @override
  State<SuggestOutsidePartyDialog> createState() => _SuggestOutsidePartyDialogState();
}

class _SuggestOutsidePartyDialogState extends State<SuggestOutsidePartyDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _suggestedPartyController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _suggestedPartyController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _descriptionController.text.trim().isNotEmpty &&
           _suggestedPartyController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Suggest Outside Party',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Suggest an external service provider who can help resolve this issue.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Description field
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description*',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Suggested Party field
              TextField(
                controller: _suggestedPartyController,
                decoration: InputDecoration(
                  hintText: 'Suggested Party',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              widget.onSuggest(
                                _descriptionController.text.trim(),
                                _suggestedPartyController.text.trim(),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: AppColors.grey,
                      ),
                      child: Text(
                        'Finish',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for updating issue status
class UpdateStatusDialog extends StatefulWidget {
  final String currentStatus;
  final Function(String newStatus, String? description, XFile? imageFile) onUpdate;

  const UpdateStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onUpdate,
  });

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  late String _selectedStatus;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'open', 'label': 'Open', 'color': Colors.blue},
    {'value': 'in_progress', 'label': 'In Progress', 'color': Colors.orange},
    {'value': 'resolved', 'label': 'Resolved', 'color': Colors.green},
    {'value': 'closed', 'label': 'Closed', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    // Normalize the status value to match dropdown options
    _selectedStatus = _normalizeStatus(widget.currentStatus);
  }

  /// Normalize status value to match dropdown options
  String _normalizeStatus(String status) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    // Verify it's a valid status, otherwise default to 'open'
    final validStatuses = _statusOptions.map((opt) => opt['value'] as String).toList();
    return validStatuses.contains(normalized) ? normalized : 'open';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Update the Status',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Update the current status of the reported issue',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Status selection dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    items: _statusOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'] as String,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: option['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              option['label'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description text field
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Upload Image button
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedImage == null ? 'Upload Image' : 'Image Selected',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: _selectedImage == null 
                              ? AppColors.textSecondary 
                              : AppColors.secondary,
                          fontWeight: _selectedImage == null 
                              ? FontWeight.w400 
                              : FontWeight.w500,
                        ),
                      ),
                      Icon(
                        _selectedImage == null ? Icons.upload : Icons.check_circle,
                        size: 20,
                        color: _selectedImage == null 
                            ? AppColors.textSecondary 
                            : AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final description = _descriptionController.text.trim().isEmpty
                            ? null
                            : _descriptionController.text.trim();
                        widget.onUpdate(_selectedStatus, description, _selectedImage);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Finish',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for requesting petty cash (for technicians)
class RequestPettyCashDialog extends StatefulWidget {
  final Function(double amount, String description) onRequest;

  const RequestPettyCashDialog({super.key, required this.onRequest});

  @override
  State<RequestPettyCashDialog> createState() => _RequestPettyCashDialogState();
}

class _RequestPettyCashDialogState extends State<RequestPettyCashDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _amountError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text.trim());
    return amount != null && 
           amount > 0 && 
           _descriptionController.text.trim().isNotEmpty;
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.isEmpty) {
        _amountError = null;
      } else {
        final amount = double.tryParse(value);
        if (amount == null) {
          _amountError = 'Please enter a valid number';
        } else if (amount <= 0) {
          _amountError = 'Amount must be greater than 0';
        } else {
          _amountError = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Request Petty Cash',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Submit a request for petty cash to cover issue-related expenses.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Amount field
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (Rs.)*',
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  hintText: 'Enter amount',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  prefixText: 'Rs. ',
                  prefixStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  errorText: _amountError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  _validateAmount(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  hintText: 'Explain what the cash is needed for',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textDisabled,
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.grey),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isValid && !_isSubmitting)
                          ? () {
                              final amount = double.parse(_amountController.text.trim());
                              widget.onRequest(
                                amount,
                                _descriptionController.text.trim(),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: AppColors.grey,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Request',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper functions to show dialogs
Future<void> showAssignGPMDialog(BuildContext context, Function(Technician) onAssign) {
  return showDialog(
    context: context,
    builder: (context) => AssignGPMDialog(onAssign: onAssign),
  );
}

Future<void> showGetOutsideSupportDialog(BuildContext context, Function(ThirdParty) onAssign) {
  return showDialog(
    context: context,
    builder: (context) => GetOutsideSupportDialog(onAssign: onAssign),
  );
}

Future<void> showCloseIssueDialog(BuildContext context, Function(String?, XFile?) onClose) {
  return showDialog(
    context: context,
    builder: (context) => CloseIssueDialog(onClose: onClose),
  );
}

Future<void> showUpdateStatusDialog(
  BuildContext context,
  String currentStatus,
  Function(String, String?, XFile?) onUpdate,
) {
  return showDialog(
    context: context,
    builder: (context) => UpdateStatusDialog(
      currentStatus: currentStatus,
      onUpdate: onUpdate,
    ),
  );
}

Future<void> showSuggestOutsidePartyDialog(
  BuildContext context,
  Function(String, String) onSuggest,
) {
  return showDialog(
    context: context,
    builder: (context) => SuggestOutsidePartyDialog(onSuggest: onSuggest),
  );
}

Future<void> showRequestPettyCashDialog(
  BuildContext context,
  Function(double, String) onRequest,
) {
  return showDialog(
    context: context,
    builder: (context) => RequestPettyCashDialog(onRequest: onRequest),
  );
}
