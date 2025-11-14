import 'package:flutter/material.dart';
import '../../tickets/controller/issue_controller.dart';
import '../../tickets/model/issue_model.dart';
import '../../../shared/widgets/user_header.dart';
import '../../../shared/widgets/status_filter_chip.dart';
import '../../../shared/widgets/issue_card.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../../../theme/app_colors.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  final IssueController _issueController = IssueController();
  final PageController _pageController = PageController(initialPage: 1);
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
          UserHeader(
            userName: 'John Doe',
            userRole: 'Technician',
            onNotificationTap: () {
              // Handle notifications
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
                _buildIssueListPage(IssueStatus.open),
                _buildIssueListPage(IssueStatus.inProgress),
                _buildIssueListPage(IssueStatus.done),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(
        showAddButton: false, // Technician has NO plus button
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
                child: IssueCard(
                  issue: issue,
                  showCriticalBell: true,
                  criticality: 'Critical',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
