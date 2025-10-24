import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName; // who sent this message
  final String receiverName; // who this message was sent to
  final String time; // preformatted like "8:58 AM"
  final String? meAvatarUrl; // current user's avatar (same across account)
  final String? otherAvatarUrl; // the other participant avatar (per message)

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.receiverName,
    required this.time,
    this.meAvatarUrl,
    this.otherAvatarUrl,
  });

  Widget _buildAvatar({required bool forSender}) {
    final String? url = forSender ? meAvatarUrl : otherAvatarUrl;
    final Color fallbackColor = forSender
        ? const Color(0xFF5DADE2)
        : const Color(0xFFFF7489);

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
        backgroundColor: fallbackColor,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: fallbackColor,
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.start, // top-align avatar with bubble
        children: [
          // Left-side avatar for received messages (other user)
          if (!isMe) ...[
            Align(
              alignment: Alignment.topCenter,
              child: _buildAvatar(forSender: false),
            ),
            const SizedBox(width: 10),
          ],

          // Bubble + meta
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFFFF7489)
                      : const Color(0xFF5DADE2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  isMe ? '$time To $receiverName' : '$time From $senderName',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ),

          // Right-side avatar for sent messages (current user)
          if (isMe) ...[
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.topCenter,
              child: _buildAvatar(forSender: true),
            ),
          ],
        ],
      ),
    );
  }
}
