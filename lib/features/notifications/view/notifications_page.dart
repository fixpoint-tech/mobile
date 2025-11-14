import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../model/notification_model.dart';
import '../controller/notification_controller.dart';

/// Notifications page showing all user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _controller = NotificationController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF292A2D),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: const Color(0xFF292A2D),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF292A2D)),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _controller.markAllAsRead();
              } else if (value == 'clear_all') {
                _showClearAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text(
                  'Mark all as read',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 14),
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Color(0xFFFF7489),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Toggle
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Show unread only',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showUnreadOnly,
                  onChanged: (value) {
                    setState(() {
                      _showUnreadOnly = value;
                    });
                  },
                  activeColor: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notifications List
          Expanded(
            child: ValueListenableBuilder<List<NotificationModel>>(
              valueListenable: _controller.notifications,
              builder: (context, notifications, _) {
                // Filter based on toggle
                final displayNotifications = _showUnreadOnly
                    ? notifications.where((n) => !n.isRead).toList()
                    : notifications;

                if (displayNotifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 80,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showUnreadOnly
                              ? 'No unread notifications'
                              : 'No notifications yet',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: displayNotifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notification = displayNotifications[index];
                    return _NotificationCard(
                      notification: notification,
                      onTap: () {
                        _controller.markAsRead(notification.id);
                        if (notification.actionUrl != null) {
                          Navigator.of(
                            context,
                          ).pushNamed(notification.actionUrl!);
                        }
                      },
                      onDelete: () {
                        _controller.deleteNotification(notification.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear All Notifications',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all notifications? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _controller.clearAll();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF7489),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual notification card widget
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.critical,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.secondaryLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon based on notification type
                  _buildNotificationIcon(),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  color: AppColors.textTitle,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.issue:
        iconData = Icons.report_problem_outlined;
        iconColor = AppColors.accent;
        break;
      case NotificationType.assignment:
        iconData = Icons.assignment_outlined;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.comment:
        iconData = Icons.chat_bubble_outline;
        iconColor = AppColors.accent200;
        break;
      case NotificationType.statusUpdate:
        iconData = Icons.update;
        iconColor = AppColors.success;
        break;
      case NotificationType.userManagement:
        iconData = Icons.people_outline;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.system:
        iconData = Icons.settings_outlined;
        iconColor = AppColors.textSecondary;
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = AppColors.secondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
