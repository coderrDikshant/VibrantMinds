class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String difficulty;
  final String set;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.set,
  });

  factory Question.fromFirestore(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      set: data['set'] ?? '',
    );
  }
}