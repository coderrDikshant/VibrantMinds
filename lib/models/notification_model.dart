// models/notification_model.dart
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 0)
class NotificationModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  DateTime receivedAt;

  NotificationModel({
    required this.title,
    required this.body,
    required this.receivedAt,
  });
}
