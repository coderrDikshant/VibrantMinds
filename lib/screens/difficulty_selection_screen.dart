import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';
import '../../widgets/difficulty_card.dart';
import '../../theme/vibrant_theme.dart';
import 'quiz_selection_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final Category category;

  const DifficultySelectionScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Difficulty - ${category.name}',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: VibrantTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: VibrantTheme.gradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: AppConstants.difficulties.length,
          itemBuilder: (context, index) {
            final difficulty = AppConstants.difficulties[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DifficultyCard(
                difficulty: difficulty,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizSelectionScreen(
                        userId: userId,
                        name: name,
                        email: email,
                        category: category,
                        difficulty: difficulty,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}