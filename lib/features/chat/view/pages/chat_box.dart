import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/widgets/app_bar.dart';
import 'package:mobile/features/chat/view/widgets/message_bubble.dart';
import 'package:mobile/features/chat/view/widgets/messge_input_field.dart';
import 'package:mobile/features/chat/view/widgets/ticket_bubble.dart';
import 'package:mobile/features/chat/view/widgets/assignment_bubble.dart';
import 'package:mobile/features/chat/view/widgets/action_dialogs.dart';
import 'package:mobile/features/user/model/user_role.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/upload_service.dart';
import 'package:mobile/features/chat/view/widgets/issue_closed_bubble.dart';
import 'package:mobile/features/chat/view/widgets/status_update_bubble.dart';
import 'package:mobile/features/chat/view/widgets/outside_party_suggestion_bubble.dart';
import 'package:mobile/features/chat/view/widgets/petty_cash_request_bubble.dart';
import 'package:mobile/features/chat/view/widgets/pending_approval_bubble.dart';
import 'package:mobile/features/tickets/model/issue_model.dart';
import 'package:mobile/features/tickets/service/issue_api_service.dart';
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
  // IDs of status entries added optimistically (API-returned) but not yet committed
  // to _issue.statuses via setState. Used to suppress duplicate socket events.
  final Set<int> _pendingStatusIds = {};
  final ScrollController _scrollController = ScrollController();
  final IssueApiService _issueApiService = IssueApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_issue == null) {
      final args = ModalRoute.of(context)?.settings.arguments as IssueModel?;
      if (args != null) {
        _issue = args;
        _connectSocket();
        _scrollToBottom();
        _refreshIssue(args.id);
      }
    }
  }

  Future<void> _refreshIssue(int issueId) async {
    try {
      final fresh = await _issueApiService.getIssueById(issueId);
      if (mounted) setState(() { _issue = fresh; });
    } catch (_) {}
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

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({
            'userId': currentUser.id.toString(),
            'role': currentUser.role,
          })
          .disableAutoConnect()
          .build(),
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

      if (data is Map<String, dynamic>) {
        // Handle Petty Cash Update
        if (data.containsKey('amount') && data.containsKey('technician_id')) {
          if (mounted && _issue != null) {
            try {
              final newRequest = PettyCashRequestModel.fromJson(data);
              final currentRequests = List<PettyCashRequestModel>.from(
                _issue!.pettyCashRequests ?? [],
              );

              final index = currentRequests.indexWhere(
                (r) => r.id == newRequest.id,
              );
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

        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          _applyIssueUpdateFields(data['data'] as Map<String, dynamic>);
          return;
        }

        if (data.containsKey('status') ||
            data.containsKey('technician_id') ||
            data.containsKey('maintenance_executive_id') ||
            data.containsKey('third_party_id')) {
          _applyIssueUpdateFields(data);
        }
      }
    });

    // ── Outside party update listener ──
    _socket!.on('outside_party_update', (data) {
      print('Outside party update: $data');
      if (data is Map<String, dynamic> && mounted && _issue != null) {
        try {
          final newReq = OutsidePartyRequestModel.fromJson(data);
          final current = List<OutsidePartyRequestModel>.from(
            _issue!.outsidePartyRequests ?? [],
          );
          final idx = current.indexWhere((r) => r.id == newReq.id);
          if (idx != -1) {
            current[idx] = newReq;
          } else {
            current.add(newReq);
          }
          setState(() {
            _issue = _issue!.copyWith(outsidePartyRequests: current);
          });
          _scrollToBottom();
        } catch (e) {
          print('Error parsing outside_party_update: $e');
        }
      }
    });

    // ── issue_update_fields: legacy event name ──
    _socket!.on('issue_update_fields', (data) {
      if (data is Map<String, dynamic> && data['success'] == true) {
        final updateData = data['data'] as Map<String, dynamic>;
        _applyIssueUpdateFields(updateData);
      }
    });

    // ── status_update_log: real-time status update bubbles ──
    _socket!.on('status_update_log', (data) {
      if (data is Map<String, dynamic> && mounted && _issue != null) {
        try {
          final newStatusEntry = StatusModel.fromJson(data);

          // Skip if this exact ID was already added optimistically by the current user
          if (_pendingStatusIds.contains(newStatusEntry.id)) {
            _pendingStatusIds.remove(newStatusEntry.id);
            return;
          }

          // Also suppress if we are mid-await for our own addStatusUpdate call.
          // Sentinel negative IDs (-1, -2, -3) are placed in _pendingStatusIds
          // before the await and removed once we have the real ID.
          // The local setState will render the bubble; we don't need the socket event.
          if (_pendingStatusIds.any((id) => id < 0)) {
            return;
          }

          // Avoid duplicating if already present in the list
          final currentStatuses = List<StatusModel>.from(
            _issue!.statuses ?? [],
          );
          final exists = currentStatuses.any((s) => s.id == newStatusEntry.id);

          if (!exists) {
            currentStatuses.add(newStatusEntry);
            setState(() {
              _issue = _issue!.copyWith(statuses: currentStatuses);
            });
            _scrollToBottom();
          }
        } catch (e) {
          print('Error parsing status_update_log: $e');
        }
      }
    });
  }

  void _applyIssueUpdateFields(Map<String, dynamic> updateData) {
    if (!mounted || _issue == null) return;

    setState(() {
      _issue = _issue!.copyWith(
        status: updateData['status'] != null
            ? IssueStatus.fromString(updateData['status'])
            : null,
        maintenanceExecutiveId: updateData['maintenance_executive_id'],
        technicianId: updateData['technician_id'],
        thirdPartyId: updateData['third_party_id'],
        maintenanceExecutiveAssignedAt:
            updateData['maintenance_executive_assigned_at'] != null
            ? DateTime.parse(
                updateData['maintenance_executive_assigned_at'],
              )
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
            ? MaintenanceExecutiveInfo.fromJson(
                updateData['maintenanceExecutive'],
              )
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

  void _sendMessage(String text, String? target) {
    if (_issue?.maintenanceExecutive == null) {
      final authService = AuthService.instance;
      final currentUser = authService.currentUser;
      if (currentUser?.role == 'maintenance_executive') {
        final meProfileId = currentUser?.maintenanceExecutiveProfileId;
        if (meProfileId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find your Maintenance Executive profile. Please log out and log back in.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        showAcceptRejectIssueDialog(
          context,
          onAccept: () async {
            try {
              _showLoadingDialog('Accepting issue...');
              final updatedIssue = await _issueApiService.assignMaintenanceExecutive(
                _issue!.id,
                meProfileId,
              );
              if (mounted) {
                setState(() { _issue = updatedIssue; });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Issue accepted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) Navigator.of(context).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to accept: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onReject: () {},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot send message: No Maintenance Executive accepted.',
            ),
          ),
        );
      }
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
      } else if (_issue?.maintenanceExecutive?.user?.id.toString() ==
          targetUserId) {
        receiverName = _issue!.maintenanceExecutive!.user!.name;
        receiverEmail = _issue!.maintenanceExecutive!.user!.email;
      }

      receiverInfo = UserInfo(
        id: int.parse(targetUserId),
        name: receiverName,
        email: receiverEmail,
      );
    }

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      body: text,
      senderId: currentUser.id,
      createdAt: DateTime.now(),
      sender: UserInfo(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
      ),
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

  /// Handle action button taps from MessageInputField
  Future<void> _handleAction(String action) async {
    if (_issue == null) return;

    switch (action) {
      case 'Accept Issue':
        final authService = AuthService.instance;
        final currentUser = authService.currentUser;
        if (currentUser == null || currentUser.maintenanceExecutiveProfileId == null) break;
        try {
          _showLoadingDialog('Accepting issue...');
          final updatedIssue = await _issueApiService.assignMaintenanceExecutive(
            _issue!.id,
            currentUser.maintenanceExecutiveProfileId!,
          );
          if (mounted) {
            setState(() { _issue = updatedIssue; });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Issue accepted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) Navigator.of(context).pop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to accept issue: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;

      case 'Assign a Technician':
        showAssignGPMDialog(context, (technician) async {
          try {
            // Show loading indicator
            _showLoadingDialog('Assigning technician...');

            // Call API to assign technician
            await _issueApiService.assignTechnician(
              _issue!.id,
              technician.id,
            );

            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Technician ${technician.name} assigned successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to assign technician: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Get Outside Support':
        showGetOutsideSupportDialog(context, (thirdParty) async {
          try {
            // Show loading indicator
            _showLoadingDialog('Assigning third party...');

            // Call API to assign third party
            final updatedIssue = await _issueApiService.assignThirdParty(
              _issue!.id,
              thirdParty.id,
            );

            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Update local state
            setState(() {
              _issue = updatedIssue;
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Third party ${thirdParty.organization} assigned successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to assign third party: ${e.toString()}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Close Issue':
        showCloseIssueDialog(context, (description, imageFile) async {
          try {
            // Show loading indicator
            _showLoadingDialog('Closing issue...');

            // Upload image if provided
            String? imageUrl;
            if (imageFile != null) {
              try {
                final uploadedFile = await UploadService.instance.uploadFile(
                  imageFile,
                  issueId: _issue!.id,
                );
                imageUrl = uploadedFile.url;
              } catch (uploadError) {
                debugPrint('Failed to upload image: $uploadError');
                // Continue with closing even if image upload fails
              }
            }

            // 1. Update issue status to closed
            final updatedIssue = await _issueApiService.updateIssueStatus(
              _issue!.id,
              IssueStatus.closed,
            );

            // 2. Create a status log entry so the bubble shows in chat
            StatusModel? newStatusEntry;
            final currentUser = AuthService.instance.currentUser;
            if (currentUser != null) {
              final desc = (description?.trim().isNotEmpty == true)
                  ? description!
                  : 'Issue closed';
              const int tempId = -4;
              _pendingStatusIds.add(tempId);
              try {
                newStatusEntry = await _issueApiService.addStatusUpdate(
                  issueId: _issue!.id,
                  userId: currentUser.id,
                  description: desc,
                  imageUrl: imageUrl,
                  statusType: 'Closed',
                );
                _pendingStatusIds.remove(tempId);
                if (newStatusEntry != null) {
                  _pendingStatusIds.add(newStatusEntry.id);
                }
              } catch (statusErr) {
                _pendingStatusIds.remove(tempId);
                debugPrint(
                  'Status log entry failed (non-blocking): $statusErr',
                );
              }
            }

            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Update local state — merge new status entry into issue
            setState(() {
              final currentStatuses = List<StatusModel>.from(
                _issue!.statuses ?? [],
              );
              if (newStatusEntry != null) currentStatuses.add(newStatusEntry);
              _issue = updatedIssue.copyWith(statuses: currentStatuses);
            });
            _scrollToBottom();

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue closed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to close issue: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Update the Status':
        showUpdateStatusDialog(context, _issue!.status.value, (
          newStatus,
          description,
          imageFiles,
        ) async {
          try {
            // Show loading indicator
            _showLoadingDialog('Updating status...');

            // Upload images if provided
            List<String>? imageUrls;
            if (imageFiles.isNotEmpty) {
              try {
                imageUrls = [];
                for (final imageFile in imageFiles) {
                  final uploadedFile = await UploadService.instance.uploadFile(
                    imageFile,
                    issueId: _issue!.id,
                  );
                  imageUrls.add(uploadedFile.url);
                }
              } catch (uploadError) {
                debugPrint('Failed to upload images: $uploadError');
                // Continue even if image upload fails
                imageUrls = null;
              }
            }

            // Map dialog status value to backend status
            final backendStatus = _mapDialogStatusToBackend(newStatus);

            // Map dialog status value to Statuses table status_type
            final statusType = _mapDialogStatusToStatusType(newStatus);

            // 1. Update the issue status
            final updatedIssue = await _issueApiService.updateIssueStatus(
              _issue!.id,
              IssueStatus.fromString(backendStatus),
            );

            // 2. Create a status log entry
            StatusModel? newStatusEntry;
            final currentUser = AuthService.instance.currentUser;
            if (currentUser != null) {
              final desc = (description?.trim().isNotEmpty == true)
                  ? description!
                  : 'Status updated to $statusType';
              // Use a temporary placeholder ID to mark this as our own event.
              // Any socket event that arrives while awaiting will be suppressed
              // by the seen-IDs deduplication in build().
              const int tempId = -1;
              _pendingStatusIds.add(tempId);
              try {
                newStatusEntry = await _issueApiService.addStatusUpdate(
                  issueId: _issue!.id,
                  userId: currentUser.id,
                  description: desc,
                  imageUrls: imageUrls,
                  statusType: statusType,
                );
                // Replace temp with the real ID so the socket listener can match it
                _pendingStatusIds.remove(tempId);
                if (newStatusEntry != null) {
                  _pendingStatusIds.add(newStatusEntry.id);
                }
              } catch (statusErr) {
                _pendingStatusIds.remove(tempId);
                debugPrint(
                  'Status log entry failed (non-blocking): $statusErr',
                );
              }
            }

            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Update local state — merge new status entry into issue
            setState(() {
              final currentStatuses = List<StatusModel>.from(
                _issue!.statuses ?? [],
              );
              if (newStatusEntry != null) currentStatuses.add(newStatusEntry);
              _issue = updatedIssue.copyWith(statuses: currentStatuses);
            });
            _scrollToBottom();

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Status updated to ${statusType.replaceAll('_', ' ')}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            // Dismiss loading
            if (mounted) Navigator.of(context).pop();

            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update status: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Suggest Outside Support':
        // For technicians suggesting outside support
        showSuggestOutsidePartyDialog(context, (
          description,
          suggestedParty,
        ) async {
          try {
            _showLoadingDialog('Submitting suggestion...');

            // TODO: Implement API endpoint for suggesting third party
            // For now, we'll just show a success message
            // In the future, this should create a suggestion/request record

            if (mounted) Navigator.of(context).pop();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Suggestion for "$suggestedParty" submitted successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) Navigator.of(context).pop();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to submit suggestion: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Request Petty Cash':
        showRequestPettyCashDialog(context, (amount, description) async {
          try {
            _showLoadingDialog('Submitting petty cash request...');

            final currentUser = AuthService.instance.currentUser;
            if (currentUser == null) {
              if (mounted) Navigator.of(context).pop();
              return;
            }

            // Use issue's assigned technician id (backend expects Technicians.id, not User.id)
            final technicianId = _issue!.technicianId ?? currentUser.id;
            final newRequest = await _issueApiService.createPettyCashRequest(
              issueId: _issue!.id,
              amount: amount,
              description: description,
              technicianId: technicianId,
            );

            if (mounted) Navigator.of(context).pop();

            // Update local state with the API response
            setState(() {
              final currentRequests = List<PettyCashRequestModel>.from(
                _issue!.pettyCashRequests ?? [],
              );
              currentRequests.add(newRequest);
              _issue = _issue!.copyWith(pettyCashRequests: currentRequests);
            });
            _scrollToBottom();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Petty cash request for Rs. ${amount.toStringAsFixed(2)} submitted',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) Navigator.of(context).pop();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to submit request: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
        break;

      case 'Suggest Outside Party':
        _showSuggestOutsidePartyDialog();
        break;
    }
  }

  /// Handle approval actions (approve/reject Pending Resolution or Pending Close)
  Future<void> _handleApprovalAction(String action) async {
    if (_issue == null) return;

    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    if (action.startsWith('approve_')) {
      final isResolution = action == 'approve_resolution';
      final newBackendStatus = isResolution
          ? IssueStatus.done
          : IssueStatus.closed;
      final newStatusType = isResolution ? 'Resolved' : 'Closed';
      final description = isResolution
          ? 'Resolution approved by ${currentUser.name}'
          : 'Close approved by ${currentUser.name}';

      try {
        _showLoadingDialog('Approving...');

        // 1. Update issue status
        final updatedIssue = await _issueApiService.updateIssueStatus(
          _issue!.id,
          newBackendStatus,
        );

        // 2. Add status log entry
        StatusModel? newStatusEntry;
        const int _approveTemp = -2;
        _pendingStatusIds.add(_approveTemp);
        try {
          newStatusEntry = await _issueApiService.addStatusUpdate(
            issueId: _issue!.id,
            userId: currentUser.id,
            description: description,
            statusType: newStatusType,
          );
          _pendingStatusIds.remove(_approveTemp);
          if (newStatusEntry != null) _pendingStatusIds.add(newStatusEntry.id);
        } catch (e) {
          _pendingStatusIds.remove(_approveTemp);
          debugPrint('Status log entry failed: $e');
        }

        if (mounted) Navigator.of(context).pop();

        setState(() {
          final currentStatuses = List<StatusModel>.from(
            _issue!.statuses ?? [],
          );
          if (newStatusEntry != null) currentStatuses.add(newStatusEntry);
          _issue = updatedIssue.copyWith(statuses: currentStatuses);
        });
        _scrollToBottom();
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to approve: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (action.startsWith('reject_')) {
      final isResolution = action == 'reject_resolution';
      final statusTypeLabel = isResolution ? 'Resolution' : 'Close request';

      // prompt for rejection reason
      final reasonController = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Reject $statusTypeLabel'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  Navigator.of(ctx).pop(reasonController.text.trim());
                }
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (reason == null || reason.isEmpty) return;

      try {
        _showLoadingDialog('Rejecting...');

        // 1. Revert issue status to In Progress
        final updatedIssue = await _issueApiService.updateIssueStatus(
          _issue!.id,
          IssueStatus.inProgress,
        );

        // 2. Add status log entry
        StatusModel? newStatusEntry;
        const int _rejectTemp = -3;
        _pendingStatusIds.add(_rejectTemp);
        try {
          newStatusEntry = await _issueApiService.addStatusUpdate(
            issueId: _issue!.id,
            userId: currentUser.id,
            description: '$statusTypeLabel rejected. Reason: $reason',
            statusType: 'In Progress',
          );
          _pendingStatusIds.remove(_rejectTemp);
          if (newStatusEntry != null) _pendingStatusIds.add(newStatusEntry.id);
        } catch (e) {
          _pendingStatusIds.remove(_rejectTemp);
          debugPrint('Status log entry failed: $e');
        }

        if (mounted) Navigator.of(context).pop();

        setState(() {
          final currentStatuses = List<StatusModel>.from(
            _issue!.statuses ?? [],
          );
          if (newStatusEntry != null) currentStatuses.add(newStatusEntry);
          _issue = updatedIssue.copyWith(statuses: currentStatuses);
        });
        _scrollToBottom();
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Handle petty cash actions (approve/reject)
  void _handlePettyCashAction(dynamic requestId, String action) async {
    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final actionLabel = action == 'approve'
        ? 'Approving'
        : action == 'cancel'
        ? 'Canceling'
        : action == 'undo'
        ? 'Undoing'
        : 'Rejecting';
    _showLoadingDialog('$actionLabel petty cash request...');

    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      // Call REST API to update petty cash request
      final updatedRequest = await _issueApiService.updatePettyCashRequest(
        requestId: requestId,
        action: action,
        issueId: _issue!.id,
        userId: currentUser.id,
      );

      if (mounted) Navigator.of(context).pop();

      // Update local state with the API response
      setState(() {
        final currentRequests = List<PettyCashRequestModel>.from(
          _issue!.pettyCashRequests ?? [],
        );
        final index = currentRequests.indexWhere(
          (r) => r.id == updatedRequest.id,
        );
        if (index != -1) {
          currentRequests[index] = updatedRequest;
        }
        _issue = _issue!.copyWith(pettyCashRequests: currentRequests);
      });

      final successMessage = action == 'approve'
          ? 'Petty cash request approved'
          : action == 'cancel'
          ? 'Petty cash request canceled'
          : action == 'undo'
          ? 'Decision undone — request is now pending'
          : 'Petty cash request rejected';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle approve / reject for outside party requests
  void _handleOutsidePartyAction(dynamic requestId, String action) async {
    if (requestId == null) return;

    _showLoadingDialog(
      '${action == 'approve' ? 'Approving' : 'Rejecting'} outside party request...',
    );

    try {
      _socket?.emit('outside_party_action', {
        'request_id': requestId,
        'action': action,
        'issue_id': _issue!.id,
        'user_id': AuthService.instance.currentUser?.id,
      });

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'approve'
                  ? 'Outside party request approved ✓'
                  : 'Outside party request rejected',
            ),
            backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show the "Suggest Outside Party" dialog for technicians
  void _showSuggestOutsidePartyDialog() {
    final vendorController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Suggest Outside Party',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: vendorController,
                decoration: InputDecoration(
                  labelText: 'Suggested Party / Vendor *',
                  hintText: 'e.g. Oven Builders Pvt Ltd',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vendor name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Why is an outside party needed?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop();
                _handleSuggestOutsideParty(
                  vendorController.text.trim(),
                  descController.text.trim(),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  /// Emit the outside_party_suggest socket event
  void _handleSuggestOutsideParty(String vendorName, String description) {
    _socket?.emit('outside_party_suggest', {
      'issue_id': _issue!.id,
      'suggested_by': AuthService.instance.currentUser?.id,
      'vendor_name': vendorName,
      'description': description,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outside party suggestion submitted ✓'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// Show a loading dialog

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = _issue;

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
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
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
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
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
      participants['u_me'] = {'name': 'You', 'avatarUrl': null, 'userId': 'me'};
    }

    // Populate participants from issue data with real profile pictures
    if (issue.manager?.user != null) {
      participants['u_mgr_${issue.manager!.id}'] = {
        'name': issue.manager!.user!.name,
        'avatarUrl':
            issue.manager!.user!.profilePicture, // Use real profile picture
        'userId': issue.manager!.user!.id.toString(),
      };
    }
    if (issue.technician?.user != null) {
      participants['u_tech_${issue.technician!.id}'] = {
        'name': issue.technician!.user!.name,
        'avatarUrl':
            issue.technician!.user!.profilePicture, // Use real profile picture
        'userId': issue.technician!.user!.id.toString(),
      };
    }
    if (issue.maintenanceExecutive?.user != null) {
      participants['u_exec_${issue.maintenanceExecutive!.id}'] = {
        'name': issue.maintenanceExecutive!.user!.name,
        'avatarUrl': issue
            .maintenanceExecutive!
            .user!
            .profilePicture, // Use real profile picture
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
      'attachments':
          <
            String
          >[], // Empty list - attachments will be populated when file upload is implemented
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
        'technicianName':
            issue.maintenanceExecutive?.user?.name ?? 'Maintenance Executive',
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

    if (issue.status == IssueStatus.done ||
        issue.status == IssueStatus.closed) {
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
        if (msgSenderId != currentUserId &&
            msgReceiverId != currentUserId &&
            msgReceiverId != null) {
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

    // Add petty cash requests — technician (sender) sees on right, others on left
    if (issue.pettyCashRequests != null) {
      for (final request in issue.pettyCashRequests!) {
        final isSender =
            myRole == UserRole.technician &&
            request.technicianId == issue.technicianId;
        chatItems.add({
          'type': 'petty_cash',
          'createdAt': request.createdAt,
          'amount': 'Rs. ${request.amount}',
          'timeText':
              '${request.createdAt.hour}:${request.createdAt.minute.toString().padLeft(2, '0')} ${request.createdAt.hour < 12 ? 'AM' : 'PM'}',
          'creatorId': 'u_tech_${request.technicianId}',
          'description': request.description,
          'status': request.status,
          'requestId': request.id,
          'alignRight': isSender,
        });
      }
    }

    // Add outside party requests
    if (issue.outsidePartyRequests != null) {
      for (final req in issue.outsidePartyRequests!) {
        final timeText =
            '${req.createdAt.hour}:${req.createdAt.minute.toString().padLeft(2, '0')} ${req.createdAt.hour < 12 ? 'AM' : 'PM'}';
        final creatorKey = participants.keys.firstWhere(
          (k) => participants[k]?['userId'] == req.suggestedBy.toString(),
          orElse: () {
            final k = 'u_opr_${req.suggestedBy}';
            participants[k] = {
              'name': 'Technician',
              'avatarUrl': null,
              'userId': req.suggestedBy.toString(),
            };
            return k;
          },
        );
        chatItems.add({
          'type': 'outside_party',
          'createdAt': req.createdAt,
          'requestId': req.id,
          'vendorName': req.vendorName,
          'description': req.description,
          'status': req.status,
          'timeText': timeText,
          'creatorId': creatorKey,
          'alignRight': false,
        });
      }
    }

    // Add status update log entries — deduplicate by ID to prevent double-render
    if (issue.statuses != null) {
      final seenStatusIds = <int>{};
      for (final statusEntry in issue.statuses!) {
        // Skip if we've already added a bubble for this ID
        if (!seenStatusIds.add(statusEntry.id)) continue;

        final creatorUserId = statusEntry.userId.toString();
        // Find or create participant key for the status updater
        final creatorKey = participants.keys.firstWhere(
          (k) => participants[k]?['userId'] == creatorUserId,
          orElse: () {
            final k = 'u_$creatorUserId';
            participants[k] = {
              'name': statusEntry.user?.name ?? 'User',
              'avatarUrl': statusEntry.user?.profilePicture,
              'userId': creatorUserId,
            };
            return k;
          },
        );
        chatItems.add({
          'type': 'status_update',
          'createdAt': statusEntry.createdAt,
          'description': statusEntry.description,
          'timeText':
              '${statusEntry.createdAt.hour}:${statusEntry.createdAt.minute.toString().padLeft(2, '0')} ${statusEntry.createdAt.hour < 12 ? 'AM' : 'PM'}',
          'creatorId': creatorKey,
          'attachments': statusEntry.imageUrls,
          'alignRight': creatorUserId == currentUserId,
          'statusType': statusEntry.statusType,
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

    // Inject a dedicated pending-approval bubble for both Technicians AND Approvers
    final isApprover =
        myRole == UserRole.executive || myRole == UserRole.branchManager;
    final isTechnician = myRole == UserRole.technician;
    final isIssuePendingResolution =
        issue.status == IssueStatus.pendingResolution;
    final isIssuePendingClose = issue.status == IssueStatus.pendingClose;

    if (isIssuePendingResolution || isIssuePendingClose) {
      String techName = issue.technician?.user?.name ?? 'Technician';

      chatItems.add({
        'type': 'pending_approval',
        'createdAt': issue.updatedAt.add(const Duration(seconds: 1)),
        'pendingType': isIssuePendingResolution
            ? 'Pending Resolution'
            : 'Pending Close',
        'requesterName': techName,
        'timeText':
            '${issue.updatedAt.hour}:${issue.updatedAt.minute.toString().padLeft(2, '0')} ${issue.updatedAt.hour < 12 ? 'AM' : 'PM'}',
        'creatorId': issue.technicianId != null
            ? 'u_tech_${issue.technicianId}'
            : null,
        // Technician sees it aligned right (their own request), manager/exec sees it aligned left
        'alignRight': isTechnician,
        // Only pass action flags for approvers
        'showActions': isApprover,
      });

      // Re-sort so this appears at the end
      chatItems.sort((a, b) {
        final dateA = a['createdAt'] as DateTime?;
        final dateB = b['createdAt'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return -1;
        if (dateB == null) return 1;
        return dateA.compareTo(dateB);
      });
    }

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
                    final showApprovalActions =
                        (it['showApprovalActions'] as bool?) ?? false;
                    final pendingType =
                        it['pendingType'] as String? ??
                        it['statusType'] as String?;

                    return StatusUpdateBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      description: it['description'] as String,
                      timeText: it['timeText'] as String,
                      attachments: (it['attachments'] as List<String>?) ?? [],
                      alignRight: alignRight,
                      statusType: it['statusType'] as String?,
                      showApprovalActions: showApprovalActions,
                      onApprove: showApprovalActions
                          ? () => _handleApprovalAction(
                              pendingType == 'Pending Resolution'
                                  ? 'approve_resolution'
                                  : 'approve_close',
                            )
                          : null,
                      onReject: showApprovalActions
                          ? () => _handleApprovalAction(
                              pendingType == 'Pending Resolution'
                                  ? 'reject_resolution'
                                  : 'reject_close',
                            )
                          : null,
                    );
                  }

                  if (it['type'] == 'pending_approval') {
                    final creatorId = it['creatorId'] as String?;
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl']
                        : null;
                    final pendingType = it['pendingType'] as String;
                    final requesterName =
                        it['requesterName'] as String? ?? 'Technician';
                    final alignRight = (it['alignRight'] as bool?) ?? false;
                    final showActions = (it['showActions'] as bool?) ?? false;

                    return PendingApprovalBubble(
                      pendingType: pendingType,
                      requesterName: requesterName,
                      timeText: it['timeText'] as String,
                      creatorAvatarUrl: creatorAvatarUrl,
                      alignRight: alignRight,
                      senderInfoText: alignRight
                          ? '${it['timeText']} · You'
                          : '${it['timeText']} · $requesterName',
                      onReject: showActions
                          ? () => _handleApprovalAction(
                              pendingType == 'Pending Resolution'
                                  ? 'reject_resolution'
                                  : 'reject_close',
                            )
                          : null,
                      onApprove: showActions
                          ? () => _handleApprovalAction(
                              pendingType == 'Pending Resolution'
                                  ? 'approve_resolution'
                                  : 'approve_close',
                            )
                          : null,
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
                    final creator = creatorId != null
                        ? participants[creatorId]
                        : null;
                    final creatorAvatarUrl = creator != null
                        ? creator['avatarUrl'] as String?
                        : null;
                    final creatorName = creator != null
                        ? creator['name'] as String?
                        : null;
                    final alignRight = (it['alignRight'] as bool?) ?? false;
                    final requestId = it['requestId'] as String?;
                    final requestStatus = it['status'] as String?;

                    final isManager =
                        myRole == UserRole.executive ||
                        myRole == UserRole.branchManager;

                    return OutsidePartySuggestionBubble(
                      vendorName: it['vendorName'] as String,
                      description: it['description'] as String? ?? '',
                      timeText: it['timeText'] as String,
                      status: requestStatus,
                      alignRight: alignRight,
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName,
                      senderInfoText: creatorName != null
                          ? '${it['timeText']} · $creatorName'
                          : null,
                      onApprove: requestStatus == 'pending' && isManager
                          ? () =>
                                _handleOutsidePartyAction(requestId, 'approve')
                          : null,
                      onReject: requestStatus == 'pending' && isManager
                          ? () => _handleOutsidePartyAction(requestId, 'reject')
                          : null,
                    );
                  }

                  if (it['type'] == 'petty_cash') {
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
                    final requestId = it['requestId'];
                    final requestStatus = it['status'] as String?;

                    final isManager =
                        myRole == UserRole.executive ||
                        myRole == UserRole.branchManager;
                    final isTechnician = myRole == UserRole.technician;

                    return PettyCashRequestBubble(
                      creatorAvatarUrl: creatorAvatarUrl,
                      creatorName: creatorName ?? 'Unknown',
                      amountLabel: it['amount'] as String,
                      timeText: it['timeText'] as String,
                      description: it['description'] as String?,
                      status: requestStatus,
                      alignRight: alignRight,
                      senderInfoText: creatorName != null
                          ? '${it['timeText']} From ${creatorName}'
                          : null,
                      onCancel: requestStatus == 'pending' && isTechnician
                          ? () => _handlePettyCashAction(requestId, 'cancel')
                          : null,
                      onReject: requestStatus == 'pending' && isManager
                          ? () => _handlePettyCashAction(requestId, 'reject')
                          : null,
                      onAccept: requestStatus == 'pending' && isManager
                          ? () => _handlePettyCashAction(requestId, 'approve')
                          : null,
                      onUndo:
                          (requestStatus == 'approved' ||
                                  requestStatus == 'rejected') &&
                              isManager
                          ? () => _handlePettyCashAction(requestId, 'undo')
                          : null,
                    );
                  }

                  final senderIdKey = it['senderId'] as String;
                  final receiverIdKey = it['receiverId'] as String?;

                  // Check if the sender is the current logged-in user
                  final senderData = participants[senderIdKey];
                  final senderUserId = senderData?['userId'];
                  final isMe = senderUserId == currentUserId;

                  final sender = participants[senderIdKey];
                  final receiver = receiverIdKey != null
                      ? participants[receiverIdKey]
                      : null;

                  // Determine whose avatar to show (the other person)
                  final otherIdKey = isMe ? receiverIdKey : senderIdKey;
                  final otherAvatar =
                      otherIdKey != null && participants[otherIdKey] != null
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
              onAction: _handleAction,
              showAcceptButton: myRole == UserRole.executive &&
                  _issue?.maintenanceExecutive == null,
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

  /// Map the dialog dropdown status value (e.g. 'open', 'in_progress', 'resolved', 'closed')
  /// to the backend Issue ENUM value ('Open', 'In Progress', 'Pending Resolution', 'Pending Close', 'Done', 'Closed')
  String _mapDialogStatusToBackend(String dialogStatus) {
    final role = AuthService.instance.currentUser?.role;
    final isTechnician = role == 'technician';

    switch (dialogStatus.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return isTechnician ? 'Pending Resolution' : 'Done';
      case 'closed':
        return isTechnician ? 'Pending Close' : 'Closed';
      default:
        return 'Open';
    }
  }

  /// Map the dialog dropdown status value to the Statuses table status_type ENUM
  /// ('Open', 'Assigned', 'In Progress', 'Pending Resolution', 'Pending Close', 'Resolved', 'Closed')
  String _mapDialogStatusToStatusType(String dialogStatus) {
    final role = AuthService.instance.currentUser?.role;
    final isTechnician = role == 'technician';

    switch (dialogStatus.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return isTechnician ? 'Pending Resolution' : 'Resolved';
      case 'closed':
        return isTechnician ? 'Pending Close' : 'Closed';
      default:
        return 'Open';
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
      case IssueStatus.pendingResolution:
        return {
          'label': 'Pending Resolution',
          'color': const Color(0xFFAB47BC), // Purple
        };
      case IssueStatus.pendingClose:
        return {
          'label': 'Pending Close',
          'color': const Color(0xFFAB47BC), // Purple
        };
    }
  }
}
