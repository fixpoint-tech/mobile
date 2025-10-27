import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/widgets/app_bar.dart';
import 'package:mobile/features/chat/view/widgets/message_bubble.dart';
import 'package:mobile/features/chat/view/widgets/messge_input_field.dart';
import 'package:mobile/features/chat/view/widgets/ticket_bubble.dart';
import 'package:mobile/features/chat/view/widgets/assignment_bubble.dart';
import 'package:mobile/features/user/model/user_role.dart'; // added
import 'package:mobile/features/chat/view/widgets/issue_closed_bubble.dart'; // added
import 'package:mobile/features/chat/view/widgets/status_update_bubble.dart'; // added
import 'package:mobile/features/chat/view/widgets/outside_party_suggestion_bubble.dart';
import 'package:mobile/features/chat/view/widgets/petty_cash_request_bubble.dart';

class ChatPage extends StatelessWidget {
  static const String routeName = '/chat';
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    const meAvatarUrl = 'https://i.pravatar.cc/100?img=3';
    const meId = 'u_me';

    // Assume this comes from saved login details.
    final myRole = UserRole
        .executive; // GDM | UserRole.technician (GPM) | UserRole.executive

    final participants = <String, Map<String, String?>>{
      meId: {'name': 'You', 'avatarUrl': meAvatarUrl},
      'u_mgr': {
        'name': 'Branch Manager',
        'avatarUrl': 'https://i.pravatar.cc/100?img=5',
      },
      'u_tech': {
        'name': 'Technician',
        'avatarUrl': 'https://i.pravatar.cc/100?img=8',
      },
    };

    // Mixed chat items: message, ticket, or assignment.
    final items = [
      {
        'type': 'ticket',
        'title': 'Pizza Oven Malfunction',
        'description': 'Main oven not heating properly & affecting production',
        'branch': 'Kottawa Branch',
        'timeText': '8:58 AM', // creation/submission time (below the box)
        'severity': 'Critical',
        'severityColor': const Color(0xFFFF7489),
        'attachments': <String>['', 'https://picsum.photos/200/200?random=1'],
        'creatorId': 'u_mgr',
        'occurrenceTimeText':
            '8:00 AM', // NEW: issue occurrence time (inside the box)
      },
      {
        'type': 'assignment',
        'title': 'Assigned a GPM',
        'technicianName': 'Malika Sandaruwan', // variable
        'timeText': '8:09 AM', // variable
        'creatorId': 'u_mgr', // who performed the assignment
        'alignRight': true, // to match the screenshot layout
      },
      {
        'type': 'status_update', // new
        'description': 'Needs replacement to restore functionality.',
        'timeText': '9:50 AM',
        'attachments': <String>[
          '', // empty slot example
          'https://picsum.photos/seed/gear/200/200',
          'https://picsum.photos/seed/part/200/200',
        ],
        'creatorId': 'u_tech',
        'alignRight': false,
      },
      {
        'type': 'issue_closed',
        'title': 'Issue Closed',
        'description': 'Issue closing description goes here',
        'timeText': '8:09 AM',
        'creatorId': 'u_mgr',
        'alignRight': true,
      },
      {
        'type': 'text',
        'text': 'Hi!',
        'time': '8:57 AM',
        'senderId': meId,
        'receiverId': 'u_mgr',
      },
      {
        'type': 'text',
        'text': 'Okay, Thanks!',
        'time': '8:55 AM',
        'senderId': 'u_mgr',
        'receiverId': meId,
      },
      {
        'type': 'outside_party',
        'partyName': 'Oven Builders PVT Ltd.',
        'timeText': '9:50 AM',
        'creatorId': 'u_mgr',
        'alignRight': false,
      },
      {
        'type': 'petty_cash',
        'amount': 'Rs. 6500.00',
        'timeText': '9:50 AM',
        'creatorId': 'u_mgr',
        'alignRight': false,
      },
    ];

    return Scaffold(
      appBar: const CustomChatAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final it = items[i];

                  if (it['type'] == 'assignment') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl']
                        : null;
                    final creatorName = creator != null
                        ? creator['name']
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? true;

                    return AssignmentBubble(
                      title: it['title'] as String,
                      technicianName: it['technicianName'] as String,
                      timeText: it['timeText'] as String,
                      alignRight: alignRight,
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName,
                      onTap: () {
                        // TODO: navigate to assignment details if needed
                      },
                    );
                  }

                  if (it['type'] == 'ticket') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl']
                        : null;
                    final creatorName = creator != null
                        ? creator['name']
                        : null;

                    return TicketBubble(
                      title: it['title'] as String,
                      description: it['description'] as String,
                      branch: it['branch'] as String,
                      timeText:
                          it['timeText']
                              as String, // creation/submission time (below)
                      severityLabel: it['severity'] as String,
                      severityColor:
                          (it['severityColor'] as Color?) ??
                          const Color(0xFFFF7489),
                      attachments:
                          (it['attachments'] as List<String>? ?? const []),
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName,
                      occurrenceTimeText:
                          it['occurrenceTimeText'] as String?, // inside (blue)
                      onTap: () {
                        // TODO: open ticket details
                      },
                    );
                  }

                  if (it['type'] == 'status_update') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl']
                        : null;
                    final creatorName = creator != null
                        ? creator['name']
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return StatusUpdateBubble(
                      description: it['description'] as String,
                      timeText: it['timeText'] as String?,
                      attachments:
                          (it['attachments'] as List<String>? ?? const []),
                      creatorAvatarUrl: creatorAvatarUrl,
                      alignRight: alignRight,
                      creatorName: creatorName,
                    );
                  }

                  if (it['type'] == 'issue_closed') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl']
                        : null;
                    final creatorName = creator != null
                        ? creator['name']
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? true;

                    return IssueClosedBubble(
                      title: it['title'] as String? ?? 'Issue Closed',
                      description:
                          it['description'] as String? ?? 'No description',
                      timeText: it['timeText'] as String? ?? '',
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName,
                      alignRight: alignRight,
                      onTap: () {
                        // TODO: open issue details if needed
                      },
                    );
                  }

                  if (it['type'] == 'outside_party') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return OutsidePartySuggestionBubble(
                      partyName:
                          it['partyName']
                              as String, // e.g. "Oven Builders PVT Ltd."
                      suggestedTime: it['timeText'] as String, // e.g. "9:50 AM"
                      alignRight: alignRight,
                      creatorAvatarUrl: creator?['avatarUrl'],
                    );
                  }

                  if (it['type'] == 'petty_cash') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return PettyCashRequestBubble(
                      amountLabel: it['amount'] as String,
                      timeText: it['timeText'] as String,
                      alignRight: alignRight,
                      creatorAvatarUrl: creator?['avatarUrl'],
                      onClose: () {},
                      onAccept: () {},
                      onRequestCash: () {},
                    );
                  }

                  final isMe = it['senderId'] == meId;
                  final sender = participants[it['senderId']]!;
                  final receiver = participants[it['receiverId']]!;
                  final meAvatar = participants[meId]!['avatarUrl'];
                  final otherId = isMe
                      ? it['receiverId'] as String
                      : it['senderId'] as String;
                  final otherAvatar = participants[otherId]!['avatarUrl'];

                  return MessageBubble(
                    text: it['text'] as String,
                    isMe: isMe,
                    time: it['time'] as String,
                    senderName: sender['name']!,
                    receiverName: receiver['name']!,
                    meAvatarUrl: meAvatar,
                    otherAvatarUrl: otherAvatar,
                  );
                },
              ),
            ),
            MessageInputField(role: myRole),
          ],
        ),
      ),
    );
  }
}
