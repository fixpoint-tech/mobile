import 'package:flutter/material.dart';
import '../model/issue_model.dart';
import '../service/issue_api_service.dart';

class IssueController extends ChangeNotifier {
  // Singleton pattern
  static final IssueController _instance = IssueController._internal();
  factory IssueController() => _instance;
  IssueController._internal() {
    // Load issues from API on initialization
    fetchIssues();
  }

  final IssueApiService _apiService = IssueApiService();

  List<IssueModel> _issues = [];
  IssueStatus _selectedFilter = IssueStatus.inProgress;
  bool _isLoading = false;
  String? _error;

  List<IssueModel> get issues => _issues;
  IssueStatus get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<IssueModel> get filteredIssues {
    return _issues.where((issue) => issue.status == _selectedFilter).toList();
  }

  void setFilter(IssueStatus status) {
    _selectedFilter = status;
    notifyListeners();
  }

  /// Fetch all issues from the API
  Future<void> fetchIssues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _issues = await _apiService.fetchIssues(includeRelations: true);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
  }

  Future<void> refreshIssues() async {
    // Fetch fresh data from the API
    await fetchIssues();
  }

  Future<void> createIssue(IssueModel issue) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create issue via API
      final createdIssue = await _apiService.createIssue(issue);
      
      // Add to local list
      _issues.insert(0, createdIssue);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so the UI can show an error message
    }
  }

  Future<void> updateIssueStatus(int issueId, IssueStatus newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update issue status via API
      final updatedIssue = await _apiService.updateIssueStatus(issueId, newStatus);
      
      // Update local list
      final index = _issues.indexWhere((issue) => issue.id == issueId);
      if (index != -1) {
        _issues[index] = updatedIssue;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw so the UI can show an error message
    }
  }

  /// Delete an issue by id. Removes locally on success.
  Future<void> deleteIssue(int issueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteIssue(issueId);

      // Remove from local list if present
      _issues.removeWhere((issue) => issue.id == issueId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
