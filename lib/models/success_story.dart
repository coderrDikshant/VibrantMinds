import 'package:cloud_firestore/cloud_firestore.dart';

class SuccessStory {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int likes;
  final int commentCount;
  final DateTime timestamp;

  // New field to track if the user liked this story (default false)
  bool userLiked;

  SuccessStory({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.likes,
    required this.commentCount,
    required this.timestamp,
    this.userLiked = false,
  });

  factory SuccessStory.fromFirestore(Map<String, dynamic> data, String id) {
    return SuccessStory(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likes: data['likes'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userLiked: false, // default false, will be updated later
    );
  }
}
