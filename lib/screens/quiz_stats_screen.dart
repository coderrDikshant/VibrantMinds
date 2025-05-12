import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../widgets/quiz_stats_card.dart';

class QuizStatsScreen extends StatelessWidget {
  final List<UserStats> stats;

  const QuizStatsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Group stats by quiz (category + quizId + difficulty)
    final quizStats = <String, List<UserStats>>{};
    for (var stat in stats) {
      final key = '${stat.category}-${stat.quizId}-${stat.difficulty}';
      quizStats.putIfAbsent(key, () => []).add(stat);
    }

    debugPrint('QuizStatsScreen: Grouped into ${quizStats.length} quizzes');

    final quizSummary = quizStats.entries.map((entry) {
      final stats = entry.value;
      final averageScore = stats.isEmpty
          ? 0.0
          : stats
          .map((s) => (s.score / s.totalQuestions) * 100)
          .reduce((a, b) => a + b) /
          stats.length;
      debugPrint(
          'Quiz: ${stats.first.category}, ${stats.first.quizId}, '
              '${stats.first.difficulty}, Attempts: ${stats.length}, '
              'Avg Score: ${averageScore.toStringAsFixed(2)}%');
      return {
        'category': stats.first.category,
        'quizId': stats.first.quizId,
        'difficulty': stats.first.difficulty,
        'attempts': stats.length,
        'averageScore': averageScore,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Stats')),
      body: quizSummary.isEmpty
          ? const Center(child: Text('No quiz stats available'))
          : ListView.builder(
        itemCount: quizSummary.length,
        itemBuilder: (context, index) {
          final summary = quizSummary[index];
          return QuizStatsCard(
            category: summary['category'] as String,
            quizId: summary['quizId'] as String,
            difficulty: summary['difficulty'] as String,
            attempts: summary['attempts'] as int,
            averageScore: summary['averageScore'] as double,
          );
        },
      ),
    );
  }
}