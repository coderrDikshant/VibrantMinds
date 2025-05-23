class Quiz {
  final String id;
  final String set;
  final String difficulty;
  final String title;

  Quiz({
    required this.id,
    required this.set,
    required this.difficulty,
    required this.title,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      title: data['title'] ?? '',
      set: data['set'] ?? '',
      difficulty: data['difficulty'] ?? '',
    );
  }
}