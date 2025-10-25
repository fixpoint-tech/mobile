class IssueModel {
  final int id;
  final int branchId;
  final String title;
  final int managerId;
  final String? description;
  final int? maintenanceExecutiveId;
  final int? technicianId;
  final IssueStatus status;
  final int? thirdPartyId;
  final DateTime? technicianAssignedAt;
  final DateTime? maintenanceExecutiveAssignedAt;
  final DateTime? thirdPartyAssignedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional relation objects (when include_relations=true)
  final BranchInfo? branch;
  final ManagerInfo? manager;
  final TechnicianInfo? technician;
  final MaintenanceExecutiveInfo? maintenanceExecutive;
  final ThirdPartyInfo? thirdParty;

  IssueModel({
    required this.id,
    required this.branchId,
    required this.title,
    required this.managerId,
    this.description,
    this.maintenanceExecutiveId,
    this.technicianId,
    required this.status,
    this.thirdPartyId,
    this.technicianAssignedAt,
    this.maintenanceExecutiveAssignedAt,
    this.thirdPartyAssignedAt,
    required this.createdAt,
    required this.updatedAt,
    this.branch,
    this.manager,
    this.technician,
    this.maintenanceExecutive,
    this.thirdParty,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as int,
      branchId: json['branch_id'] as int,
      title: json['title'] as String,
      managerId: json['manager_id'] as int,
      description: json['description'] as String?,
      maintenanceExecutiveId: json['maintenance_executive_id'] as int?,
      technicianId: json['technician_id'] as int?,
      status: IssueStatus.fromString(json['status'] as String),
      thirdPartyId: json['third_party_id'] as int?,
      technicianAssignedAt: json['technician_assigned_at'] != null
          ? DateTime.parse(json['technician_assigned_at'] as String)
          : null,
      maintenanceExecutiveAssignedAt: json['maintenance_executive_assigned_at'] != null
          ? DateTime.parse(json['maintenance_executive_assigned_at'] as String)
          : null,
      thirdPartyAssignedAt: json['third_party_assigned_at'] != null
          ? DateTime.parse(json['third_party_assigned_at'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      branch: json['branch'] != null ? BranchInfo.fromJson(json['branch']) : null,
      manager: json['manager'] != null ? ManagerInfo.fromJson(json['manager']) : null,
      technician: json['technician'] != null ? TechnicianInfo.fromJson(json['technician']) : null,
      maintenanceExecutive: json['maintenanceExecutive'] != null 
          ? MaintenanceExecutiveInfo.fromJson(json['maintenanceExecutive']) 
          : null,
      thirdParty: json['thirdParty'] != null ? ThirdPartyInfo.fromJson(json['thirdParty']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'title': title,
      'manager_id': managerId,
      'description': description,
      'maintenance_executive_id': maintenanceExecutiveId,
      'technician_id': technicianId,
      'status': status.value,
      'third_party_id': thirdPartyId,
      'technician_assigned_at': technicianAssignedAt?.toIso8601String(),
      'maintenance_executive_assigned_at': maintenanceExecutiveAssignedAt?.toIso8601String(),
      'third_party_assigned_at': thirdPartyAssignedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  IssueModel copyWith({
    int? id,
    int? branchId,
    String? title,
    int? managerId,
    String? description,
    int? maintenanceExecutiveId,
    int? technicianId,
    IssueStatus? status,
    int? thirdPartyId,
    DateTime? technicianAssignedAt,
    DateTime? maintenanceExecutiveAssignedAt,
    DateTime? thirdPartyAssignedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    BranchInfo? branch,
    ManagerInfo? manager,
    TechnicianInfo? technician,
    MaintenanceExecutiveInfo? maintenanceExecutive,
    ThirdPartyInfo? thirdParty,
  }) {
    return IssueModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      title: title ?? this.title,
      managerId: managerId ?? this.managerId,
      description: description ?? this.description,
      maintenanceExecutiveId: maintenanceExecutiveId ?? this.maintenanceExecutiveId,
      technicianId: technicianId ?? this.technicianId,
      status: status ?? this.status,
      thirdPartyId: thirdPartyId ?? this.thirdPartyId,
      technicianAssignedAt: technicianAssignedAt ?? this.technicianAssignedAt,
      maintenanceExecutiveAssignedAt: maintenanceExecutiveAssignedAt ?? this.maintenanceExecutiveAssignedAt,
      thirdPartyAssignedAt: thirdPartyAssignedAt ?? this.thirdPartyAssignedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branch: branch ?? this.branch,
      manager: manager ?? this.manager,
      technician: technician ?? this.technician,
      maintenanceExecutive: maintenanceExecutive ?? this.maintenanceExecutive,
      thirdParty: thirdParty ?? this.thirdParty,
    );
  }
}

// Relation models
class BranchInfo {
  final int id;
  final String name;
  final String? location;

  BranchInfo({required this.id, required this.name, this.location});

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String?,
    );
  }
}

class UserInfo {
  final int id;
  final String name;
  final String email;

  UserInfo({required this.id, required this.name, required this.email});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class ManagerInfo {
  final int id;
  final UserInfo? user;

  ManagerInfo({required this.id, this.user});

  factory ManagerInfo.fromJson(Map<String, dynamic> json) {
    return ManagerInfo(
      id: json['id'] as int,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class TechnicianInfo {
  final int id;
  final String? specialization;
  final UserInfo? user;

  TechnicianInfo({required this.id, this.specialization, this.user});

  factory TechnicianInfo.fromJson(Map<String, dynamic> json) {
    return TechnicianInfo(
      id: json['id'] as int,
      specialization: json['specialization'] as String?,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class MaintenanceExecutiveInfo {
  final int id;
  final UserInfo? user;

  MaintenanceExecutiveInfo({required this.id, this.user});

  factory MaintenanceExecutiveInfo.fromJson(Map<String, dynamic> json) {
    return MaintenanceExecutiveInfo(
      id: json['id'] as int,
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }
}

class ThirdPartyInfo {
  final int id;
  final String organization;
  final String email;
  final String? worktype;

  ThirdPartyInfo({
    required this.id,
    required this.organization,
    required this.email,
    this.worktype,
  });

  factory ThirdPartyInfo.fromJson(Map<String, dynamic> json) {
    return ThirdPartyInfo(
      id: json['id'] as int,
      organization: json['organization'] as String,
      email: json['email'] as String,
      worktype: json['worktype'] as String?,
    );
  }
}

enum IssueStatus {
  open('Open'),
  inProgress('In Progress'),
  done('Done'),
  closed('Closed');

  final String value;
  const IssueStatus(this.value);

  static IssueStatus fromString(String value) {
    return IssueStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => IssueStatus.open,
    );
  }
}
