import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/issue_controller.dart';
import '../model/issue_model.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/upload_service.dart';

class ReportNewIssuePage extends StatefulWidget {
  const ReportNewIssuePage({super.key});

  @override
  State<ReportNewIssuePage> createState() => _ReportNewIssuePageState();
}

class _ReportNewIssuePageState extends State<ReportNewIssuePage> {
  String _selectedIssueType = 'Critical'; // Critical or General
  late DateTime _selectedDate; // Initialize with current date
  MaintenanceExecutive? _selectedExecutive;
  final List<File> _selectedFiles = []; // Real file objects
  final List<UploadedFile> _uploadedFiles = []; // Uploaded file info from server
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final IssueController _issueController = IssueController();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Dynamic data from backend
  List<MaintenanceExecutive> _executives = [];
  bool _isLoadingExecutives = false;
  bool _isUploadingFiles = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Use current date as default
    _loadExecutives();
  }

  Future<void> _loadExecutives() async {
    setState(() {
      _isLoadingExecutives = true;
    });
    
    try {
      final executives = await UserService.instance.getMaintenanceExecutives();
      if (mounted) {
        setState(() {
          _executives = executives;
          _isLoadingExecutives = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingExecutives = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    // Don't dispose singleton controller
    // _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report New Issue',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              // Show help
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue Type - Two Buttons
                  _buildSectionLabel('Issue type'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildIssueTypeButton('Critical'),
                      const SizedBox(width: 12),
                      _buildIssueTypeButton('General'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Reported On
                  _buildSectionLabel('Reported On'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Ash color background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF4FC3F7), // Blue icon
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat(
                              'MMMM dd, yyyy\nhh:mm a',
                            ).format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Task name
                  _buildSectionLabel('Task name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter task name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildSectionLabel('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload file
                  _buildSectionLabel('Upload file'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _uploadFile,
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: const Text('Add Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                      ),
                      if (_selectedFiles.isNotEmpty && !_isUploadingFiles) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _uploadSelectedFiles,
                          icon: const Icon(Icons.cloud_upload, size: 18),
                          label: Text('Upload (${_selectedFiles.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Show uploading indicator
                  if (_isUploadingFiles) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Uploading files...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                  // Show selected files (pending upload) with thumbnails
                  if (_selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Pending Upload:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFiles.asMap().entries.map((entry) {
                        return _buildSelectedFileThumbnail(entry.key, entry.value);
                      }).toList(),
                    ),
                  ],
                  // Show uploaded files
                  if (_uploadedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Uploaded:',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    ..._uploadedFiles.map((file) => _buildUploadedFileChip(file)),
                  ],
                  const SizedBox(height: 20),

                  // Assigned Maintenance Executive
                  _buildSectionLabel('Assigned Maintenance Executive'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _selectExecutive,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                  ),
                  if (_selectedExecutive != null) ...[
                    const SizedBox(height: 12),
                    _buildExecutiveChip(_selectedExecutive!.name),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildIssueTypeButton(String type) {
    final isSelected = _selectedIssueType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIssueType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4FC3F7)
              : Colors.grey[300], // Ash color for unselected
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build thumbnail for selected file (pending upload)
  Widget _buildSelectedFileThumbnail(int index, File file) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeFile(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build chip for uploaded file
  Widget _buildUploadedFileChip(UploadedFile uploadedFile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              uploadedFile.originalName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatFileSize(uploadedFile.size),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              try {
                await UploadService.instance.deleteFile(uploadedFile.url);
                setState(() {
                  _uploadedFiles.remove(uploadedFile);
                });
              } catch (e) {
                // Ignore delete errors
              }
            },
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildExecutiveChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedExecutive = null;
              });
            },
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _uploadFile() {
    // Show options to pick from camera or gallery
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to capture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select existing photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check file limit
      if (_selectedFiles.length >= 5) {
        _showErrorDialog('Maximum 5 files allowed');
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to pick image: ${e.toString()}');
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploadingFiles = true;
    });

    try {
      final uploaded = await UploadService.instance.uploadMultipleFiles(_selectedFiles);
      if (mounted) {
        setState(() {
          _uploadedFiles.addAll(uploaded);
          _selectedFiles.clear();
          _isUploadingFiles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
        });
        _showErrorDialog('Failed to upload files: ${e.toString()}');
      }
    }
  }

  void _selectExecutive() {
    // Show dialog to select executive from dynamic list
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFCE4EC), // Light pink background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Select Maintenance Executive',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        content: _isLoadingExecutives
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _executives.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No maintenance executives available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _executives.map((executive) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: executive.profilePicture != null
                                ? NetworkImage(executive.profilePicture!)
                                : null,
                            child: executive.profilePicture == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(executive.name),
                          subtitle: Text(
                            executive.email,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedExecutive = executive;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    try {
      // Validate required fields
      if (_taskNameController.text.trim().isEmpty) {
        _showErrorDialog('Please enter a task name');
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _showErrorDialog('Please enter a description');
        return;
      }

      // Get current user info for branchId and managerId
      final currentUser = AuthService.instance.currentUser;
      
      // Create new issue
      // Note: id, createdAt, updatedAt will be set by backend
      // For now, we'll set temporary values that will be replaced
      final newIssue = IssueModel(
        id: 0, // Backend will assign the real ID
        branchId: currentUser?.branchId ?? 1, // Use user's branch or default to 1
        managerId: currentUser?.branchManagerProfileId ?? 1, // Use current user's ID if they are the manager
        title: _taskNameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: IssueStatus.open,
        maintenanceExecutiveId: _selectedExecutive?.id, // Use selected executive's real ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add issue to controller
      await _issueController.createIssue(newIssue);

      // Show success message and go back to home page
      if (mounted) {
        // Show success snackbar with custom styling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Expanded(
                  child: Text(
                    'New task created successfully',
                    style: TextStyle(
                      color: Color(0xFF28A745), // Green text
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF28A745), // Green X
                    size: 20,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD4EDDA), // Light green background
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            elevation: 0,
          ),
        );

        // Go back to home page after a brief delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // Clear form fields on error
      _taskNameController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedExecutive = null;
        _uploadedFiles.clear();
      });

      // Show error message with custom styling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Failed to create new task.',
                    style: TextStyle(
                      color: AppColors.primary, // Your blue #3EA8D0
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: const Icon(
                    Icons.close,
                    color: AppColors.primary, // Your blue #3EA8D0
                    size: 20,
                  ),
                ),
              ],
            ),
            backgroundColor:
                AppColors.accent100, // Light pink background (#FFE4F2)
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            elevation: 0,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCE4EC), // Light pink background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFD81B60), // Pink-red color for icon
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFD81B60), // Pink-red color for text
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFD81B60), // Pink-red color for button
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
