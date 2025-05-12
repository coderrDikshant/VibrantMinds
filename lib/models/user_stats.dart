import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UserStats.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserStats(
      userId: userId,
      name: data['name']?.toString() ?? 'Unknown',
      email: data['email']?.toString() ?? 'Unknown',
      category: data['category']?.toString().toLowerCase() ?? '',
      quizId: data['quizId']?.toString() ?? '',
      difficulty: data['difficulty']?.toString().toLowerCase() ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      correctAnswers: (data['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (data['wrongAnswers'] as num?)?.toInt() ?? 0,
    );
  }
}