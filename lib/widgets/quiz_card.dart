import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          'Quiz ${quiz.id} (${quiz.set})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Difficulty: ${quiz.difficulty.toUpperCase()}'),
        onTap: onTap,
      ),
    );
  }
}