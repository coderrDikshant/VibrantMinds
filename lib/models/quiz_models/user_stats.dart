import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

/// Represents a user's quiz attempt statistics, including performance metrics
/// and metadata used for user stats and leaderboard rankings.
class UserStats {
  /// Unique identifier for the user (e.g., Firebase Auth UID).
  final String userId;

  /// User's display name.
  final String name;

  /// User's email address, used for leaderboard identification.
  final String email;

  /// Category of the quiz (e.g., Math, Science).
  final String category;

  /// Unique identifier for the quiz, used for leaderboard grouping.
  final String quizId;

  /// Difficulty level of the quiz (e.g., easy, medium, hard).
  final String difficulty;

  /// List of questions attempted in the quiz.
  final List<Question> questions;

  /// Time taken to complete the quiz in seconds.
  final int timeTakenSeconds;

  /// Score achieved in the quiz, used for leaderboard rankings.
  final int score;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Number of correct answers.
  final int correctAnswers;

  /// Number of incorrect answers.
  final int wrongAnswers;

  /// Timestamp of the quiz attempt, used for leaderboard tie-breaking.
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

  /// Converts the UserStats object to a Firestore-compatible map.
  /// Includes all fields for saving to userStats/quizAttempts and
  /// supports quiz_results collection (userEmail, userName, quizId, score, timestamp).
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

  /// Creates a UserStats object from a Firestore document.
  /// Handles null values and provides defaults for missing fields.
  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    return UserStats(
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      category: data['category'] as String? ?? '',
      quizId: data['quizId'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? '',
      questions: (data['questions'] as List<dynamic>? ?? [])
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
      timeTakenSeconds: data['timeTakenSeconds'] as int? ?? 0,
      score: data['score'] as int? ?? 0,
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      correctAnswers: data['correctAnswers'] as int? ?? 0,
      wrongAnswers: data['wrongAnswers'] as int? ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}