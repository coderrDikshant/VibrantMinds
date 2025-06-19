import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/notification_model.dart';
import '../../theme/vibrant_theme.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NotificationModel>('notificationsBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<NotificationModel> box, _) {
          final notifications = box.values.toList().reversed.toList();

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications at the moment.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.key.toString()),
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
                onDismissed: (_) {
                  notification.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification cleared')),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(notification.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    subtitle: Text(notification.body,
                        style: Theme.of(context).textTheme.bodyMedium),
                    leading: const Icon(Icons.notifications,
                        color: VibrantTheme.primaryColor),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
