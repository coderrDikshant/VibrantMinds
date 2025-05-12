import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../utils/constants.dart';
import '../../widgets/difficulty_card.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text('Select Difficulty - ${category.name}')),
      body: ListView.builder(
        itemCount: AppConstants.difficulties.length,
        itemBuilder: (context, index) {
          final difficulty = AppConstants.difficulties[index];
          return DifficultyCard(
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
          );
        },
      ),
    );
  }
}