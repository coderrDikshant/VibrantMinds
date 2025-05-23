import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime timestamp;
  int likes;
  int dislikes;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.timestamp,
    required this.likes,
    required this.dislikes,
  });

  factory Blog.fromFirestore(Map<String, dynamic> data, String id) {
    return Blog(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
    );
  }
}
