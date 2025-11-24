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
import 'package:mobile/features/tickets/model/issue_model.dart';

class ChatPage extends StatelessWidget {
  static const String routeName = '/chat';
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final issue = ModalRoute.of(context)?.settings.arguments as IssueModel?;
    // ignore: avoid_print
    print('Received issue in ChatPage: ${issue?.toJson()}');

    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No issue data provided.')),
      );
    }

    const meAvatarUrl = 'https://i.pravatar.cc/100?img=3';
    const meId = 'u_me';

    // Assume this comes from saved login details.
    final myRole = UserRole.executive;

    final participants = <String, Map<String, String?>>{
      meId: {'name': 'You', 'avatarUrl': meAvatarUrl, 'userId': 'me'},
    };

    // Populate participants from issue data
    if (issue.manager?.user != null) {
      participants['u_mgr_${issue.manager!.id}'] = {
        'name': issue.manager!.user!.name,
        'avatarUrl': 'https://i.pravatar.cc/100?img=5', // Placeholder
        'userId': issue.manager!.user!.id.toString(),
      };
    }
    if (issue.technician?.user != null) {
      participants['u_tech_${issue.technician!.id}'] = {
        'name': issue.technician!.user!.name,
        'avatarUrl': 'https://i.pravatar.cc/100?img=8', // Placeholder
        'userId': issue.technician!.user!.id.toString(),
      };
    }
    if (issue.maintenanceExecutive?.user != null) {
      participants['u_exec_${issue.maintenanceExecutive!.id}'] = {
        'name': issue.maintenanceExecutive!.user!.name,
        'avatarUrl': 'https://i.pravatar.cc/100?img=3', // Placeholder
        'userId': issue.maintenanceExecutive!.user!.id.toString(),
      };
    }

    // Combine all items to be displayed in the chat
    final List<Map<String, dynamic>> chatItems = [];

    // Add the main issue ticket
    chatItems.add({
      'type': 'ticket',
      'title': issue.title,
      'description': issue.description ?? 'No description provided.',
      'branch': issue.branch?.name ?? 'Unknown Branch',
      'timeText':
          '${issue.createdAt.hour}:${issue.createdAt.minute.toString().padLeft(2, '0')} ${issue.createdAt.hour < 12 ? 'AM' : 'PM'}',
      'severity': 'Critical', // This seems to be hardcoded, leaving as is.
      'severityColor': const Color(0xFFFF7489),
      'attachments': <String>['', 'https://picsum.photos/200/200?random=1'],
      'creatorId': 'u_mgr_${issue.managerId}',
      'occurrenceTimeText':
          '${issue.createdAt.hour}:${issue.createdAt.minute.toString().padLeft(2, '0')} ${issue.createdAt.hour < 12 ? 'AM' : 'PM'}',
    });

    // Add assignment events (technician, maintenance executive, third party)
    if (issue.technicianAssignedAt != null) {
      chatItems.add({
        'type': 'assignment',
        'title': 'Technician Assigned',
        'technicianName': issue.technician?.user?.name ?? 'Technician',
        'timeText':
            '${issue.technicianAssignedAt!.hour}:${issue.technicianAssignedAt!.minute.toString().padLeft(2, '0')} ${issue.technicianAssignedAt!.hour < 12 ? 'AM' : 'PM'}',
  'creatorId': 'u_mgr_${issue.managerId}',
        'alignRight': false,
      });
    }

    if (issue.maintenanceExecutiveAssignedAt != null) {
      chatItems.add({
        'type': 'assignment',
        'title': 'Maintenance Executive Assigned',
        'technicianName': issue.maintenanceExecutive?.user?.name ?? 'Maintenance Executive',
        'timeText':
            '${issue.maintenanceExecutiveAssignedAt!.hour}:${issue.maintenanceExecutiveAssignedAt!.minute.toString().padLeft(2, '0')} ${issue.maintenanceExecutiveAssignedAt!.hour < 12 ? 'AM' : 'PM'}',
  'creatorId': 'u_mgr_${issue.managerId}',
        'alignRight': false,
      });
    }

    if (issue.thirdPartyAssignedAt != null) {
      chatItems.add({
        'type': 'assignment',
        'title': 'Third Party Assigned',
        'technicianName': issue.thirdParty?.organization ?? 'Third Party',
        'timeText':
            '${issue.thirdPartyAssignedAt!.hour}:${issue.thirdPartyAssignedAt!.minute.toString().padLeft(2, '0')} ${issue.thirdPartyAssignedAt!.hour < 12 ? 'AM' : 'PM'}',
  'creatorId': 'u_mgr_${issue.managerId}',
        'alignRight': false,
      });
    }

    // Add messages from the issue
    if (issue.messages != null) {
      for (final message in issue.messages!) {
        // Find or create participant key for sender
        final senderIdStr = message.sender.id.toString();
        final senderKey = participants.keys.firstWhere(
          (k) => participants[k]?['userId'] == senderIdStr,
          orElse: () {
            final k = 'u_${senderIdStr}';
            participants[k] = {
              'name': message.sender.name,
              'avatarUrl': null,
              'userId': senderIdStr,
            };
            return k;
          },
        );

        String? receiverKey;
        if (message.receiver != null) {
          final receiverIdStr = message.receiver!.id.toString();
          receiverKey = participants.keys.firstWhere(
            (k) => participants[k]?['userId'] == receiverIdStr,
            orElse: () {
              final k = 'u_${receiverIdStr}';
              participants[k] = {
                'name': message.receiver!.name,
                'avatarUrl': null,
                'userId': receiverIdStr,
              };
              return k;
            },
          );
        }

        chatItems.add({
          'type': 'text',
          'text': message.body,
          'time':
              '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')} ${message.createdAt.hour < 12 ? 'AM' : 'PM'}',
          'senderId': senderKey,
          'receiverId': receiverKey,
        });
      }
    }

    // Add petty cash requests
    if (issue.pettyCashRequests != null) {
      for (final request in issue.pettyCashRequests!) {
        chatItems.add({
          'type': 'petty_cash',
          'amount': 'Rs. ${request.amount}',
          'timeText':
              '${request.createdAt.hour}:${request.createdAt.minute.toString().padLeft(2, '0')} ${request.createdAt.hour < 12 ? 'AM' : 'PM'}',
          'creatorId': 'u_tech_${request.technicianId}',
          'description': request.description,
          'status': request.status,
          'alignRight': false,
        });
      }
    }

    // Sort items by time - assuming all have a 'time' or 'timeText' like field
    // This part is tricky because the data models are different.
    // For now, we'll just display them in the order they are added.

    final managerKey = 'u_mgr_${issue.managerId}';
    final managerAvatar = participants[managerKey]?['avatarUrl'];

    return Scaffold(
      appBar: CustomChatAppBar(
        title: issue.title,
        branchName: issue.branch?.name,
        branchLocation: issue.branch?.location,
        avatarUrl: managerAvatar,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: chatItems.length,
                itemBuilder: (context, i) {
                  final it = chatItems[i];

                  if (it['type'] == 'assignment') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final creatorName =
                        creator != null ? creator['name'] : null;
                    final alignRight = (it['alignRight'] as bool?) ?? true;

                    return AssignmentBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      title: it['title'] as String,
                      technicianName: it['technicianName'] as String,
                      timeText: it['timeText'] as String,
                      alignRight: alignRight,
                      onTap: () {},
                    );
                  }

                  if (it['type'] == 'ticket') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final creatorName =
                        creator != null ? creator['name'] : null;

                    return TicketBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      title: it['title'] as String,
                      description: it['description'] as String,
                      branch: it['branch'] as String,
                      timeText: it['timeText'] as String,
                      severityLabel: it['severity'] as String,
                      severityColor: it['severityColor'] as Color,
                      attachments: (it['attachments'] as List<String>?) ?? [],
                      occurrenceTimeText: it['occurrenceTimeText'] as String?,
                      onTap: () {},
                    );
                  }

                  if (it['type'] == 'status_update') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final creatorName =
                        creator != null ? creator['name'] : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return StatusUpdateBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      description: it['description'] as String,
                      timeText: it['timeText'] as String,
                      attachments: (it['attachments'] as List<String>?) ?? [],
                      alignRight: alignRight,
                    );
                  }

                  if (it['type'] == 'issue_closed') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final creatorName =
                        creator != null ? creator['name'] : null;
                    final alignRight = (it['alignRight'] as bool?) ?? true;

                    return IssueClosedBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      title: it['title'] as String,
                      description: it['description'] as String,
                      timeText: it['timeText'] as String,
                      alignRight: alignRight,
                      onTap: () {},
                    );
                  }

                  if (it['type'] == 'outside_party') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return OutsidePartySuggestionBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      partyName: it['partyName'] as String,
                      suggestedTime: it['timeText'] as String,
                      alignRight: alignRight,
                    );
                  }

                  if (it['type'] == 'petty_cash') {
                    final creatorId = it['creatorId'] as String?;
                    final creator =
                        creatorId != null ? participants[creatorId] : null;
                    final creatorAvatarUrl =
                        creator != null ? creator['avatarUrl'] : null;
                    final creatorName =
                        creator != null ? creator['name'] : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;

                    return PettyCashRequestBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      amountLabel: it['amount'] as String,
                      timeText: it['timeText'] as String,
                      description: it['description'] as String?,
                      status: it['status'] as String?,
                      alignRight: alignRight,
                      onClose: () {},
                      onAccept: () {},
                      onRequestCash: () {},
                    );
                  }

                  final isMe = it['senderId'] == meId;
                  final sender = participants[it['senderId']];
                  final receiver = participants[it['receiverId']];
                  final meAvatar = participants[meId]!['avatarUrl'];
                  final otherId = isMe
                      ? it['receiverId'] as String
                      : it['senderId'] as String;
                  final otherAvatar =
                      participants[otherId] != null ? participants[otherId]!['avatarUrl'] : null;

                  return MessageBubble(
                    isMe: isMe,
                    text: it['text'] as String,
                    time: it['time'] as String,
                    senderName: sender?['name'] ?? 'Unknown',
                    receiverName: receiver?['name'] ?? 'Unknown',
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
