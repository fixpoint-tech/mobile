import 'package:flutter/material.dart';

class PettyCashRequestBubble extends StatelessWidget {
  final String amountLabel; // e.g. "Rs. 6500.00"
  final String timeText; // e.g. "9:50 AM"
  final bool alignRight;
  final String? creatorAvatarUrl;
  final VoidCallback? onClose;
  final VoidCallback? onAccept;
  final VoidCallback? onRequestCash;

  const PettyCashRequestBubble({
    super.key,
    required this.amountLabel,
    required this.timeText,
    this.alignRight = false,
    this.creatorAvatarUrl,
    this.onClose,
    this.onAccept,
    this.onRequestCash,
  });

  static const _timeColor = Color(0xFF3EA8D0);
  static const _requestIconAsset = 'assets/icons/mail-icon.png'; // <-- updated

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
                      'Requested Petty Cash',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      amountLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: _timeColor,
                        ),
                        const SizedBox(width: 6),
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
                    const SizedBox(height: 12),
                    // Buttons in one line (reduced size)
                    Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: onClose,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF727272),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 4,
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _timeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 6,
                          child: OutlinedButton.icon(
                            onPressed: onRequestCash,
                            icon: Image.asset(
                              _requestIconAsset,
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: Color(0xFF727272),
                              ),
                            ),
                            label: const Text(
                              'Request',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF727272),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
