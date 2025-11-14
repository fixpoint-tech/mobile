import 'package:flutter/foundation.dart';
import '../model/notification_model.dart';

/// Controller for managing notifications
class NotificationController {
  // ValueNotifier to observe notifications list
  final ValueNotifier<List<NotificationModel>> notifications =
      ValueNotifier<List<NotificationModel>>([]);

  // Simulated unread count
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Load notifications (simulated - replace with API call)
  Future<void> loadNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Sample notifications for demonstration
    final sampleNotifications = [
      NotificationModel(
        id: '1',
        title: 'New Issue Assigned',
        message:
            'You have been assigned to issue #1234 - AC not working in Domino\'s Kottawa outlet.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.assignment,
        isRead: false,
        relatedId: '1234',
        actionUrl: '/tickets',
      ),
      NotificationModel(
        id: '2',
        title: 'Issue Status Updated',
        message: 'Issue #1230 has been marked as "Done" by the technician.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.statusUpdate,
        isRead: false,
        relatedId: '1230',
        actionUrl: '/tickets',
      ),
      NotificationModel(
        id: '3',
        title: 'New Comment',
        message:
            'Technician added a comment: "Refrigeration unit replaced successfully."',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.comment,
        isRead: true,
        relatedId: '1228',
        actionUrl: '/tickets',
      ),
      NotificationModel(
        id: '4',
        title: 'New User Added',
        message: 'A new GPM "Kamal Silva" has been added to the network.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.userManagement,
        isRead: true,
        relatedId: 'user_123',
        actionUrl: '/gpms',
      ),
      NotificationModel(
        id: '5',
        title: 'Critical Issue Reported',
        message:
            'High priority issue reported at Domino\'s Colombo 7 - Power outage affecting operations.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.issue,
        isRead: true,
        relatedId: '1235',
        actionUrl: '/tickets',
      ),
      NotificationModel(
        id: '6',
        title: 'System Maintenance',
        message:
            'Scheduled system maintenance will occur tonight from 11 PM to 1 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        title: 'Issue Reassigned',
        message:
            'Issue #1232 has been reassigned from Technician A to Technician B.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.assignment,
        isRead: true,
        relatedId: '1232',
        actionUrl: '/tickets',
      ),
      NotificationModel(
        id: '8',
        title: 'Outlet Added',
        message:
            'New outlet "Domino\'s Pizza Kandy" has been added to the network.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.userManagement,
        isRead: true,
        relatedId: 'outlet_456',
        actionUrl: '/outlets',
      ),
    ];

    notifications.value = sampleNotifications;
    _updateUnreadCount();
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final updatedList = notifications.value.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    notifications.value = updatedList;
    _updateUnreadCount();
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    final updatedList = notifications.value
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    notifications.value = updatedList;
    _updateUnreadCount();
  }

  /// Delete a notification
  void deleteNotification(String notificationId) {
    final updatedList = notifications.value
        .where((notification) => notification.id != notificationId)
        .toList();

    notifications.value = updatedList;
    _updateUnreadCount();
  }

  /// Clear all notifications
  void clearAll() {
    notifications.value = [];
    _updateUnreadCount();
  }

  /// Add a new notification (for when new notifications arrive)
  void addNotification(NotificationModel notification) {
    notifications.value = [notification, ...notifications.value];
    _updateUnreadCount();
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.value.where((n) => !n.isRead).length;
  }

  /// Dispose resources
  void dispose() {
    notifications.dispose();
    unreadCount.dispose();
  }
}
