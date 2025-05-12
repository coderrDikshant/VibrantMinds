import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $questionNumber: ${question.question}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (value) => onAnswerSelected(value!),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}