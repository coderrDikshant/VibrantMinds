class Quiz {
  final String id;
  final String set;
  final String difficulty;

  Quiz({
    required this.id,
    required this.set,
    required this.difficulty,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      set: data['set'] ?? '',
      difficulty: data['difficulty'] ?? '',
    );
  }
}