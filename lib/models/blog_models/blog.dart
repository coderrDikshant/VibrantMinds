class Blog {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String content;
  int likes;
  bool userLiked;
  int commentCount;

  Blog({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.content,
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
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      userLiked: data['userLiked'] ?? false,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'content': content,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}