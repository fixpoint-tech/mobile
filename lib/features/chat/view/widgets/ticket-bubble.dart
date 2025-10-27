import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/pages/image_viewer.dart'; // added

class TicketBubble extends StatelessWidget {
  final String title;
  final String description;
  final String branch;
  final String timeText; // creation/submission time (below the box)
  final String severityLabel; // e.g. "Critical"
  final Color severityColor;
  final List<String> attachments; // image URLs
  final bool alignRight; // if you ever need to align to right
  final VoidCallback? onTap;
  final String? creatorAvatarUrl;
  final String? creatorName; // added
  final String?
  occurrenceTimeText; // NEW: issue occurrence time (inside the box)

  const TicketBubble({
    super.key,
    required this.title,
    required this.description,
    required this.branch,
    required this.timeText,
    required this.severityLabel,
    this.severityColor = const Color(0xFFFF7489),
    this.attachments = const [],
    this.alignRight = false,
    this.onTap,
    this.creatorAvatarUrl,
    this.creatorName, // added
    this.occurrenceTimeText, // NEW
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
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Padding(
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
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.3,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Branch + occurrence time shown together inside the box (blue)
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: Color(0xFF3EA8D0),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        branch,
                                        style: const TextStyle(
                                          color: Color(0xFF3EA8D0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                  if ((occurrenceTimeText ?? '')
                                      .trim()
                                      .isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.access_time_outlined,
                                          size: 18,
                                          color: Color(0xFF3EA8D0),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          occurrenceTimeText!,
                                          style: const TextStyle(
                                            color: Color(0xFF3EA8D0),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Severity chip near top-right corner
                        PositionedDirectional(
                          top: 12, // was 6
                          end: 18, // was 12
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              severityLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Attachments row (tap to view)
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final url = attachments[i];
                        final hasImage = url.isNotEmpty;
                        final thumb = ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 100,
                            height: 86,
                            color: const Color(0xFFF0ECF8),
                            child: hasImage
                                ? Hero(
                                    tag: url,
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, _) => Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey.shade500,
                                  ),
                          ),
                        );

                        return hasImage
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImageGalleryViewer(
                                        urls: attachments
                                            .where((u) => u.isNotEmpty)
                                            .toList(),
                                        initialIndex: attachments
                                            .where((u) => u.isNotEmpty)
                                            .toList()
                                            .indexOf(url),
                                      ),
                                    ),
                                  );
                                },
                                child: thumb,
                              )
                            : thumb;
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _buildMetaText(
                      timeText: timeText,
                      senderName: creatorName,
                    ), // creation time below (after images)
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
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

  String _buildMetaText({required String timeText, String? senderName}) {
    final t = timeText.trim();
    final n = (senderName ?? '').trim();
    if (t.isNotEmpty && n.isNotEmpty) return '$t From $n';
    if (t.isNotEmpty) return t;
    if (n.isNotEmpty) return 'From $n';
    return '';
  }
}
