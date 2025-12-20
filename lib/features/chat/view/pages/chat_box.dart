import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/widgets/app_bar.dart';
import 'package:mobile/features/chat/view/widgets/message_bubble.dart';
import 'package:mobile/features/chat/view/widgets/messge_input_field.dart';
import 'package:mobile/features/chat/view/widgets/ticket_bubble.dart';
import 'package:mobile/features/chat/view/widgets/assignment_bubble.dart';
import 'package:mobile/features/user/model/user_role.dart'; // added
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/features/chat/view/widgets/issue_closed_bubble.dart'; // added
import 'package:mobile/features/chat/view/widgets/status_update_bubble.dart'; // added
import 'package:mobile/features/chat/view/widgets/outside_party_suggestion_bubble.dart';
import 'package:mobile/features/chat/view/widgets/petty_cash_request_bubble.dart';
import 'package:mobile/features/tickets/model/issue_model.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile/core/config/api_config.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IssueModel? _issue;
  IO.Socket? _socket;
  final List<MessageModel> _realtimeMessages = [];
  bool _isConnected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_issue == null) {
      final args = ModalRoute.of(context)?.settings.arguments as IssueModel?;
      if (args != null) {
        _issue = args;
        _connectSocket();
        _scrollToBottom();
      }
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _connectSocket() {
    if (_issue == null) return;

    final authService = AuthService.instance;
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    // Construct socket URL
    // ApiConfig.baseUrl is like 'http://10.0.2.2:5050/api/v1'
    // We need 'http://10.0.2.2:5050'
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api/v1', '');
    final namespace = '/issue-${_issue!.id}';
    final socketUrl = '$baseUrl$namespace';

    print('Connecting to socket: $socketUrl');

    _socket = IO.io(socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({
        'userId': currentUser.id.toString(),
        'role': currentUser.role,
      })
      .disableAutoConnect()
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    });

    _socket!.on('receive_message', (data) {
      print('Received message: $data');
      if (data is Map<String, dynamic>) {
        final text = data['text'];
        final senderId = int.tryParse(data['from'].toString()) ?? 0;
        
        // Ignore own messages as they are added optimistically
        if (senderId == AuthService.instance.currentUser?.id) {
          return;
        }
        
        // Find sender name
        String senderName = 'Unknown';
        if (_issue?.manager?.user?.id == senderId) {
          senderName = _issue!.manager!.user!.name;
        } else if (_issue?.technician?.user?.id == senderId) {
          senderName = _issue!.technician!.user!.name;
        } else if (_issue?.maintenanceExecutive?.user?.id == senderId) {
          senderName = _issue!.maintenanceExecutive!.user!.name;
        } else if (AuthService.instance.currentUser?.id == senderId) {
          senderName = AuthService.instance.currentUser!.name;
        }
        
        final newMessage = MessageModel(
           id: DateTime.now().millisecondsSinceEpoch,
           body: text.toString(),
           senderId: senderId,
           createdAt: DateTime.now(),
           sender: UserInfo(id: senderId, name: senderName, email: ''),
           receiverId: null, 
        );
        
        if (mounted) {
          setState(() {
            _realtimeMessages.add(newMessage);
          });
          _scrollToBottom();
        }
      }
    });
    
    _socket!.on('issue_update', (data) {
      print('Received issue update: $data');

      // Handle Petty Cash Update
      if (data is Map<String, dynamic> && data.containsKey('amount') && data.containsKey('technician_id')) {
         if (mounted && _issue != null) {
            try {
              final newRequest = PettyCashRequestModel.fromJson(data);
              final currentRequests = List<PettyCashRequestModel>.from(_issue!.pettyCashRequests ?? []);
              
              final index = currentRequests.indexWhere((r) => r.id == newRequest.id);
              if (index != -1) {
                currentRequests[index] = newRequest;
              } else {
                currentRequests.add(newRequest);
              }
              
              setState(() {
                _issue = _issue!.copyWith(pettyCashRequests: currentRequests);
              });
              _scrollToBottom();
            } catch (e) {
              print('Error parsing petty cash update: $e');
            }
         }
         return;
      }

      if (data is Map<String, dynamic> && data['success'] == true) {
        final updateData = data['data'] as Map<String, dynamic>;
        if (mounted && _issue != null) {
          setState(() {
            _issue = _issue!.copyWith(
              status: updateData['status'] != null 
                  ? IssueStatus.fromString(updateData['status']) 
                  : null,
              maintenanceExecutiveId: updateData['maintenance_executive_id'],
              technicianId: updateData['technician_id'],
              thirdPartyId: updateData['third_party_id'],
              maintenanceExecutiveAssignedAt: updateData['maintenance_executive_assigned_at'] != null
                  ? DateTime.parse(updateData['maintenance_executive_assigned_at'])
                  : null,
              technicianAssignedAt: updateData['technician_assigned_at'] != null
                  ? DateTime.parse(updateData['technician_assigned_at'])
                  : null,
              thirdPartyAssignedAt: updateData['third_party_assigned_at'] != null
                  ? DateTime.parse(updateData['third_party_assigned_at'])
                  : null,
              updatedAt: updateData['updatedAt'] != null
                  ? DateTime.parse(updateData['updatedAt'])
                  : null,
              maintenanceExecutive: updateData['maintenanceExecutive'] != null
                  ? MaintenanceExecutiveInfo.fromJson(updateData['maintenanceExecutive'])
                  : null,
              technician: updateData['technician'] != null
                  ? TechnicianInfo.fromJson(updateData['technician'])
                  : null,
              thirdParty: updateData['thirdParty'] != null
                  ? ThirdPartyInfo.fromJson(updateData['thirdParty'])
                  : null,
            );
          });
          _scrollToBottom();
        }
      }
    });
  }

  void _sendMessage(String text, String? target) {
    if (_issue?.maintenanceExecutive == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send message: No Maintenance Executive accepted.')),
      );
      return;
    }

    if (_socket == null || !_isConnected) {
       print('Not connected');
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Not connected to chat server')),
       );
       return;
    }
    
    final authService = AuthService.instance;
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    String? targetUserId;
    if (target == 'Executive') {
      targetUserId = _issue?.maintenanceExecutive?.user?.id.toString();
    } else if (target == 'GPM') {
      targetUserId = _issue?.technician?.user?.id.toString();
    } else if (target == 'GDM') {
      targetUserId = _issue?.manager?.user?.id.toString();
    }

    final payload = {
      'text': text,
      'from': currentUser.id.toString(),
      if (targetUserId != null) 'to': targetUserId,
    };

    if (targetUserId != null) {
       // Send to specific user room
       _socket!.emit('send_message_to_user', [payload, targetUserId]);
    } else {
       // Fallback to broadcast if no specific target found or implied
       _socket!.emit('send_message_to_all', payload);
    }
    
    // Optimistic update
    UserInfo? receiverInfo;
    if (targetUserId != null) {
      String receiverName = 'Unknown';
      String receiverEmail = '';
      
      if (_issue?.manager?.user?.id.toString() == targetUserId) {
        receiverName = _issue!.manager!.user!.name;
        receiverEmail = _issue!.manager!.user!.email;
      } else if (_issue?.technician?.user?.id.toString() == targetUserId) {
        receiverName = _issue!.technician!.user!.name;
        // technician user might not have email in this model structure if not loaded, but UserInfo requires it.
        // Assuming it's available or empty string.
        receiverEmail = _issue!.technician!.user!.email; 
      } else if (_issue?.maintenanceExecutive?.user?.id.toString() == targetUserId) {
        receiverName = _issue!.maintenanceExecutive!.user!.name;
        receiverEmail = _issue!.maintenanceExecutive!.user!.email;
      }
      
      receiverInfo = UserInfo(
        id: int.parse(targetUserId), 
        name: receiverName, 
        email: receiverEmail
      );
    }

    final newMessage = MessageModel(
       id: DateTime.now().millisecondsSinceEpoch,
       body: text,
       senderId: currentUser.id,
       createdAt: DateTime.now(),
       sender: UserInfo(id: currentUser.id, name: currentUser.name, email: currentUser.email),
       receiverId: targetUserId != null ? int.tryParse(targetUserId) : null,
       receiver: receiverInfo,
    );

    setState(() {
      _realtimeMessages.add(newMessage);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final issue = _issue;
    // ignore: avoid_print
    print('Received issue in ChatPage: ${issue?.toJson()}');

    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No issue data provided.')),
      );
    }



    // Get current user from AuthService
    final authService = AuthService.instance;
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine role
    UserRole? role;
    switch (currentUser.role) {
      case 'technician':
        role = UserRole.technician;
        break;
      case 'branch_manager':
        role = UserRole.branchManager;
        break;
      case 'maintenance_executive':
        role = UserRole.executive;
        break;
    }

    if (role == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authService.clearAuth();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myRole = role;

    // Identify the current user's ID to determine 'isMe'
    String currentUserId = currentUser.id.toString();

    final participants = <String, Map<String, String?>>{};

    // Add current user to participants
    if (currentUser != null) {
      participants['u_${currentUser.id}'] = {
        'name': currentUser.name,
        'avatarUrl': currentUser.profilePicture,
        'userId': currentUser.id.toString(),
      };
    } else if (currentUserId == 'me') {
      // Fallback for test mode
      participants['u_me'] = {
        'name': 'You',
        'avatarUrl': null,
        'userId': 'me'
      };
    }

    // Populate participants from issue data with real profile pictures
    if (issue.manager?.user != null) {
      participants['u_mgr_${issue.manager!.id}'] = {
        'name': issue.manager!.user!.name,
        'avatarUrl': issue.manager!.user!.profilePicture, // Use real profile picture
        'userId': issue.manager!.user!.id.toString(),
      };
    }
    if (issue.technician?.user != null) {
      participants['u_tech_${issue.technician!.id}'] = {
        'name': issue.technician!.user!.name,
        'avatarUrl': issue.technician!.user!.profilePicture, // Use real profile picture
        'userId': issue.technician!.user!.id.toString(),
      };
    }
    if (issue.maintenanceExecutive?.user != null) {
      participants['u_exec_${issue.maintenanceExecutive!.id}'] = {
        'name': issue.maintenanceExecutive!.user!.name,
        'avatarUrl': issue.maintenanceExecutive!.user!.profilePicture, // Use real profile picture
        'userId': issue.maintenanceExecutive!.user!.id.toString(),
      };
    }

    // Combine all items to be displayed in the chat
    final List<Map<String, dynamic>> chatItems = [];

    // Determine severity based on issue status
    final severityInfo = _getSeverityFromStatus(issue.status);

    // Add the main issue ticket
    chatItems.add({
      'type': 'ticket',
      'createdAt': issue.createdAt,
      'title': issue.title,
      'description': issue.description ?? 'No description provided.',
      'branch': issue.branch?.name ?? 'Unknown Branch',
      'timeText':
          '${issue.createdAt.hour}:${issue.createdAt.minute.toString().padLeft(2, '0')} ${issue.createdAt.hour < 12 ? 'AM' : 'PM'}',
      'severity': severityInfo['label'], // Dynamic severity based on status
      'severityColor': severityInfo['color'], // Dynamic color based on status
      'attachments': <String>[], // Empty list - attachments will be populated when file upload is implemented
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
        'title': 'Maintenance Executive Accepted',
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

    if (issue.status == IssueStatus.done || issue.status == IssueStatus.closed) {
      chatItems.add({
        'type': 'issue_closed',
        'createdAt': issue.updatedAt,
        'title': 'Issue Closed',
        'description': 'The issue has been marked as ${issue.status.value}.',
        'timeText':
            '${issue.updatedAt.hour}:${issue.updatedAt.minute.toString().padLeft(2, '0')} ${issue.updatedAt.hour < 12 ? 'AM' : 'PM'}',
        'creatorId': 'u_mgr_${issue.managerId}',
        'alignRight': true,
      });
    }

    // Add messages from the issue AND realtime messages
    final allMessages = [...?issue.messages, ..._realtimeMessages];
    
    for (final message in allMessages) {
        // Filter messages for non-executive roles
        if (myRole != UserRole.executive) {
          final msgSenderId = message.sender.id.toString();
          final msgReceiverId = message.receiver?.id.toString();
          // Only show if I am the sender or the receiver OR if it is a broadcast
          if (msgSenderId != currentUserId && msgReceiverId != currentUserId && msgReceiverId != null) {
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
                controller: _scrollController,
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
                    receiverName: receiver?['name'] ?? 'Everyone',
                    meAvatarUrl: meAvatar,
                    otherAvatarUrl: otherAvatar,
                  );
                },
              ),
            ),
            MessageInputField(
              role: myRole,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to convert backend role string to UserRole enum
  UserRole _getUserRoleFromString(String? role) {
    switch (role) {
      case 'technician':
        return UserRole.technician;
      case 'branch_manager':
        return UserRole.branchManager;
      case 'maintenance_executive':
        return UserRole.executive;
      default:
        return UserRole.executive; // Default fallback
    }
  }

  /// Helper function to get severity info from issue status
  Map<String, dynamic> _getSeverityFromStatus(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return {
          'label': 'Open',
          'color': const Color(0xFFFF7489), // Red/Pink - needs attention
        };
      case IssueStatus.inProgress:
        return {
          'label': 'In Progress',
          'color': const Color(0xFFFFA726), // Orange - being worked on
        };
      case IssueStatus.done:
        return {
          'label': 'Done',
          'color': const Color(0xFF66BB6A), // Green - completed
        };
      case IssueStatus.closed:
        return {
          'label': 'Closed',
          'color': const Color(0xFF78909C), // Grey - closed
        };
    }
  }
}
