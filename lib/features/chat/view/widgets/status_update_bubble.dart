import 'package:flutter/material.dart';
import 'package:mobile/features/chat/view/pages/image_viewer.dart';

class StatusUpdateBubble extends StatelessWidget {
  final String description;
  final String? timeText;
  final List<String> attachments; // image URLs
  final String? creatorAvatarUrl;
  final bool alignRight;
  final String? creatorName; // kept for API compatibility
  final String? statusType; // e.g. 'Open', 'In Progress', 'Resolved', 'Closed'
  final bool showApprovalActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const StatusUpdateBubble({
    super.key,
    required this.description,
    this.timeText,
    this.attachments = const [],
    this.creatorAvatarUrl,
    this.alignRight = false,
    this.creatorName,
    this.statusType,
    this.showApprovalActions = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const avatarWithSpacing = 40.0; // ~32 avatar + 8 spacing
    final maxWidth = (screenWidth * 0.86) - avatarWithSpacing;

    // Filter out any empty URLs
    final validAttachments = attachments.where((u) => u.trim().isNotEmpty).toList();

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
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Text content ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: "Status Update" + badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Status Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            if (statusType != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(statusType!)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _statusColor(statusType!),
                                      width: 1),
                                ),
                                child: Text(
                                  statusType!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(statusType!),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.3,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        // Time
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
                        // Approval Actions
                        if (showApprovalActions) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onReject,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: onApprove,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Bottom padding when no images follow
                        if (validAttachments.isEmpty)
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ── Image previews (inside bubble) ───────────────────
                  if (validAttachments.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    // Single image: full-width tall preview
                    if (validAttachments.length == 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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

                    // 3+ images: first large + scrollable strip below
                    if (validAttachments.length >= 3) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
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
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
          if (alignRight) ...[
            const SizedBox(width: 8),
            _buildAvatar(creatorAvatarUrl),
          ],
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
              heroTagPrefix: 'status_',
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
            tag: 'status_${url}_$index',
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

  Color _statusColor(String type) {
    switch (type.toLowerCase()) {
      case 'open':
        return const Color(0xFF3EA8D0);
      case 'assigned':
        return const Color(0xFF9C27B0);
      case 'in progress':
        return const Color(0xFFFFA726);
      case 'resolved':
        return const Color(0xFF66BB6A);
      case 'closed':
        return const Color(0xFF78909C);
      case 'pending resolution':
        return const Color(0xFFAB47BC);
      case 'pending close':
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF3EA8D0);
    }
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
}
