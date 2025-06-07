import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final List<dynamic> content; // CHANGED: Type from String to List<dynamic> for Quill Delta JSON
  int likes;
  bool userLiked;
  int commentCount;

  Blog({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.content, // CHANGED: Type definition here
    this.likes = 0,
    this.userLiked = false,
    this.commentCount = 0,
  });

  factory Blog.fromFirestore(Map<String, dynamic> data, String id) {
    return Blog(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'Anonymous',
      imageUrl: data['imageUrl'] ?? '',
      // CHANGED: Safely cast content from Firestore as List<dynamic>
      content: List<dynamic>.from(data['content'] ?? []),
      likes: data['likes'] ?? 0,
      // userLiked is client-side, so it might not always come from Firestore directly.
      // Keeping it here for now as per your original model, but its value
      // will be explicitly set in FirestoreService.getBlogs().
      userLiked: data['userLiked'] ?? false,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'content': content, // This will correctly be a List<dynamic> (Quill Delta JSON)
      'likes': likes,
      'commentCount': commentCount,
      // Removed 'userLiked' as it's typically client-side state and not usually
      // stored directly in Firestore for consistency across multiple users.
    };
  }
}
