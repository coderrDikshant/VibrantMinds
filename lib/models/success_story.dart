import 'package:cloud_firestore/cloud_firestore.dart';

class SuccessStory {
  final String id;
  String title;
  String description;
  String imageUrl;
  int likes;
  int commentCount;
  bool userLiked;
  Timestamp timestamp;

  SuccessStory({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.likes = 0,
    this.commentCount = 0,
    this.userLiked = false,
    required this.timestamp,
  });

  factory SuccessStory.fromFirestore(Map<String, dynamic> data, String id) {
    return SuccessStory(
      id: id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      userLiked: false, // Set in FirestoreService
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'likes': likes,
    'commentCount': commentCount,
    'timestamp': timestamp,
  };
}