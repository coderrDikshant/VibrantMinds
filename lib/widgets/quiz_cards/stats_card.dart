import 'package:flutter/material.dart';
import '../../models/quiz_models/user_stats.dart';
import '../../theme/vibrant_theme.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9F9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz: ${stats.category.toUpperCase()} - ${stats.quizId}',
              style: VibrantTheme.themeData.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${stats.difficulty.toUpperCase()}',
              style: VibrantTheme.themeData.textTheme.bodyMedium,
            ),
            Text(
              'Score: ${stats.score} / ${stats.totalQuestions}',
              style: VibrantTheme.themeData.textTheme.bodyMedium,
            ),
            Text(
              'Correct Answers: ${stats.correctAnswers}',
              style: VibrantTheme.themeData.textTheme.bodyMedium,
            ),
            Text(
              'Wrong Answers: ${stats.wrongAnswers}',
              style: VibrantTheme.themeData.textTheme.bodyMedium,
            ),
            Text(
              'Date: ${stats.timestamp.toString().substring(0, 16)}',
              style: VibrantTheme.themeData.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}