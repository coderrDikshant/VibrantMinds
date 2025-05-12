class Question {
  final String category;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String set;
  final String difficulty;

  Question({
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.set,
    required this.difficulty,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'set': set,
      'difficulty': difficulty,
    };
  }
}