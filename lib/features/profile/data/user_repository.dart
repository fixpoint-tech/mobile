import '../../../core/models/app_user.dart';

/// Repository interface for user operations
abstract class UserRepository {
  Future<AppUser> getCurrentUser();
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? password,
    String? extraField,
  });
}

/// Mock implementation of UserRepository for demo
class MockUserRepository implements UserRepository {
  // Change this to test different roles: 0 = Branch Manager, 1 = General Purpose Mechanic, 2 = Maintenance Executive
  static const int _selectedUserIndex = 0;

  static final List<AppUser> _mockUsers = [
    const AppUser(
      id: '1',
      fullName: 'Nuwan Fernando',
      roleTitle: 'Branch Manager',
      role: UserRole.branchManager,
      avatarUrl: null,
    ),
    const AppUser(
      id: '2',
      fullName: 'Kamal Silva',
      roleTitle: 'General Purpose Mechanic',
      role: UserRole.generalPurposeMechanic,
      avatarUrl: null,
    ),
    const AppUser(
      id: '3',
      fullName: 'Amal Perera',
      roleTitle: 'Maintenance Executive',
      role: UserRole.maintenanceExecutive,
      avatarUrl: null,
    ),
  ];

  @override
  Future<AppUser> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockUsers[_selectedUserIndex];
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? password,
    String? extraField,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would send data to backend
    // For now, just return success
  }
}
