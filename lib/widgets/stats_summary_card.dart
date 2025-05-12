import 'package:flutter/material.dart';

class StatsSummaryCard extends StatelessWidget {
  final int totalUsers;
  final int totalQuizzes;
  final double averageScore;

  const StatsSummaryCard({
    super.key,
    required this.totalUsers,
    required this.totalQuizzes,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiz Stats Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total Users: $totalUsers',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Quizzes Attempted: $totalQuizzes',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
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