import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/pages/image_viewer.dart';

class StatusUpdateBubble extends StatelessWidget {
  final String description;
  final String? timeText;
  final List<String> attachments; // image URLs
  final String? creatorAvatarUrl;
  final bool alignRight;
  final String? creatorName; // kept for API compatibility

  const StatusUpdateBubble({
    super.key,
    required this.description,
    this.timeText,
    this.attachments = const [],
    this.creatorAvatarUrl,
    this.alignRight = false,
    this.creatorName,
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
                // Bubble
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6F0),
                    borderRadius: const BorderRadius.all(Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                          'Status Update',
                          style: TextStyle(
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
                        // Updated time inside the box
                        if ((timeText ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_outlined,
                                size: 16,
                                color: Color(0xFF3EA8D0),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                timeText!.trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3EA8D0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Attachments thumbnails with viewer (kept below the bubble)
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachments.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
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
                                      errorBuilder: (_, error, stackTrace) =>
                                          Icon(
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
                                  final imgs = attachments
                                      .where((u) => u.isNotEmpty)
                                      .toList();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImageGalleryViewer(
                                        urls: imgs,
                                        initialIndex: imgs.indexOf(url),
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
                ],
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
