import 'package:flutter/material.dart';
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

  ProfileController({required UserRepository repository})
    : _repository = repository {
    _loadCurrentUser();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// Load current user from repository
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();
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
      );
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
