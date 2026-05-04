/// Maintenance Executive Model
class MaintenanceExecutive {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String role; // 'maintenance_executive'
  final String? employeeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaintenanceExecutive({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    required this.role,
    this.employeeId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory MaintenanceExecutive.fromJson(Map<String, dynamic> json) {
    final maintenanceExecutiveProfile = json['maintenanceExecutiveProfile'];
    return MaintenanceExecutive(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      role: json['role'] ?? 'maintenance_executive',
      employeeId: maintenanceExecutiveProfile?['employeeId'] ?? json['employeeId'] ?? '',
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
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
      'role': role,
      if (employeeId != null) 'employeeId': employeeId,
    };
  }

  /// Display subtitle
  String get displaySubtitle => 'Maintenance Executive';
}
