import 'package:flutter/material.dart';

import '../theme/vibrant_theme.dart';

class QuestionMapScreen extends StatelessWidget {
  final int totalQuestions;
  final Map<int, String> questionStatus;
  final Function(int) onQuestionSelected;

  const QuestionMapScreen({
    super.key,
    required this.totalQuestions,
    required this.questionStatus,
    required this.onQuestionSelected,
  });

  Color _getColorForStatus(String? status, BuildContext context) {
    final theme = VibrantTheme.themeData;
    switch (status) {
      case 'answered':
        return Colors.green.shade600; // vibrant green
      case 'review':
        return Colors.amber.shade600; // vibrant amber/orange-yellow
      case 'skipped':
        return Colors.red.shade600; // vibrant red
      case 'unvisited':
      default:
        return theme.colorScheme.surface; // typically white or light background
    }
  }

  Color _getTextColor(String? status) {
    switch (status) {
      case 'answered':
      case 'review':
      case 'skipped':
        return Colors.white;
      case 'unvisited':
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Map"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: totalQuestions,
          itemBuilder: (context, index) {
            final status = questionStatus[index];
            final color = _getColorForStatus(status, context);
            final textColor = _getTextColor(status);

            return GestureDetector(
              onTap: () => onQuestionSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
