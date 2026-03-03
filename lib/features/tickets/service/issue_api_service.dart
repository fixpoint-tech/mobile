import '../../../core/services/api_service.dart';
import '../model/issue_model.dart';

/// Service for issue-related API calls
class IssueApiService {
  final ApiService _apiService = ApiService();

  /// Fetch all issues with optional filters and relations
  Future<List<IssueModel>> fetchIssues({
    int? branchId,
    int? managerId,
    int? technicianId,
    int? maintenanceExecutiveId,
    String? status,
    bool includeRelations = true,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (branchId != null) queryParams['branch_id'] = branchId.toString();
      if (managerId != null) queryParams['manager_id'] = managerId.toString();
      if (technicianId != null) queryParams['technician_id'] = technicianId.toString();
      if (maintenanceExecutiveId != null) {
        queryParams['maintenance_executive_id'] = maintenanceExecutiveId.toString();
      }
      if (status != null) queryParams['status'] = status;
      if (includeRelations) queryParams['include_relations'] = 'true';

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final endpoint = queryString.isEmpty ? '/issues' : '/issues?$queryString';
      final response = await _apiService.get(endpoint);
      
      // Backend returns: { success: true, data: [...], count, total, message }
      final List<dynamic> issuesJson = response['data'] as List<dynamic>;
      
      return issuesJson.map((json) => IssueModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch issues: ${e.toString()}');
    }
  }

  /// Create a new issue
  Future<IssueModel> createIssue(IssueModel issue) async {
    try {
      final response = await _apiService.post('/issues', issue.toJson());
      
      // Backend returns: { success: true, data: {...}, message }
      final issueData = response['data'] as Map<String, dynamic>;
      
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to create issue: ${e.toString()}');
    }
  }

  /// Update issue
  Future<IssueModel> updateIssue(int issueId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/issues/$issueId', updates);
      
      // Backend returns: { success: true, data: {...}, message }
      final issueData = response['data'] as Map<String, dynamic>;
      
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to update issue: ${e.toString()}');
    }
  }

  /// Update issue status
  Future<IssueModel> updateIssueStatus(int issueId, IssueStatus status) async {
    try {
      final response = await _apiService.put('/issues/$issueId/status', {
        'status': status.value,
      });
      
      // Backend returns: { success: true, data: {...}, message }
      final issueData = response['data'] as Map<String, dynamic>;
      
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to update issue status: ${e.toString()}');
    }
  }

  /// Delete an issue
  Future<void> deleteIssue(int issueId) async {
    try {
      await _apiService.delete('/issues/$issueId');
    } catch (e) {
      throw Exception('Failed to delete issue: ${e.toString()}');
    }
  }

  /// Get issue by ID with relations
  Future<IssueModel> getIssueById(int issueId, {bool includeRelations = true}) async {
    try {
      final endpoint = includeRelations 
          ? '/issues/$issueId?include_relations=true'
          : '/issues/$issueId';
      
      final response = await _apiService.get(endpoint);
      
      // Backend returns: { success: true, data: {...}, message }
      final issueData = response['data'] as Map<String, dynamic>;
      
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to fetch issue: ${e.toString()}');
    }
  }

  /// Assign technician to issue
  Future<IssueModel> assignTechnician(int issueId, int technicianId) async {
    try {
      final response = await _apiService.post(
        '/issues/$issueId/assign-technician',
        {'technician_id': technicianId},
      );
      
      final issueData = response['data'] as Map<String, dynamic>;
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to assign technician: ${e.toString()}');
    }
  }

  /// Assign maintenance executive to issue
  Future<IssueModel> assignMaintenanceExecutive(int issueId, int executiveId) async {
    try {
      final response = await _apiService.post(
        '/issues/$issueId/assign-maintenance-executive',
        {'executive_id': executiveId},
      );
      
      final issueData = response['data'] as Map<String, dynamic>;
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to assign maintenance executive: ${e.toString()}');
    }
  }

  /// Assign third party to issue
  Future<IssueModel> assignThirdParty(int issueId, int thirdPartyId) async {
    try {
      final response = await _apiService.post(
        '/issues/$issueId/assign-third-party',
        {'third_party_id': thirdPartyId},
      );
      
      final issueData = response['data'] as Map<String, dynamic>;
      return IssueModel.fromJson(issueData);
    } catch (e) {
      throw Exception('Failed to assign third party: ${e.toString()}');
    }
  }

  /// Add a status update log entry for an issue.
  /// [issueId] - the issue to log against
  /// [userId] - ID of the user making the update
  /// [description] - required description of what changed
  /// [imageUrl] - optional single uploaded image URL (deprecated, use imageUrls)
  /// [imageUrls] - optional list of uploaded image URLs
  /// [statusType] - one of: Open, Assigned, In Progress, Resolved, Closed
  Future<StatusModel> addStatusUpdate({
    required int issueId,
    required int userId,
    required String description,
    String? imageUrl,
    List<String>? imageUrls,
    String statusType = 'Open',
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'user_id': userId,
        'description': description,
        'status_type': statusType,
      };

      // Support both single imageUrl and multiple imageUrls
      if (imageUrls != null && imageUrls.isNotEmpty) {
        requestBody['image_urls'] = imageUrls;
      } else if (imageUrl != null) {
        requestBody['image_url'] = imageUrl;
      }

      final response = await _apiService.post('/issues/$issueId/statuses', requestBody);

      final data = response['data'] as Map<String, dynamic>;
      return StatusModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create status update: ${e.toString()}');
    }
  }

  /// Fetch all status updates for an issue.
  Future<List<StatusModel>> getStatusUpdates(int issueId) async {
    try {
      final response = await _apiService.get('/issues/$issueId/statuses');
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((x) => StatusModel.fromJson(x as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch status updates: ${e.toString()}');
    }
  }
}
