import 'package:flutter/material.dart';

class PettyCashRequestBubble extends StatelessWidget {
  final String amountLabel; // e.g. "Rs. 6500.00"
  final String timeText; // e.g. "9:50 AM"
  final bool alignRight;
  final String? creatorAvatarUrl;
  final String? creatorName;
  final String? description;
  final String? status;
  final String? senderInfoText; // e.g. "8:58 AM From GPM"
  final VoidCallback? onReject;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;
  final VoidCallback? onUndo;

  const PettyCashRequestBubble({
    super.key,
    required this.amountLabel,
    required this.timeText,
    this.alignRight = false,
    this.creatorAvatarUrl,
    this.creatorName,
    this.description,
    this.status,
    this.senderInfoText,
    this.onReject,
    this.onAccept,
    this.onCancel,
    this.onUndo,
  });

  static const _timeColor = Color(0xFF3EA8D0);

  bool get _isApproved => status?.toLowerCase() == 'approved';
  bool get _isRejected => status?.toLowerCase() == 'rejected';
  bool get _isPending => status?.toLowerCase() == 'pending' || status == null;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const avatarSize = 32.0;
    const avatarSpacing = 8.0;
    final maxWidth = (screenWidth * 0.86) - avatarSize - avatarSpacing;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar on left
              if (!alignRight) ...[
                _buildAvatar(creatorAvatarUrl),
                const SizedBox(width: avatarSpacing),
              ],

              // Bubble
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE6F0),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Title ──
                        const Text(
                          'Requested Petty Cash',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 3),

                        // ── Amount ──
                        Text(
                          amountLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // ── Optional description ──
                        if (description != null &&
                            description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // ── Time row ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_outlined,
                              size: 15,
                              color: _timeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _timeColor,
                              ),
                            ),
                          ],
                        ),

                        // ── RESOLVED STATE ──
                        if (_isApproved || _isRejected) ...[
                          const SizedBox(height: 10),
                          const Text(
                            '· · ·',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFAAAAAA),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isApproved
                                    ? Icons.check_box_outlined
                                    : Icons.cancel_outlined,
                                size: 17,
                                color: _isApproved
                                    ? _timeColor
                                    : const Color(0xFFFF7489),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  _isApproved
                                      ? 'Cash Request Accepted'
                                      : 'Cash Request Rejected',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isApproved
                                        ? _timeColor
                                        : const Color(0xFFFF7489),
                                  ),
                                ),
                              ),
                              if (onUndo != null) ...[
                                const SizedBox(width: 8),
                                _buildSmallOutlinedButton(
                                  label: 'Undo',
                                  color: const Color(0xFF666666),
                                  borderColor: const Color(0xFFCCCCCC),
                                  bgColor: Colors.white,
                                  onPressed: onUndo!,
                                ),
                              ],
                            ],
                          ),
                        ],

                        // ── PENDING: action buttons ──
                        if (_isPending &&
                            (onReject != null ||
                                onAccept != null ||
                                onCancel != null)) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Technician: Cancel
                              if (onCancel != null) ...[
                                _buildSmallOutlinedButton(
                                  label: 'Cancel',
                                  color: const Color(0xFF1A1A1A),
                                  borderColor: const Color(0xFFCCCCCC),
                                  bgColor: Colors.white,
                                  onPressed: onCancel!,
                                ),
                              ],
                              // Manager: Reject
                              if (onReject != null) ...[
                                _buildSmallOutlinedButton(
                                  label: 'Close',
                                  color: const Color(0xFF1A1A1A),
                                  borderColor: const Color(0xFFCCCCCC),
                                  bgColor: Colors.white,
                                  onPressed: onReject!,
                                ),
                                const SizedBox(width: 6),
                              ],
                              // Manager: Accept
                              if (onAccept != null) ...[
                                _buildFilledButton(
                                  label: 'Accept',
                                  onPressed: onAccept!,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar on right
              if (alignRight) ...[
                const SizedBox(width: avatarSpacing),
                _buildAvatar(creatorAvatarUrl),
              ],
            ],
          ),

          // ── Sender info footer ──
          if (senderInfoText != null) ...[
            const SizedBox(height: 3),
            Padding(
              padding: EdgeInsets.only(
                left: alignRight ? 0 : avatarSize + avatarSpacing,
                right: alignRight ? avatarSize + avatarSpacing : 0,
              ),
              child: Text(
                senderInfoText!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallOutlinedButton({
    required String label,
    required Color color,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: color,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFilledButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _timeColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFFFD6DC),
      backgroundImage:
          (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.person, size: 18, color: Color(0xFFFF7489))
          : null,
    );
  }
}
