import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 17.42,
            color: AppColors.textTitle,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 29,
            color: AppColors.textTitle,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _FAQItem(
            question: 'How do I report a new maintenance issue?',
            answer:
                'Tap the blue + button at the bottom center of your home screen. Fill in the issue details including title, description, priority level, and affected location. Submit the form to create the issue.',
          ),
          _FAQItem(
            question: 'How do I track the status of my reported issues?',
            answer:
                'All your reported issues are visible on the home dashboard. Use the status filter chips (Open, In Progress, Done) to view issues in different stages. Tap on any issue to see detailed progress and communications.',
          ),
          _FAQItem(
            question: 'Can I assign issues to specific technicians?',
            answer:
                'Yes, Maintenance Executives can assign issues to technicians when creating or editing an issue. The assigned technician will receive a notification and can view the issue in their dashboard.',
          ),
          _FAQItem(
            question: 'How do I communicate about an issue?',
            answer:
                'Tap on any issue card to open the chat interface. Here you can send messages, share updates, and communicate with all personnel involved in resolving the issue.',
          ),
          _FAQItem(
            question: 'What do the priority levels mean?',
            answer:
                'Critical: Immediate attention required, affects operations. High: Important, should be addressed within 24 hours. Medium: Normal priority, address within 2-3 days. Low: Minor issues, can be scheduled.',
          ),
          _FAQItem(
            question: 'How do I update my profile information?',
            answer:
                'Tap your profile icon, then tap the Edit Profile button. You can update your name, contact details, and profile picture. Don\'t forget to save your changes.',
          ),
          _FAQItem(
            question: 'Who can I contact for technical support?',
            answer:
                'Use the Contact Support option in Help & Support to reach our technical team. You can also email support@fixpoint.lk or call our hotline at +94 11 234 5678.',
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textTitle,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.secondary,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
