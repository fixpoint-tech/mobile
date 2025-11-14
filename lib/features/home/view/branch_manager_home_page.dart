import 'package:flutter/material.dart';
import '../../tickets/controller/issue_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../tickets/model/issue_model.dart';
import '../../../shared/widgets/user_header.dart';
import '../../../shared/widgets/status_filter_chip.dart';
import '../../../shared/widgets/issue_card.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../../../theme/app_colors.dart';

class BranchManagerHomePage extends StatefulWidget {
  const BranchManagerHomePage({super.key});

  @override
  State<BranchManagerHomePage> createState() => _BranchManagerHomePageState();
}

class _BranchManagerHomePageState extends State<BranchManagerHomePage> {
  final IssueController _issueController = IssueController();
  final PageController _pageController = PageController(initialPage: 1); // Start at In Progress
  int _currentPageIndex = 1;
  // int _selectedNavIndex = 0; // Commented out since nav items are commented

  @override
  void initState() {
    super.initState();
    _issueController.setFilter(IssueStatus.inProgress); // Start at In Progress
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
        toolbarHeight: 0, // Remove the app bar title area
      ),
      body: Column(
        children: [
          // User Header
          const UserHeader(
            userName: 'Nuwan Fernando',
            userRole: 'Branch Manager - Kollupitiya',
          ),
          const SizedBox(height: 8),

          // Main Content
          Expanded(
            child: ListenableBuilder(
              listenable: _issueController,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Report Issue Card
                        _buildReportIssueCard(),
                        const SizedBox(height: 24),
                        
                        // Recent Issues Title
                        const Text(
                          'Recent Issues',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Filter Chips (tap to jump to page OR swipe pages)
                        Row(
                          children: [
                            StatusFilterChip(
                              label: 'Open',
                              isSelected: _currentPageIndex == 0,
                              onTap: () {
                                _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              },
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'In Progress',
                              isSelected: _currentPageIndex == 1,
                              onTap: () {
                                _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              },
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Done',
                              isSelected: _currentPageIndex == 2,
                              onTap: () {
                                _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Swipeable PageView for the 3 status sections
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                  final statuses = [IssueStatus.open, IssueStatus.inProgress, IssueStatus.done];
                  _issueController.setFilter(statuses[index]);
                });
              },
              children: [
                // Page 1: Open Issues
                _buildIssueListPage(IssueStatus.open),
                // Page 2: In Progress Issues
                _buildIssueListPage(IssueStatus.inProgress),
                // Page 3: Done Issues
                _buildIssueListPage(IssueStatus.done),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: CustomBottomNavigation(
        showAddButton: true,
        onAddTap: () {
          Navigator.pushNamed(context, '/report-new-issue');
        },
      ),
    );
  }

  Widget _buildReportIssueCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4FC3F7),
            Color(0xFF29B6F6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Found a problem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Show menu options
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Report the maintenance need\nhere.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to report issue page
              Navigator.pushNamed(context, '/report-new-issue');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4FC3F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18),
                SizedBox(width: 4),
                Text('Report Issue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueListPage(IssueStatus status) {
    return ListenableBuilder(
      listenable: _issueController,
      builder: (context, _) {
        final issues = _issueController.issues.where((issue) => issue.status == status).toList();
        
        if (issues.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${status.value.toLowerCase()} issues',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
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
              final isOpenAndCritical = status == IssueStatus.open;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onLongPress: () => _onLongPressIssue(issue),
                  child: IssueCard(
                    issue: issue,
                    showCriticalBell: isOpenAndCritical,
                    criticality: isOpenAndCritical ? 'Critical' : 'General',
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _onLongPressIssue(IssueModel issue) async {
    // Branch Manager may delete only issues they created (managerId)
  final currentUserId = AuthService.instance.currentUser?.id;
  final canDelete = (currentUserId != null && issue.managerId == currentUserId);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete issue?'),
        content: const Text('This action will permanently delete the issue.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You do not have permission to delete this issue.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    try {
      await _issueController.deleteIssue(issue.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete issue: $e'), backgroundColor: AppColors.primary),
      );
    }
  }
}
