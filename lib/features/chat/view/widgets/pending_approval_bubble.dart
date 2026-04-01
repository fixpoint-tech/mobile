import 'package:flutter/material.dart';

/// Chat bubble shown when a technician requests Resolved or Closed approval.
/// Styled identically to [PettyCashRequestBubble].
class PendingApprovalBubble extends StatelessWidget {
  /// 'Pending Resolution' or 'Pending Close'
  final String pendingType;

  final String timeText;
  final bool alignRight;
  final String? creatorAvatarUrl;
  final String? requesterName;
  final String? senderInfoText; // e.g. "9:50 AM From Technician"

  /// Branch Manager / Maintenance Executive only
  final VoidCallback? onReject;
  final VoidCallback? onApprove;

  const PendingApprovalBubble({
    super.key,
    required this.pendingType,
    required this.timeText,
    this.requesterName,
    this.alignRight = false,
    this.creatorAvatarUrl,
    this.senderInfoText,
    this.onReject,
    this.onApprove,
  });

  static const _timeColor = Color(0xFF3EA8D0);

  bool get _isResolution => pendingType == 'Pending Resolution';

  String get _title =>
      _isResolution ? 'Requested Resolution' : 'Requested Close';

  String get _description => _isResolution
      ? 'Technician requests to mark this issue as Resolved.'
      : 'Technician requests to close this issue.';

  Color get _accentColor =>
      _isResolution ? const Color(0xFF66BB6A) : const Color(0xFF78909C);

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
              // Avatar left
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
                        // ── Title row with accent dot ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: _accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // ── Description ──
                        Text(
                          _description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6B6B),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── "Awaiting Approval" chip ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFAB47BC).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFAB47BC), width: 1),
                          ),
                          child: const Text(
                            'Awaiting Approval',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFAB47BC),
                            ),
                          ),
                        ),

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

                        // ── Action buttons (Manager / Executive only) ──
                        if (onReject != null || onApprove != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onReject != null) ...[
                                _buildOutlinedButton(
                                  label: 'Reject',
                                  onPressed: onReject!,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (onApprove != null)
                                _buildFilledButton(
                                  label: 'Approve',
                                  color: _accentColor,
                                  onPressed: onApprove!,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar right
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

  Widget _buildOutlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFFCCCCCC)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
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
