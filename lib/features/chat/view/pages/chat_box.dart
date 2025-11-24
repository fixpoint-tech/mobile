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

    // Assume this comes from saved login details.
    final myRole = UserRole.executive;

    // Identify the current user's ID to determine 'isMe'
    // In a real app, this ID would come from your AuthProvider/UserSession
    String? currentUserId;
    if (myRole == UserRole.technician) {
      currentUserId = issue.technician?.user?.id.toString();
    } else if (myRole == UserRole.branchManager) {
      currentUserId = issue.manager?.user?.id.toString();
    } else if (myRole == UserRole.executive) {
      currentUserId = issue.maintenanceExecutive?.user?.id.toString();
    }
    // Fallback if not found (e.g. testing or user not assigned yet)
    currentUserId ??= 'me';

    final participants = <String, Map<String, String?>>{};

    // If we are in a test mode where ID is 'me', add the placeholder
    if (currentUserId == 'me') {
      participants['u_me'] = {
        'name': 'You',
        'avatarUrl': 'https://i.pravatar.cc/100?img=3',
        'userId': 'me'
      };
    }

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
      'createdAt': issue.createdAt,
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
        'createdAt': issue.technicianAssignedAt,
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
        'createdAt': issue.maintenanceExecutiveAssignedAt,
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
        'createdAt': issue.thirdPartyAssignedAt,
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
        // Filter messages for non-executive roles
        if (myRole != UserRole.executive) {
          final msgSenderId = message.sender.id.toString();
          final msgReceiverId = message.receiver?.id.toString();
          // Only show if I am the sender or the receiver
          if (msgSenderId != currentUserId && msgReceiverId != currentUserId) {
            continue;
          }
        }

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
          'createdAt': message.createdAt,
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
          'createdAt': request.createdAt,
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

    // Sort items by time
    chatItems.sort((a, b) {
      final dateA = a['createdAt'] as DateTime?;
      final dateB = b['createdAt'] as DateTime?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return -1;
      if (dateB == null) return 1;
      return dateA.compareTo(dateB);
    });

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

                  final senderIdKey = it['senderId'] as String;
                  final receiverIdKey = it['receiverId'] as String?;

                  // Check if the sender is the current logged-in user
                  final senderData = participants[senderIdKey];
                  final senderUserId = senderData?['userId'];
                  final isMe = senderUserId == currentUserId;

                  final sender = participants[senderIdKey];
                  final receiver =
                      receiverIdKey != null ? participants[receiverIdKey] : null;

                  // Determine whose avatar to show (the other person)
                  final otherIdKey = isMe ? receiverIdKey : senderIdKey;
                  final otherAvatar = otherIdKey != null &&
                          participants[otherIdKey] != null
                      ? participants[otherIdKey]!['avatarUrl']
                      : null;

                  // For "me" avatar, we try to find our own entry
                  // (though MessageBubble usually doesn't show my avatar, just my text on right)
                  final meEntry = participants.entries
                      .where((e) => e.value['userId'] == currentUserId)
                      .firstOrNull;
                  final meAvatar = meEntry?.value['avatarUrl'];

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
