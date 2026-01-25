import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Model for technician (GPM - General Purpose Mechanic) data
class Technician {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String? profilePicture;
  final String? specialization;

  Technician({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.profilePicture,
    this.specialization,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    // The API returns nested user data or flat structure
    // Expected structure from backend:
    // {
    //   "id": <user_id>,
    //   "name": "...",
    //   "email": "...",
    //   "technicianProfile": {
    //     "id": <technician_id>,  // This is the ID we need for assignment
    //     "userId": <user_id>,
    //     "specialization": "..."
    //   }
    // }
    final technicianProfile = json['technicianProfile'] as Map<String, dynamic>?;
    
    // Extract the technician profile ID (not the user ID!)
    int technicianId;
    if (technicianProfile != null && technicianProfile['id'] != null) {
      technicianId = technicianProfile['id'] as int;
    } else {
      // Fallback to json['id'] but this is likely the user ID
      technicianId = json['id'] as int? ?? 0;
      debugPrint('Warning: technicianProfile.id not found, using json[\'id\']: $technicianId');
    }
    
    return Technician(
      id: technicianId,
      userId: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      specialization: technicianProfile?['specialization'] as String?,
    );
  }
}

/// Model for third party (outside support) data
class ThirdParty {
  final int id;
  final String organization;
  final String? contactPerson;
  final String? contactNumber;
  final String? email;
  final String? serviceType;

  ThirdParty({
    required this.id,
    required this.organization,
    this.contactPerson,
    this.contactNumber,
    this.email,
    this.serviceType,
  });

  factory ThirdParty.fromJson(Map<String, dynamic> json) {
    return ThirdParty(
      id: json['id'] as int,
      organization: json['organization'] as String? ?? 'Unknown',
      contactPerson: json['contact_person'] as String?,
      contactNumber: json['contact_number'] as String?,
      email: json['email'] as String?,
      serviceType: json['service_type'] as String?,
    );
  }
}

/// Model for maintenance executive data
class MaintenanceExecutive {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String? profilePicture;

  MaintenanceExecutive({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.profilePicture,
  });

  factory MaintenanceExecutive.fromJson(Map<String, dynamic> json) {
    // The API returns nested user data or flat structure
    // Expected structure from backend:
    // {
    //   "id": <user_id>,
    //   "name": "...",
    //   "email": "...",
    //   "maintenanceExecutiveProfile": {
    //     "id": <executive_id>,  // This is the ID we need for assignment
    //     "userId": <user_id>
    //   }
    // }
    final profileData = json['maintenanceExecutiveProfile'] as Map<String, dynamic>?;
    
    // Extract the executive profile ID (not the user ID!)
    int executiveId;
    if (profileData != null && profileData['id'] != null) {
      executiveId = profileData['id'] as int;
    } else {
      // Fallback to json['id'] but this is likely the user ID
      executiveId = json['id'] as int? ?? 0;
      debugPrint('Warning: maintenanceExecutiveProfile.id not found, using json[\'id\']: $executiveId');
    }
    
    return MaintenanceExecutive(
      id: executiveId,
      userId: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
    );
  }
}

/// Service for fetching user-related data from the backend
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  /// Fetches all maintenance executives from the backend
  /// Returns a list of MaintenanceExecutive objects
  Future<List<MaintenanceExecutive>> getMaintenanceExecutives() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/maintenance-executives');
    
    try {
      final resp = await http
          .get(uri, headers: AuthService.instance.getAuthHeaders())
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        
        return data.map((item) {
          final userMap = item as Map<String, dynamic>;
          return MaintenanceExecutive.fromJson(userMap);
        }).toList();
      } else {
        debugPrint('Failed to fetch maintenance executives: ${resp.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching maintenance executives: $e');
      return [];
    }
  }

  /// Fetches all branch managers from the backend
  Future<List<Map<String, dynamic>>> getBranchManagers() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/branch-managers');
    
    try {
      final resp = await http
          .get(uri, headers: AuthService.instance.getAuthHeaders())
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        debugPrint('Failed to fetch branch managers: ${resp.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching branch managers: $e');
      return [];
    }
  }

  /// Fetches all technicians (GPM - General Purpose Mechanic) from the backend
  /// Returns a list of Technician objects
  Future<List<Technician>> getTechnicians() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/technicians');
    
    try {
      final resp = await http
          .get(uri, headers: AuthService.instance.getAuthHeaders())
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        
        return data.map((item) {
          final userMap = item as Map<String, dynamic>;
          return Technician.fromJson(userMap);
        }).toList();
      } else {
        debugPrint('Failed to fetch technicians: ${resp.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
      return [];
    }
  }

  /// Fetches all third parties (outside support) from the backend
  /// Returns a list of ThirdParty objects
  Future<List<ThirdParty>> getThirdParties() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/thirdparties');
    
    try {
      final resp = await http
          .get(uri, headers: AuthService.instance.getAuthHeaders())
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        
        return data.map((item) {
          final thirdPartyMap = item as Map<String, dynamic>;
          return ThirdParty.fromJson(thirdPartyMap);
        }).toList();
      } else {
        debugPrint('Failed to fetch third parties: ${resp.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching third parties: $e');
      return [];
    }
  }
}
