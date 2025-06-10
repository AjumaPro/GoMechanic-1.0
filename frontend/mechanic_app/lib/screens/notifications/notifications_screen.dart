import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gomechanic_mechanic/models/notification_model.dart';
import 'package:gomechanic_mechanic/models/job.dart';
import 'package:gomechanic_mechanic/providers/notification_provider.dart';
import 'package:gomechanic_mechanic/screens/jobs/job_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Mark notification as read
    await context.read<NotificationProvider>().markAsRead(notification.id);

    // Navigate based on notification type
    if (!mounted) return;

    switch (notification.type) {
      case NotificationType.newJob:
      case NotificationType.jobCompleted:
        if (notification.data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JobDetailsScreen(job: Job.fromJson(notification.data!)),
            ),
          );
        }
        break;
      case NotificationType.paymentReceived:
        // TODO: Navigate to earnings details
        break;
      case NotificationType.newRating:
        if (notification.data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JobDetailsScreen(job: Job.fromJson(notification.data!)),
            ),
          );
        }
        break;
      case NotificationType.appUpdate:
        // TODO: Navigate to update screen
        break;
      case NotificationType.maintenanceReminder:
        // TODO: Navigate to maintenance screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: () {
                    provider.markAllAsRead();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchNotifications();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        context
            .read<NotificationProvider>()
            .deleteNotification(notification.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                notification.isUnread ? Colors.blue : Colors.grey[300],
            child: Icon(
              notification.icon,
              color: notification.isUnread ? Colors.white : Colors.grey[600],
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isUnread
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                notification.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          subtitle: Text(
            notification.message,
            style: TextStyle(
              color: notification.isUnread ? Colors.black87 : Colors.grey[600],
            ),
          ),
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }
}
