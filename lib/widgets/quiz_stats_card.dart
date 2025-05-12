import 'package:flutter/material.dart';

class QuizStatsCard extends StatelessWidget {
  final String category;
  final String quizId;
  final String difficulty;
  final int attempts;
  final double averageScore;

  const QuizStatsCard({
    super.key,
    required this.category,
    required this.quizId,
    required this.difficulty,
    required this.attempts,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz: ${category.toUpperCase()} - $quizId',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${difficulty.toUpperCase()}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total Attempts: $attempts',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Average Score: ${averageScore.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}