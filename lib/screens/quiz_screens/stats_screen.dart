import 'package:flutter/material.dart';
import '../../../models/quiz_models/user_stats.dart';

class StatsScreen extends StatelessWidget {
  final UserStats stats;

  const StatsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildHeaderInfo(primaryColor),
            const SizedBox(height: 16),
            _buildScoreSummary(primaryColor),
            const Divider(height: 32, thickness: 1.5),
            const Text(
              'Questions Overview:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...stats.questions.map((q) => _buildQuestionCard(q, primaryColor)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("User", "${stats.name} (${stats.email})", primaryColor),
        _buildInfoRow("Category", stats.category, primaryColor),
        _buildInfoRow("Quiz ID", stats.quizId, primaryColor),
        _buildInfoRow("Difficulty", stats.difficulty, primaryColor),
        _buildInfoRow("Time Taken", "${stats.timeTakenSeconds} seconds", primaryColor),
      ],
    );
  }

  Widget _buildScoreSummary(Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Score: ${stats.score} / ${stats.totalQuestions}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreChip('Correct', stats.correctAnswers, Colors.green),
                  _buildScoreChip('Wrong', stats.wrongAnswers, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(text: "$title: ", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, int count, Color chipColor) {
    return Chip(
      backgroundColor: chipColor.withOpacity(0.2),
      label: Text(
        '$label: $count',
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(question, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Your Answer: ${question.selectedOption ?? "Not Answered"}',
                style: TextStyle(
                  color: question.selectedOption == question.correctAnswer ? Colors.green : Colors.red,
                )),
            Text('Correct Answer: ${question.correctAnswer}'),
            if (question.explanation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Explanation: ${question.explanation}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}