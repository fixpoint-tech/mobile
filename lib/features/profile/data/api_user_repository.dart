import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/app_user.dart';
import '../../../core/services/auth_service.dart';
import 'user_repository.dart';

/// Real API implementation of UserRepository
/// Connects to the backend to fetch and update user profile data
class ApiUserRepository implements UserRepository {
  final http.Client _client;
  final AuthService _authService;

  ApiUserRepository({
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService.instance;

  /// Get the current user's profile from the backend
  @override
  Future<AppUser> getCurrentUser() async {
    try {
      // Fetch current user from auth service
      final userProfile = _authService.currentUser;

      if (userProfile == null) {
        throw Exception('Not authenticated');
      }

      // Use general users endpoint with the authenticated user's ID
      final url =
          Uri.parse('${ApiConfig.baseUrl}/users/${userProfile.id}');

      final response = await _client
          .get(
            url,
            headers: _authService.getAuthHeaders(),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Backend returns: { success: true, data: { ...user } }
        if (data['success'] == true && data['data'] != null) {
          // Sync with AuthService
          await _authService.updateUserData(data['data']);
          return _mapUserFromApi(data['data']);
        } else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Clear auth on authentication errors
        await _authService.clearAuth();
        throw Exception('Authentication failed');
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
  @override
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? password,
    String? extraField,
    Uint8List? profileImageBytes,
    String? profileImageName,
  }) async {
    try {
      final userProfile = _authService.currentUser;
      if (userProfile == null) {
        throw Exception('Not authenticated');
      }

      final endpoint = _getRoleEndpoint(userProfile.role);
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint/$userId');

      // Prepare fields map
      final Map<String, String> fields = {};

      // Combine first and last name into single 'name' field
      if (firstName != null || lastName != null) {
        final first = firstName?.trim() ?? '';
        final last = lastName?.trim() ?? '';
        final fullName = '$first $last'.trim();
        if (fullName.isNotEmpty) {
          fields['name'] = fullName;
        }
      }

      if (phone != null && phone.isNotEmpty) {
        fields['phone'] = phone;
      }

      if (password != null && password.isNotEmpty) {
        fields['password'] = password;
      }

      // Handle role-specific extra fields
      if (extraField != null && extraField.isNotEmpty) {
        switch (userProfile.role) {
          case 'technician':
            fields['specialization'] = extraField;
            break;
          case 'branch_manager':
            fields['branchId'] = extraField;
            break;
          case 'maintenance_executive':
            fields['department'] = extraField;
            break;
        }
      }
      
      // Debug logging
      print('Updating profile for user $userId, role: ${userProfile.role}');
      print('Fields being sent: $fields');
      print('Has image: ${profileImageBytes != null}, Image name: $profileImageName');
      print('URL: $url');
      
      // If we have an image, we MUST use MultipartRequest
      if (profileImageBytes != null && profileImageName != null) {
        final request = http.MultipartRequest('PUT', url);
        
        // Add auth header only (let http set the multipart content-type)
        final token = _authService.token;
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';
        
        // Add fields
        request.fields.addAll(fields);
        
        // Determine content type from filename extension
        // On web, file names from image_picker might be like "image_picker_xxx.png" or just a blob
        String mimeType = 'image/jpeg'; // default
        String filename = profileImageName;
        
        // Extract extension, handle various filename formats
        String ext = '';
        if (filename.contains('.')) {
          ext = filename.toLowerCase().split('.').last;
        }
        
        print('DEBUG: Original filename: $filename');
        print('DEBUG: Detected extension: $ext');
        
        switch (ext) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          default:
            // If no extension or unknown, default to jpeg
            mimeType = 'image/jpeg';
            // Also ensure filename has an extension for the server
            if (!filename.contains('.')) {
              filename = '$filename.jpg';
            }
        }
        
        print('DEBUG: Using mimeType: $mimeType');
        print('DEBUG: Final filename: $filename');
        
        // Add file from bytes with proper content type
        request.files.add(
          http.MultipartFile.fromBytes(
            'profilePicture',
            profileImageBytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ),
        );
        
        final streamedResponse = await _client.send(request).timeout(ApiConfig.timeout);
        final response = await http.Response.fromStream(streamedResponse);
        
        await _handleResponse(response);
      } else {
        // Normal JSON request if no image
        if (fields.isEmpty) {
           throw Exception('No fields to update');
        }
        
        final response = await _client
            .put(
              url,
              headers: _authService.getAuthHeaders(),
              body: jsonEncode(fields),
            )
            .timeout(ApiConfig.timeout);
            
         await _handleResponse(response);
      }

    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<void> _handleResponse(http.Response response) async {
      print('=== API Response ===');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      print('===================');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] != true) {
            throw Exception(data['message'] ?? 'Update failed');
          }
          // Success - profile updated
        } catch (e) {
          if (e is Exception) rethrow;
          print('Error parsing success response: $e');
          throw Exception('Failed to parse response');
        }
      } else if (response.statusCode == 400) {
        dynamic error;
        try {
          error = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Server returned invalid JSON: ${response.body}');
        }
        
        // Validation errors from express-validator
        if (error['errors'] != null && error['errors'] is List) {
          final errors = (error['errors'] as List)
              .map((e) => e['message'] ?? e.toString())
              .join(', ');
          throw Exception('Validation error: $errors');
        }
        // Controller error message
        else if (error['message'] != null) {
          throw Exception(error['message']);
        }
        // Unknown 400 error
        else {
          throw Exception('Bad request: ${response.body}');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _authService.clearAuth();
        throw Exception('Authentication failed');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Server error (${response.statusCode}): ${response.body}');
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
    if (data['technicianProfile'] != null) {
      profileData = Map<String, dynamic>.from(data['technicianProfile']);
    }
    if (data['branchManagerProfile'] != null) {
      profileData = Map<String, dynamic>.from(data['branchManagerProfile']);
    }
    if (data['maintenanceExecutiveProfile'] != null) {
      profileData = Map<String, dynamic>.from(
        data['maintenanceExecutiveProfile'],
      );
    }

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
