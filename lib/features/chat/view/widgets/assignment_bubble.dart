import 'package:flutter/material.dart';

class AssignmentBubble extends StatelessWidget {
  final String title; // e.g. "Assigned a GPM"
  final String technicianName; // variable
  final String timeText; // variable, e.g. "8:09 AM"
  final bool alignRight;
  final String? creatorAvatarUrl; // avatar on the side of the bubble
  final VoidCallback? onTap;
  final String? creatorName; // added

  const AssignmentBubble({
    super.key,
    required this.title,
    required this.technicianName,
    required this.timeText,
    this.alignRight = true,
    this.creatorAvatarUrl,
    this.onTap,
    this.creatorName, // added
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const avatarWithSpacing = 40.0; // ~32 avatar + 8 spacing
    final maxWidth = (screenWidth * 0.86) - avatarWithSpacing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: alignRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!alignRight) ...[
            _buildAvatar(creatorAvatarUrl),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE6F0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            technicianName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Assigned time inside the box (blue) aligned with icon
                          if (timeText.trim().isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                  color: Color(0xFF3EA8D0),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  timeText,
                                  style: const TextStyle(
                                    color: Color(0xFF3EA8D0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          if (alignRight) ...[
            const SizedBox(width: 8),
            _buildAvatar(creatorAvatarUrl),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFFF7489),
      backgroundImage: (url != null && url.isNotEmpty)
          ? NetworkImage(url)
          : null,
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.person, size: 18, color: Color(0xFF8AA4B8))
          : null,
    );
  }
}
