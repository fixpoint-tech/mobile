import '../models/branch_manager.dart';
import 'api_service.dart';

/// Service for Branch Manager (GDM/GPM) operations
class BranchManagerService {
  final ApiService _apiService = ApiService();

  /// Get all branch managers
  Future<List<BranchManager>> getAllBranchManagers() async {
    try {
      final response = await _apiService.get('/users/branch-managers');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => BranchManager.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch branch managers: ${e.toString()}');
    }
  }

  /// Get branch manager by ID
  Future<BranchManager> getBranchManagerById(int id) async {
    try {
      final response = await _apiService.get('/users/branch-managers/$id');
      
      if (response['success'] == true && response['data'] != null) {
        return BranchManager.fromJson(response['data']);
      }
      
      throw ApiException('Branch manager not found');
    } catch (e) {
      throw ApiException('Failed to fetch branch manager: ${e.toString()}');
    }
  }

  /// Create a new branch manager
  Future<BranchManager> createBranchManager({
    required String name,
    required String email,
    String? phone,
    String? password,
    int? branchId,
    String? employeeId,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (password != null) 'password': password,
        if (branchId != null) 'branchId': branchId,
        if (employeeId != null) 'employeeId': employeeId,
      };

      final response = await _apiService.post('/users/branch-managers', data);
      
      if (response['success'] == true && response['data'] != null) {
        return BranchManager.fromJson(response['data']);
      }
      
      throw ApiException('Failed to create branch manager');
    } catch (e) {
      throw ApiException('Failed to create branch manager: ${e.toString()}');
    }
  }

  /// Update branch manager
  Future<BranchManager> updateBranchManager({
    required int id,
    String? name,
    String? email,
    String? phone,
    int? branchId,
    String? employeeId,
    bool clearBranch = false,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (clearBranch) {
        data['branchId'] = null;
      } else if (branchId != null) {
        data['branchId'] = branchId;
      }
      if (employeeId != null) data['employeeId'] = employeeId;

      final response = await _apiService.put('/users/branch-managers/$id', data);
      
      if (response['success'] == true && response['data'] != null) {
        return BranchManager.fromJson(response['data']);
      }
      
      throw ApiException('Failed to update branch manager');
    } catch (e) {
      throw ApiException('Failed to update branch manager: ${e.toString()}');
    }
  }

  /// Delete branch manager
  Future<bool> deleteBranchManager(int id) async {
    try {
      final response = await _apiService.delete('/users/branch-managers/$id');
      return response['success'] == true;
    } catch (e) {
      throw ApiException('Failed to delete branch manager: ${e.toString()}');
    }
  }
}
