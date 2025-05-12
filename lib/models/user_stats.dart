class UserStats {
  final String userId;
  final String name;
  final String email;
  final String category;
  final String quizId;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;
  final int correctAnswers;
  final int wrongAnswers;

  UserStats({
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
    required this.quizId,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'category': category,
      'quizId': quizId,
      'difficulty': difficulty,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
    };
  }
}