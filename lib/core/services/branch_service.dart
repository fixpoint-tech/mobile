import '../models/branch.dart';
import 'api_service.dart';

/// Service for Branch (Outlet) operations
class BranchService {
  final ApiService _apiService = ApiService();

  /// Get all branches
  Future<List<Branch>> getAllBranches() async {
    try {
      final response = await _apiService.get('/branches');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Branch.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch branches: ${e.toString()}');
    }
  }

  /// Get branch by ID
  Future<Branch> getBranchById(int id) async {
    try {
      final response = await _apiService.get('/branches/$id');
      
      if (response['success'] == true && response['data'] != null) {
        return Branch.fromJson(response['data']);
      }
      
      throw ApiException('Branch not found');
    } catch (e) {
      throw ApiException('Failed to fetch branch: ${e.toString()}');
    }
  }

  /// Create a new branch
  Future<Branch> createBranch({
    required String name,
    required String location,
    int? managerId,
  }) async {
    try {
      final data = {
        'name': name,
        'location': location,
        if (managerId != null) 'manager_id': managerId,
      };

      final response = await _apiService.post('/branches', data);
      
      if (response['success'] == true && response['data'] != null) {
        return Branch.fromJson(response['data']);
      }
      
      throw ApiException('Failed to create branch');
    } catch (e) {
      throw ApiException('Failed to create branch: ${e.toString()}');
    }
  }

  /// Update branch
  Future<Branch> updateBranch({
    required int id,
    String? name,
    String? location,
    int? managerId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (location != null) data['location'] = location;
      if (managerId != null) data['manager_id'] = managerId;

      final response = await _apiService.put('/branches/$id', data);
      
      if (response['success'] == true && response['data'] != null) {
        return Branch.fromJson(response['data']);
      }
      
      throw ApiException('Failed to update branch');
    } catch (e) {
      throw ApiException('Failed to update branch: ${e.toString()}');
    }
  }

  /// Delete branch
  Future<bool> deleteBranch(int id) async {
    try {
      final response = await _apiService.delete('/branches/$id');
      return response['success'] == true;
    } catch (e) {
      throw ApiException('Failed to delete branch: ${e.toString()}');
    }
  }
}
