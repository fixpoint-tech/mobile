import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/app_user.dart';
import 'user_repository.dart';

/// Real API implementation of UserRepository
/// Connects to the backend to fetch and update user profile data
class ApiUserRepository implements UserRepository {
  final http.Client _client;

  // TODO: Replace with actual authentication logic
  // For now, using hardcoded user ID and role
  static const String _currentUserId = '1'; // Get this from auth service
  static const String _currentUserRole =
      'technician'; // Get this from auth service

  ApiUserRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Get the current user's profile from the backend
  Future<AppUser> getCurrentUser() async {
    try {
      // Use general users endpoint so we can fetch any role's profile
      final url = Uri.parse('${ApiConfig.baseUrl}/users/$_currentUserId');

      final response = await _client
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Backend returns: { success: true, data: { ...user } }
        if (data['success'] == true && data['data'] != null) {
          return _mapUserFromApi(data['data']);
        } else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Update the current user's profile
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? password,
    String? extraField,
  }) async {
    try {
      final endpoint = _getRoleEndpoint(_currentUserRole);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/$userId');

      // Build request body
      final Map<String, dynamic> body = {};

      // Combine first and last name into single 'name' field
      if (firstName != null || lastName != null) {
        final first = firstName?.trim() ?? '';
        final last = lastName?.trim() ?? '';
        final fullName = '$first $last'.trim();
        if (fullName.isNotEmpty) {
          body['name'] = fullName;
        }
      }

      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      // Handle role-specific extra fields
      if (extraField != null && extraField.isNotEmpty) {
        switch (_currentUserRole) {
          case 'technician':
            // Technicians might have specialization or employeeId
            body['specialization'] = extraField;
            break;
          case 'branch_manager':
            // Branch managers have branchId
            body['branchId'] = int.tryParse(extraField) ?? extraField;
            break;
          case 'maintenance_executive':
            // Maintenance executives might have department
            body['department'] = extraField;
            break;
        }
      }

      // Don't send empty body
      if (body.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _client
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Update failed');
        }
        // Success - profile updated
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        // Validation errors
        if (error['errors'] != null && error['errors'] is List) {
          final errors = (error['errors'] as List)
              .map((e) => e['message'] ?? e.toString())
              .join(', ');
          throw Exception('Validation error: $errors');
        } else {
          throw Exception(error['message'] ?? 'Invalid data provided');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Map API response to AppUser model
  AppUser _mapUserFromApi(Map<String, dynamic> data) {
    // Extract basic user fields
    final String id = data['id'].toString();
    final String name = data['name'] ?? 'Unknown User';
    final String? profilePicture = data['profilePicture'];
    final String? email = data['email'];
    final String? phone = data['phone']?.toString();
    final String roleStr = data['role'] ?? '';

    // Map role string to UserRole enum
    UserRole role;
    String roleTitle;

    switch (roleStr) {
      case 'technician':
        role = UserRole.generalPurposeMechanic;
        roleTitle = 'General Purpose Mechanic';
        break;
      case 'branch_manager':
        role = UserRole.branchManager;
        roleTitle = 'Branch Manager';
        break;
      case 'maintenance_executive':
        role = UserRole.maintenanceExecutive;
        roleTitle = 'Maintenance Executive';
        break;
      default:
        role = UserRole.generalPurposeMechanic;
        roleTitle = 'Unknown Role';
    }

    // Extract role-specific profile if present
    Map<String, dynamic>? profileData;
    if (data['technicianProfile'] != null)
      profileData = Map<String, dynamic>.from(data['technicianProfile']);
    if (data['branchManagerProfile'] != null)
      profileData = Map<String, dynamic>.from(data['branchManagerProfile']);
    if (data['maintenanceExecutiveProfile'] != null)
      profileData = Map<String, dynamic>.from(
        data['maintenanceExecutiveProfile'],
      );

    return AppUser(
      id: id,
      fullName: name,
      roleTitle: roleTitle,
      role: role,
      avatarUrl: profilePicture,
      email: email,
      phone: phone,
      profile: profileData,
    );
  }

  /// Get the appropriate endpoint for the user's role
  String _getRoleEndpoint(String role) {
    switch (role) {
      case 'technician':
        return '/users/technicians';
      case 'branch_manager':
        return '/users/branch-managers';
      case 'maintenance_executive':
        return '/users/maintenance-executives';
      default:
        return '/users/technicians';
    }
  }

  void dispose() {
    _client.close();
  }
}
