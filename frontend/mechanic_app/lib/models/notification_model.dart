import 'package:flutter/material.dart';

enum NotificationType {
  newJob,
  jobCompleted,
  paymentReceived,
  newRating,
  appUpdate,
  maintenanceReminder,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isUnread;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isUnread = true,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      isUnread: json['is_unread'] ?? true,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'is_unread': isUnread,
      'data': data,
    };
  }

  IconData get icon {
    switch (type) {
      case NotificationType.newJob:
        return Icons.work_outline;
      case NotificationType.jobCompleted:
        return Icons.check_circle_outline;
      case NotificationType.paymentReceived:
        return Icons.payment_outlined;
      case NotificationType.newRating:
        return Icons.star_outline;
      case NotificationType.appUpdate:
        return Icons.update_outlined;
      case NotificationType.maintenanceReminder:
        return Icons.event_outlined;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
