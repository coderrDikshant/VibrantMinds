import 'package:flutter/material.dart';
import '../../theme/vibrant_theme.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
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
          return Card(
            child: ListTile(
              title: Text(
                notifications[index]['title'] ?? '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: Text(
                notifications[index]['body'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              leading: const Icon(Icons.notifications, color: VibrantTheme.primaryColor),
            ),
          );
        },
      ),
    );
  }
}
