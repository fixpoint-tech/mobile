/// User roles in the system
enum UserRole { branchManager, generalPurposeMechanic, maintenanceExecutive }

/// Extension to get display title for each role
extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.branchManager:
        return 'Branch Manager';
      case UserRole.generalPurposeMechanic:
        return 'General Purpose Mechanic';
      case UserRole.maintenanceExecutive:
        return 'Maintenance Executive';
    }
  }
}

/// Application user model
class AppUser {
  final String id;
  final String fullName;
  final String roleTitle;
  final UserRole role;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? profile; // role-specific profile data

  const AppUser({
    required this.id,
    required this.fullName,
    required this.roleTitle,
    required this.role,
    this.avatarUrl,
    this.email,
    this.phone,
    this.profile,
  });

  AppUser copyWith({
    String? id,
    String? fullName,
    String? roleTitle,
    UserRole? role,
    String? avatarUrl,
    String? email,
    String? phone,
    Map<String, dynamic>? profile,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      roleTitle: roleTitle ?? this.roleTitle,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profile: profile ?? this.profile,
    );
  }
}
