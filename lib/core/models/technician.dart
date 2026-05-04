/// Technician Model
class Technician {
final int? id;
final String name;
final String email;
final String? phone;
final String? address;
final String? specialization;
final String? profilePicture;
final String employeeId;
final String role; // 'technician'
final DateTime? createdAt;
final DateTime? updatedAt;

Technician({
  this.id,
  required this.name,
  required this.email,
  this.phone,
  this.address,
  this.specialization,
  this.profilePicture,
  required this.employeeId,
  required this.role,
  this.createdAt,
  this.updatedAt,
});

/// Create from JSON
factory Technician.fromJson(Map<String, dynamic> json) {
  final technicianProfile = json['technicianProfile'];
  return Technician(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
    address: json['address'],
    specialization: technicianProfile?['specialization'] ?? json['specialization'] ?? '',
    employeeId: technicianProfile?['employeeId'] ?? json['employeeId'] ?? '',
    profilePicture: json['profilePicture'],
    role: json['role'] ?? 'technician',
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
    if (address != null) 'address': address,
    if (specialization != null) 'specialization': specialization,
    if (profilePicture != null) 'profilePicture': profilePicture,
    'role': role,
  };
}
}