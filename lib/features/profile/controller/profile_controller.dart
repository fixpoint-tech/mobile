import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/app_user.dart';
import '../data/user_repository.dart';

/// Controller for managing profile state and operations
class ProfileController extends ChangeNotifier {
  final UserRepository _repository;

  // Controllers for form fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final extraFieldController = TextEditingController();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  ProfileController({required UserRepository repository})
    : _repository = repository {
    _loadCurrentUser();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  XFile? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  /// Get the label for the extra field based on user role
  String get extraFieldLabel {
    if (_currentUser == null) return 'Extra Field';
    switch (_currentUser!.role) {
      case UserRole.branchManager:
        return 'Outlet';
      case UserRole.generalPurposeMechanic:
        return 'Email';
      case UserRole.maintenanceExecutive:
        return 'Location';
    }
  }

  /// Pick an image from gallery
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Optimize image size
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        _selectedImage = pickedFile;
        // Read bytes for cross-platform compatibility (web + mobile)
        _selectedImageBytes = await pickedFile.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  /// Load current user from repository
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();

      // Pre-fill form fields with current user data
      if (_currentUser != null) {
        final nameParts = _currentUser!.fullName.split(' ');
        firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
        lastNameController.text = nameParts.length > 1
            ? nameParts.skip(1).join(' ')
            : '';
        // Prefill phone if available
        if (_currentUser!.phone != null) {
          phoneController.text = _currentUser!.phone!;
        }

        // If the extra field for this role represents Email, prefill it from the user
        if (extraFieldLabel.toLowerCase() == 'email' &&
            _currentUser!.email != null) {
          extraFieldController.text = _currentUser!.email!;
        }
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile() async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(
        userId: _currentUser!.id,
        firstName: firstNameController.text.trim().isEmpty
            ? null
            : firstNameController.text.trim(),
        lastName: lastNameController.text.trim().isEmpty
            ? null
            : lastNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        password: passwordController.text.trim().isEmpty
            ? null
            : passwordController.text.trim(),
        extraField: extraFieldController.text.trim().isEmpty
            ? null
            : extraFieldController.text.trim(),
        profileImageBytes: _selectedImageBytes,
        profileImageName: _selectedImage?.name,
      );
      
      // Reload user data to get updated avatar URL if changed
      await _loadCurrentUser();
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    extraFieldController.dispose();
    super.dispose();
  }
}
