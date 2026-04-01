import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/pages/image_viewer.dart';

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
  final String? creatorName;
  final String? occurrenceTimeText; // issue occurrence time (inside the box)

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
    this.creatorName,
    this.occurrenceTimeText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const avatarWithSpacing = 40.0; // ~32 avatar + 8 spacing
    final maxWidth = (screenWidth * 0.86) - avatarWithSpacing;

    // Filter out empty URLs
    final validAttachments =
        attachments.where((u) => u.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                      borderRadius:
                          const BorderRadius.all(Radius.circular(22)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Text content ──
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: severityColor,
                                      borderRadius:
                                          BorderRadius.circular(16),
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
                                ],
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
                              // Branch + occurrence time
                              Wrap(
                                crossAxisAlignment:
                                    WrapCrossAlignment.center,
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

                        // ── Image previews (inside bubble) ──
                        if (validAttachments.isNotEmpty) ...[
                          // Single image: full-width tall preview
                          if (validAttachments.length == 1)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: _buildImageTile(
                                context,
                                validAttachments[0],
                                validAttachments,
                                0,
                                height: 180,
                                radius: 14,
                              ),
                            ),

                          // Two images: side-by-side
                          if (validAttachments.length == 2)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildImageTile(
                                      context,
                                      validAttachments[0],
                                      validAttachments,
                                      0,
                                      height: 120,
                                      radius: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildImageTile(
                                      context,
                                      validAttachments[1],
                                      validAttachments,
                                      1,
                                      height: 120,
                                      radius: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 3+ images: large first + scrollable strip
                          if (validAttachments.length >= 3) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 0, 10, 6),
                              child: _buildImageTile(
                                context,
                                validAttachments[0],
                                validAttachments,
                                0,
                                height: 150,
                                radius: 12,
                              ),
                            ),
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.fromLTRB(
                                    10, 0, 10, 10),
                                itemCount: validAttachments.length - 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 6),
                                itemBuilder: (ctx, i) => _buildImageTile(
                                  ctx,
                                  validAttachments[i + 1],
                                  validAttachments,
                                  i + 1,
                                  height: 70,
                                  width: 90,
                                  radius: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Meta text (time + sender name below the bubble)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _buildMetaText(
                      timeText: timeText,
                      senderName: creatorName,
                    ),
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

  // ── Helpers ──

  Widget _buildImageTile(
    BuildContext context,
    String url,
    List<String> allUrls,
    int index, {
    required double height,
    double? width,
    required double radius,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageGalleryViewer(
              urls: allUrls,
              initialIndex: index,
              heroTagPrefix: 'ticket_',
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: width,
          height: height,
          child: Hero(
            tag: 'ticket_${url}_$index',
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: width ?? double.infinity,
              height: height,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFDDD6F3),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: const Color(0xFF7C5CBF),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE8E0F0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: Colors.grey.shade500, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'Failed to load',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFFF7489),
      backgroundImage:
          (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
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
