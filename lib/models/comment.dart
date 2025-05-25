import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String authorEmail;
  final String authorName;
  final DateTime timestamp;
  int likes;
  bool userLiked;

  Comment({
    required this.id,
    required this.content,
    required this.authorEmail,
    required this.authorName,
    required this.timestamp,
    this.likes = 0,
    this.userLiked = false,
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      content: data['content'] ?? '',
      authorEmail: data['authorEmail'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      userLiked: data['userLiked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }
}