import 'package:flutter/material.dart';
import 'package:mobile/features/user/model/user_role.dart';

class MessageInputField extends StatefulWidget {
  final UserRole role; // supplied from saved login role

  const MessageInputField({super.key, required this.role});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  bool showActions = false;

  @override
  Widget build(BuildContext context) {
    // Exact order as screenshots
    final List<String> actions;
    switch (widget.role) {
      case UserRole.branchManager: // GDM
        actions = const [
          'Assign a Technician',
          'Get Outside Support',
          'Close Issue',
        ];
        break;
      case UserRole.executive:
        actions = const [
          'Update the Status',
          'Suggest Outside Support',
          'Request Petty Cash',
          'Close Issue',
        ];
        break;
      case UserRole.technician: // GPM: no options
        actions = const [];
        break;
    }

    final bool hasActions = actions.isNotEmpty;
    final bool displayActions = hasActions && showActions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior:
              Clip.none, // allow chips to draw above without expanding height
          alignment: Alignment.bottomRight,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                    onPressed: () {},
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
                    overlayColor: const MaterialStatePropertyAll(
                      Colors.transparent,
                    ),
                    onTap: () {
                      if (!hasActions) return;
                      setState(() => showActions = !showActions);
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
            if (displayActions)
              Positioned(
                right: 0,
                bottom: 56, // place chips above the input row; tweak as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      actionChip(actions[i]),
                      if (i < actions.length - 1) const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget actionChip(String text) {
    return Container(
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
    );
  }
}
