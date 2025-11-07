import '../models/maintenance_executive.dart';
import 'api_service.dart';

/// Service for Maintenance Executive operations
class MaintenanceExecutiveService {
  final ApiService _apiService = ApiService();

  /// Get all maintenance executives
  Future<List<MaintenanceExecutive>> getAllMaintenanceExecutives() async {
    try {
      final response = await _apiService.get('/users/maintenance-executives');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => MaintenanceExecutive.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch maintenance executives: ${e.toString()}');
    }
  }

  /// Get maintenance executive by ID
  Future<MaintenanceExecutive> getMaintenanceExecutiveById(int id) async {
    try {
      final response = await _apiService.get('/users/maintenance-executives/$id');
      
      if (response['success'] == true && response['data'] != null) {
        return MaintenanceExecutive.fromJson(response['data']);
      }
      
      throw ApiException('Maintenance executive not found');
    } catch (e) {
      throw ApiException('Failed to fetch maintenance executive: ${e.toString()}');
    }
  }

  /// Create a new maintenance executive
  Future<MaintenanceExecutive> createMaintenanceExecutive({
    required String name,
    required String email,
    String? phone,
    String? password,
    String? employeeId,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        if (employeeId != null) 'employeeId': employeeId,
      };

      final response = await _apiService.post('/users/maintenance-executives', data);
      
      if (response['success'] == true && response['data'] != null) {
        return MaintenanceExecutive.fromJson(response['data']);
      }
      
      throw ApiException('Failed to create maintenance executive');
    } catch (e) {
      throw ApiException('Failed to create maintenance executive: ${e.toString()}');
    }
  }

  /// Update maintenance executive
  Future<MaintenanceExecutive> updateMaintenanceExecutive({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? employeeId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (employeeId != null) data['employeeId'] = employeeId;

      final response = await _apiService.put('/users/maintenance-executives/$id', data);
      
      if (response['success'] == true && response['data'] != null) {
        return MaintenanceExecutive.fromJson(response['data']);
      }
      
      throw ApiException('Failed to update maintenance executive');
    } catch (e) {
      throw ApiException('Failed to update maintenance executive: ${e.toString()}');
    }
  }

  /// Delete maintenance executive
  Future<bool> deleteMaintenanceExecutive(int id) async {
    try {
      final response = await _apiService.delete('/users/maintenance-executives/$id');
      return response['success'] == true;
    } catch (e) {
      throw ApiException('Failed to delete maintenance executive: ${e.toString()}');
    }
  }
}
