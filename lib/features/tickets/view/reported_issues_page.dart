import 'package:flutter/material.dart';
import '../model/issue_model.dart';

class ReportedIssuesPage extends StatefulWidget {
  const ReportedIssuesPage({super.key});

  @override
  State<ReportedIssuesPage> createState() => _ReportedIssuesPageState();
}

class _ReportedIssuesPageState extends State<ReportedIssuesPage> {
  bool _showSuccessMessage = true;
  bool _showErrorMessage = false;

  String _getStatusTitle(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return 'Open';
      case IssueStatus.inProgress:
        return 'Ongoing Operations';
      case IssueStatus.done:
        return 'Done';
      case IssueStatus.closed:
        return 'Closed';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} | ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Get the issue passed as argument
    final issue = ModalRoute.of(context)?.settings.arguments as IssueModel?;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reported Issues',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/report-new-issue');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Section Header - Dynamic based on issue status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              issue != null ? _getStatusTitle(issue.status) : 'Ongoing Operations',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Issue Detail Card
                  _buildIssueCard(issue),
                  const SizedBox(height: 16),
                  
                  // Success/Error Messages
                  if (_showSuccessMessage) _buildSuccessMessage(),
                  if (_showErrorMessage) _buildErrorMessage(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildIssueCard(IssueModel? issue) {
    // Use default values if issue is null
    final title = issue?.title ?? 'Oven Operational Failure';
    final description = issue?.description ?? 'During the yesterday evening shift the oven failed to heat. Control panel displayed error code "E12". Quick restart was unsuccessful.';
    final dateTime = issue?.createdAt ?? DateTime.now();
    final formattedDate = _formatDateTime(dateTime);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Criticality Row
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Critical',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Only show edit button if issue is not done
              if (issue?.status != IssueStatus.done && issue?.status != IssueStatus.closed)
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    // Navigate back to edit the issue
                    Navigator.pushNamed(context, '/report-new-issue');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Image placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Icon(Icons.extension, size: 32, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Row - Profile, Attachments, Comments, Views
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 18, color: Colors.grey[700]),
              ),
              const Spacer(),
              _buildIconWithCount(Icons.attach_file, 2),
              const SizedBox(width: 16),
              _buildIconWithCount(Icons.comment, 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithCount(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'New task created successfully',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSuccessMessage = false;
              });
            },
            child: const Icon(Icons.close, size: 18, color: Color(0xFF4FC3F7)), // Blue close icon
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC), // Light pink background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Failed to create new task',
              style: TextStyle(
                color: Color(0xFFD81B60), // Pink-red color for text
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showErrorMessage = false;
              });
            },
            child: const Icon(Icons.close, size: 18, color: Color(0xFF4FC3F7)), // Blue close icon
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4FC3F7),
                Color(0xFF29B6F6),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
