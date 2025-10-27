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

  @override
  void initState() {
    super.initState();
    _issueController.refreshIssues();
  }

  // Don't dispose singleton controller
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

          // Filter Tabs
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListenableBuilder(
              listenable: _issueController,
              builder: (context, _) {
                return Row(
                  children: [
                    StatusFilterChip(
                      label: 'Open',
                      isSelected:
                          _issueController.selectedFilter == IssueStatus.open,
                      onTap: () {
                        setState(() {
                          _issueController.setFilter(IssueStatus.open);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    StatusFilterChip(
                      label: 'In Progress',
                      isSelected:
                          _issueController.selectedFilter ==
                          IssueStatus.inProgress,
                      onTap: () {
                        setState(() {
                          _issueController.setFilter(IssueStatus.inProgress);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    StatusFilterChip(
                      label: 'Done',
                      isSelected:
                          _issueController.selectedFilter == IssueStatus.done,
                      onTap: () {
                        setState(() {
                          _issueController.setFilter(IssueStatus.done);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Issues List
          Expanded(
            child: ListenableBuilder(
              listenable: _issueController,
              builder: (context, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildFilteredIssueList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(
        showAddButton: false, // Technician has NO plus button
      ),
    );
  }

  Widget _buildFilteredIssueList() {
    final filteredIssues = _issueController.filteredIssues;

    if (filteredIssues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                'No issues found',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredIssues.map((issue) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IssueCard(
            issue: issue,
            showCriticalBell: true, // Technician sees critical bell
            criticality: 'Critical', // Placeholder - will be from API
          ),
        );
      }).toList(),
    );
  }
}
