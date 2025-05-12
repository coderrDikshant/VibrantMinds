import 'package:flutter/material.dart';
import '../models/user_stats.dart';

class UserStatsCard extends StatelessWidget {
  final UserStats stats;

  const UserStatsCard({super.key, required this.stats});

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
              stats.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stats.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Quiz: ${stats.category.toUpperCase()} - ${stats.quizId}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Difficulty: ${stats.difficulty.toUpperCase()}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Score: ${stats.score}/${stats.totalQuestions} '
                  '(${((stats.score / stats.totalQuestions) * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Completed: ${stats.timestamp.toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}