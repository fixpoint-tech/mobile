/// Branch Manager Model (GDM/GPM)
class BranchManager {
  final int? id;
  final int? profileId;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String role; // 'branch_manager'
  final int? branchId;
  final String? branchName;
  final String? branchLocation;
  final String? employeeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BranchManager({
    this.id,
    this.profileId,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    required this.role,
    this.branchId,
    this.branchName,
    this.branchLocation,
    this.employeeId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory BranchManager.fromJson(Map<String, dynamic> json) {
    // Extract branchId from nested branchManagerProfile
    final branchManagerProfile = json['branchManagerProfile'];
    final int? profileId = branchManagerProfile != null
        ? branchManagerProfile['id'] as int?
        : null;
    final int? branchId = branchManagerProfile != null 
        ? branchManagerProfile['branchId'] 
        : json['branchId'];
    
    return BranchManager(
      id: json['id'],
      profileId: profileId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      role: json['role'] ?? 'branch_manager',
      branchId: branchId,
      branchName: json['Branch']?['name'],
      branchLocation: json['Branch']?['location'],
      employeeId: branchManagerProfile?['employeeId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (profileId != null) 'branchManagerProfileId': profileId,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
      'role': role,
      if (branchId != null) 'branchId': branchId,
      if (employeeId != null) 'employeeId': employeeId,
    };
  }

  /// Display name with role
  String get displayName {
    if (branchName != null) {
      return '$name | $branchName';
    }
    return name;
  }

  /// Get role display text
  String get roleDisplayText {
    // Both GDM and GPM are stored as 'branch_manager' in backend
    // We can differentiate them based on context or additional field
    if (branchName != null) {
      return 'GDM | $branchName';
    }
    return 'GPM';
  }
}
