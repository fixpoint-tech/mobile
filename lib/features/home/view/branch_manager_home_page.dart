import 'package:flutter/material.dart';
import '../../tickets/controller/issue_controller.dart';
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
  // int _selectedNavIndex = 0; // Commented out since nav items are commented

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
                        Text(
                          'Recent Issues',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips
                        Row(
                          children: [
                            StatusFilterChip(
                              label: 'Open',
                              isSelected:
                                  _issueController.selectedFilter ==
                                  IssueStatus.open,
                              onTap: () =>
                                  _issueController.setFilter(IssueStatus.open),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'In Progress',
                              isSelected:
                                  _issueController.selectedFilter ==
                                  IssueStatus.inProgress,
                              onTap: () => _issueController.setFilter(
                                IssueStatus.inProgress,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusFilterChip(
                              label: 'Done',
                              isSelected:
                                  _issueController.selectedFilter ==
                                  IssueStatus.done,
                              onTap: () =>
                                  _issueController.setFilter(IssueStatus.done),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Issue List based on filter
                        _buildFilteredIssueList(),
                      ],
                    ),
                  ),
                );
              },
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
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
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
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppColors.white),
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
            style: TextStyle(color: AppColors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to report issue page
              Navigator.pushNamed(context, '/report-new-issue');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: const Color(0xFF4FC3F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildFilteredIssueList() {
    final filteredIssues = _issueController.filteredIssues;

    if (filteredIssues.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No issues found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    // All issues use the same IssueCard widget
    // Show critical bell icon only for "Open" issues with "Critical" status
    return Column(
      children: filteredIssues.map((issue) {
        final isOpenAndCritical =
            _issueController.selectedFilter == IssueStatus.open;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IssueCard(
            issue: issue,
            showCriticalBell: isOpenAndCritical,
            criticality: isOpenAndCritical ? 'Critical' : 'General',
          ),
        );
      }).toList(),
    );
  }
}
