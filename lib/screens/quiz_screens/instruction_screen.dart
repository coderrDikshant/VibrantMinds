import 'package:flutter/material.dart';
import '../../models/quiz_models/category.dart';
import '../../models/quiz_models/quiz.dart';
import '../../screens/quiz_screens/quiz_screen.dart';
import '../../../theme/vibrant_theme.dart';

class InstructionScreen extends StatelessWidget {
  final String name;
  final String email;
  final Category category;
  final Quiz quiz;
  final String difficulty;

  const InstructionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.category,
    required this.quiz,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: VibrantTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Instructions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: VibrantTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInstructionText('• Each question has one correct answer.', theme),
                _buildInstructionText('• You can mark a question for review.', theme),
                _buildInstructionText('• Use the map icon to navigate between questions.', theme),
                _buildInstructionText('• Once started, you cannot go back until submission.', theme),
                _buildInstructionText('• Quiz will auto-submit after the timer runs out.', theme),
                _buildInstructionText('• No tab switching and taking screenshots allowed.', theme),

                const SizedBox(height: 20),
                Text(
                  'Question Status Colors:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildColoredInstruction('Answered: Green', Colors.green.shade600, theme),
                _buildColoredInstruction('Marked for Review: Yellow', Colors.amber.shade600, theme),
                _buildColoredInstruction('Skipped: Red', Colors.red.shade600, theme),
                _buildColoredInstruction('Unvisited: White', theme.colorScheme.surface, theme, textColor: Colors.black87),

                const Spacer(),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VibrantTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            name: name,
                            email: email,
                            category: category,
                            quiz: quiz,
                            difficulty: difficulty,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Quiz', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildColoredInstruction(String text, Color bgColor, ThemeData theme, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: textColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}