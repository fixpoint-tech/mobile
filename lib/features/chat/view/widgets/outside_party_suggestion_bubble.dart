import 'package:flutter/material.dart';

class OutsidePartySuggestionBubble extends StatelessWidget {
  final String partyName; // e.g. "Oven Builders PVT Ltd."
  final String suggestedTime; // e.g. "9:50 AM"
  final bool alignRight;
  final String? creatorAvatarUrl;
  final VoidCallback? onTap;

  const OutsidePartySuggestionBubble({
    super.key,
    required this.partyName,
    required this.suggestedTime,
    this.alignRight = false,
    this.creatorAvatarUrl,
    this.onTap,
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
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECE6F0),
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
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
                      const Text(
                        'Suggested an Outside Party',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        partyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // icon + time aligned as in the mock
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: Color(0xFF3EA8D0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            suggestedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3EA8D0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
