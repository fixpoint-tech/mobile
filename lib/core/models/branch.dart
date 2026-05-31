/// Branch Model (Outlet)
class Branch {
  final int? id;
  final String name;
  final String location;
  final int? managerId;
  final String? managerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Branch({
    this.id,
    required this.name,
    required this.location,
    this.managerId,
    this.managerName,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      managerId: (json['manager_id'] as num?)?.toInt(),
      managerName: json['Manager']?['name'],
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
      'location': location,
      if (managerId != null) 'manager_id': managerId,
    };
  }

  /// Full display name
  String get displayName => name;

  /// Display address
  String get displayAddress => location;
}
