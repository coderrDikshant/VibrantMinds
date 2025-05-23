import 'package:flutter/material.dart';
import '../../models/quiz_models/user_stats.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz: ${stats.category.toUpperCase()} - ${stats.quizId}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Difficulty: ${stats.difficulty.toUpperCase()}'),
            Text('Score: ${stats.score} / ${stats.totalQuestions}'),
            Text('Correct Answers: ${stats.correctAnswers}'),
            Text('Wrong Answers: ${stats.wrongAnswers}'),
            Text('Date: ${stats.timestamp.toString().substring(0, 16)}'),
          ],
        ),
      ),
    );
  }
}