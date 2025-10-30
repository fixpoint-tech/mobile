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

  void _loadSampleData() {
    // Sample data for demonstration (when API is not available)
    _issues = [
      // In Progress Issues
      IssueModel(
        id: 1,
        branchId: 1,
        title: 'Pizza Oven Malfunction',
        managerId: 1,
        description: 'Main oven not heating properly & affecting production.',
        status: IssueStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 2,
        branchId: 1,
        title: 'Freezer Temperature Issue',
        managerId: 1,
        description: 'Freezer not maintaining proper temperature.',
        status: IssueStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 3,
        branchId: 1,
        title: 'Kitchen Sink Leak',
        managerId: 1,
        description: 'Water leaking from main kitchen sink.',
        status: IssueStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      
      // Open Issues (New)
      IssueModel(
        id: 4,
        branchId: 1,
        title: 'Refrigerator Not Working',
        managerId: 1,
        description: 'Walk-in refrigerator temperature rising and affecting food storage.',
        status: IssueStatus.open,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 5,
        branchId: 1,
        title: 'Dishwasher Malfunction',
        managerId: 1,
        description: 'Commercial dishwasher not starting properly.',
        status: IssueStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 6,
        branchId: 1,
        title: 'Exhaust Fan Broken',
        managerId: 1,
        description: 'Kitchen exhaust fan making loud noise and not working.',
        status: IssueStatus.open,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 7,
        branchId: 1,
        title: 'Gas Stove Issue',
        managerId: 1,
        description: 'One of the gas burners not igniting properly.',
        status: IssueStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      
      // Done Issues (Completed)
      IssueModel(
        id: 8,
        branchId: 1,
        title: 'AC System Issue',
        managerId: 1,
        description: 'Air conditioning not cooling properly in dining area.',
        status: IssueStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 9,
        branchId: 1,
        title: 'Door Lock Repair',
        managerId: 1,
        description: 'Main entrance door lock was jammed.',
        status: IssueStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 10,
        branchId: 1,
        title: 'Light Fixture Replacement',
        managerId: 1,
        description: 'Kitchen ceiling light was flickering.',
        status: IssueStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
      IssueModel(
        id: 11,
        branchId: 1,
        title: 'Plumbing Leak Fixed',
        managerId: 1,
        description: 'Bathroom sink had minor leak underneath.',
        status: IssueStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        branch: BranchInfo(id: 1, name: 'Kollupitiya Branch', location: 'Colombo'),
      ),
    ];
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
      // Load sample data as fallback
      _loadSampleData();
      notifyListeners();
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
