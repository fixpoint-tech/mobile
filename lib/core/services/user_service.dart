import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

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
    // Handle both cases
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    final profileData = json['maintenanceExecutiveProfile'] as Map<String, dynamic>?;
    
    return MaintenanceExecutive(
      id: profileData?['id'] as int? ?? json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? json['id'] as int,
      name: userData['name'] as String? ?? json['name'] as String? ?? 'Unknown',
      email: userData['email'] as String? ?? json['email'] as String? ?? '',
      profilePicture: userData['profilePicture'] as String?,
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
}
