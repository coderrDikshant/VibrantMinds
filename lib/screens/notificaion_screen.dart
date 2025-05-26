import 'package:flutter/material.dart';
import '../../theme/vibrant_theme.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> notifications = [
    {
      'title': 'New Quiz Added!',
      'body': 'Check out the latest Flutter quiz in the app now!',
    },
    {
      'title': 'Weekly Summary',
      'body': 'You answered 40 questions correctly this week. Great job!',
    },
    {
      'title': 'Profile Reminder',
      'body': 'Complete your profile to get personalized recommendations.',
    },
  ];

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications at the moment.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification['title']! + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Clear', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            onDismissed: (direction) {
              _removeNotification(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification cleared')),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  notification['title'] ?? '',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                subtitle: Text(
                  notification['body'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                leading: const Icon(Icons.notifications, color: VibrantTheme.primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }
}
