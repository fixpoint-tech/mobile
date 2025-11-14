/// Notification model representing a system notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? relatedId; // ID of related issue/ticket/user
  final String? actionUrl; // Deep link or route to navigate

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.relatedId,
    this.actionUrl,
  });

  /// Create a copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? relatedId,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'relatedId': relatedId,
      'actionUrl': actionUrl,
    };
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}

/// Types of notifications in the system
enum NotificationType {
  general,
  issue,
  assignment,
  comment,
  statusUpdate,
  userManagement,
  system,
}
