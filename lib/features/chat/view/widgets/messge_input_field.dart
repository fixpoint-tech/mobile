import 'package:flutter/material.dart';
import 'package:mobile/features/user/model/user_role.dart';

class MessageInputField extends StatefulWidget {
  final UserRole role; // supplied from saved login role
  final Function(String text, String? target)? onSend;
  final Function(String action)? onAction; // callback for action buttons
  final bool showAcceptButton;

  const MessageInputField({
    super.key,
    required this.role,
    this.onSend,
    this.onAction,
    this.showAcceptButton = false,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  bool showActions = false;
  bool showSendOptions = false;
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleSendOptions() {
    if (showSendOptions) {
      _removeOverlay();
      setState(() => showSendOptions = false);
    } else {
      setState(() {
        showSendOptions = true;
        showActions = false;
      });
      _showOverlay(isSendOptions: true);
    }
  }

  void _toggleActions() {
    if (showActions) {
      _removeOverlay();
      setState(() => showActions = false);
    } else {
      setState(() {
        showActions = true;
        showSendOptions = false;
      });
      _showOverlay(isSendOptions: false);
    }
  }

  void _showOverlay({required bool isSendOptions}) {
    _removeOverlay();
    
    final overlay = Overlay.of(context);
    
    // Get actions list again for the overlay
    final List<String> actions;
    switch (widget.role) {
      case UserRole.branchManager:
        actions = const ['Close Issue'];
        break;
      case UserRole.executive:
        actions = [
          if (widget.showAcceptButton) 'Accept Issue',
          'Update the Status',
          'Assign a Technician',
          'Get Outside Support',
          'Close Issue',
        ];
        break;
      case UserRole.technician:
        actions = const [
          'Suggest Outside Party',
          'Request Petty Cash',
          'Update the Status',
        ];
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 200, // Constrain width so it doesn't span full screen
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, -10), // Slight gap
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomRight,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: isSendOptions
                    ? [
                        senderChip('GPM'),
                        const SizedBox(height: 6),
                        senderChip('GDM'),
                      ]
                    : [
                        for (int i = 0; i < actions.length; i++) ...[
                          actionChip(actions[i], () {
                            _removeOverlay();
                            setState(() => showActions = false);
                            widget.onAction?.call(actions[i]);
                          }),
                          if (i < actions.length - 1) const SizedBox(height: 6),
                        ],
                      ],
              ),
            ),
          ),
        );
      },
    );
    
    overlay.insert(_overlayEntry!);
  }

  void _sendMessage(String target) {
    if (_controller.text.trim().isEmpty) return;
    // ignore: avoid_print
    print('Sending message to $target: ${_controller.text}');
    
    widget.onSend?.call(_controller.text, target);

    _controller.clear();
    _removeOverlay();
    setState(() {
      showSendOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exact order as screenshots
    final List<String> actions;
    switch (widget.role) {
      case UserRole.branchManager: // GDM
        actions = const [
          'Update the Status',
          'Get Outside Support',
          'Close Issue',
        ];
        break;
      case UserRole.executive:
        actions = [
          if (widget.showAcceptButton) 'Accept Issue',
          'Update the Status',
          'Assign a Technician',
          'Get Outside Support',
          'Close Issue',
        ];
        break;
      case UserRole.technician:
        actions = const [
          'Suggest Outside Party',
          'Request Petty Cash',
          'Update the Status',
        ];
        break;
    }

    final bool hasActions = actions.isNotEmpty;
    final bool displayActions = hasActions && showActions;
    final bool displaySendOptions = widget.role == UserRole.executive &&
        showSendOptions &&
        _controller.text.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    if (value.isEmpty && showSendOptions) {
                      _removeOverlay();
                      setState(() => showSendOptions = false);
                    } else if (value.isNotEmpty && !showSendOptions) {
                       setState(() {}); 
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    filled: true,
                    fillColor:
                        Colors.transparent, // keep input bg transparent
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: const Color(0xFF3EA8D0),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;

                    if (widget.role == UserRole.executive) {
                      _toggleSendOptions();
                    } else {
                      // For other roles, send directly (e.g. to Executive)
                      _sendMessage('Executive');
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: const Color(0xFF3EA8D0),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  onTap: () {
                    if (!hasActions) return;
                    _toggleActions();
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        hasActions && showActions ? Icons.close : Icons.add,
                        color: Colors.white,
                        size: 24, // match send icon size
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget senderChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3EA8D0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget actionChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFF7489),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
