import 'package:flutter/material.dart';
import '../../tickets/controller/issue_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../tickets/model/issue_model.dart';
import '../../../shared/widgets/user_header.dart';
import '../../../shared/widgets/status_filter_chip.dart';
import '../../../shared/widgets/issue_card.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../../../theme/app_colors.dart';
import '../../chat/view/pages/chat_box.dart';
import '../../tickets/service/issue_api_service.dart';

class MaintenanceExecutiveHomePage extends StatefulWidget {
  const MaintenanceExecutiveHomePage({super.key});

  @override
  State<MaintenanceExecutiveHomePage> createState() =>
      _MaintenanceExecutiveHomePageState();
}

class _MaintenanceExecutiveHomePageState
    extends State<MaintenanceExecutiveHomePage> {
  final IssueController _issueController = IssueController();
  final IssueApiService _issueApiService = IssueApiService();
  final PageController _pageController = PageController(
    initialPage: 1,
  ); // Start at In Progress
  int _currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    _issueController.setFilter(IssueStatus.inProgress);
    _issueController.refreshIssues();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  // @override
  // void dispose() {
  //   _issueController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          // User Header
          // User Header
          ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              return UserHeader(
                userName: AuthService.instance.currentUser?.name ?? 'User',
                userRole: AuthService.instance.currentUser?.role == 'maintenance_executive'
                    ? 'Maintenance Executive'
                    : (AuthService.instance.currentUser?.role ?? ''),
                avatarUrl: AuthService.instance.currentUser?.profilePicture,
                onNotificationTap: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
              );
            },
          ),

          // Filter Chips (tap to jump to page OR swipe pages)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                StatusFilterChip(
                  label: 'Open',
                  isSelected: _currentPageIndex == 0,
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(width: 8),
                StatusFilterChip(
                  label: 'In Progress',
                  isSelected: _currentPageIndex == 1,
                  onTap: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(width: 8),
                StatusFilterChip(
                  label: 'Done',
                  isSelected: _currentPageIndex == 2,
                  onTap: () {
                    _pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),

          // Swipeable PageView for the 3 status sections
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                  final statuses = [
                    IssueStatus.open,
                    IssueStatus.inProgress,
                    IssueStatus.done,
                  ];
                  _issueController.setFilter(statuses[index]);
                });
              },
              children: [
                _buildIssueListPage(IssueStatus.open),
                _buildIssueListPage(IssueStatus.inProgress),
                _buildIssueListPage(IssueStatus.done),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        showAddButton: true,
        onAddTap: () {
          // ME can also create issues
          Navigator.pushNamed(context, '/report-new-issue');
        },
      ),
    );
  }

  Widget _buildIssueListPage(IssueStatus status) {
    return ListenableBuilder(
      listenable: _issueController,
      builder: (context, _) {
        final issues = _issueController.issues.where((issue) {
          if (status == IssueStatus.inProgress) {
            return issue.status == IssueStatus.inProgress ||
                issue.status == IssueStatus.pendingResolution ||
                issue.status == IssueStatus.pendingClose;
          }
          return issue.status == status;
        }).toList();

        if (issues.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${status.value.toLowerCase()} issues',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: issues.map((issue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _onTapIssue(issue),
                  onLongPress: () => _onLongPressIssue(issue),
                  child: IssueCard(
                    issue: issue,
                    showCriticalBell: true,
                    criticality: 'Critical',
                    onTap: () => _onTapIssue(issue),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _onTapIssue(IssueModel issue) async {
    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final detailedIssue = await _issueApiService.getIssueById(issue.id);

      print('Hello');

      Navigator.pop(context); // Dismiss the loading indicator

      await Navigator.pushNamed(
        context,
        ChatPage.routeName,
        arguments: detailedIssue,
      );

      // Refresh the issue list after returning to update tabs
      if (mounted) {
        _issueController.refreshIssues();
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load issue details: ${e.toString()}')),
      );
    }
  }

  Future<void> _onLongPressIssue(IssueModel issue) async {
    // Maintenance executive may delete only issues they created/assigned to them
    final currentUserId = AuthService.instance.currentUser?.id;
    final canDelete =
        (currentUserId != null) &&
        ((issue.maintenanceExecutiveId != null &&
                issue.maintenanceExecutiveId == currentUserId) ||
            (issue.maintenanceExecutive?.user != null &&
                issue.maintenanceExecutive!.user!.id == currentUserId));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete issue?'),
        content: const Text('This action will permanently delete the issue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You do not have permission to delete this issue.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    try {
      await _issueController.deleteIssue(issue.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Issue deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete issue: $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
