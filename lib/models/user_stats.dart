import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';  // Your Question model

class UserStats {
  final String userId;
  final String name;
  final String email;
  final String category;
  final String quizId;
  final String difficulty;
  final List<Question> questions;
  final int timeTakenSeconds;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final DateTime timestamp;

  UserStats({
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
    required this.quizId,
    required this.difficulty,
    required this.questions,
    required this.timeTakenSeconds,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'category': category,
      'quizId': quizId,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeTakenSeconds': timeTakenSeconds,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    return UserStats(
      userId: data['userId'],
      name: data['name'],
      email: data['email'],
      category: data['category'],
      quizId: data['quizId'],
      difficulty: data['difficulty'],
      questions: (data['questions'] as List<dynamic>)
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
      timeTakenSeconds: data['timeTakenSeconds'],
      score: data['score'],
      totalQuestions: data['totalQuestions'],
      correctAnswers: data['correctAnswers'],
      wrongAnswers: data['wrongAnswers'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
