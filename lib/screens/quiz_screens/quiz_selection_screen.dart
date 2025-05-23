import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz_models/category.dart';
import '../../../models/quiz_models/quiz.dart';
import '../../../services/firestore_service.dart';
import 'instruction_screen.dart';
import '../../../theme/vibrant_theme.dart';

class QuizSelectionScreen extends StatelessWidget {
  final String name;
  final String email;
  final Category category;
  final String difficulty;

  const QuizSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.category,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quizzes - ${category.name}',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: VibrantTheme.backgroundColor,
      body: FutureBuilder<List<Quiz>>(
        future: firestoreService.getQuizzes(category.id, difficulty, difficulty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: VibrantTheme.primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading quizzes: ${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VibrantTheme.errorColor,
                ),
              ),
            );
          }

          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return Center(
              child: Text(
                'No quizzes available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: VibrantTheme.primaryColor,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstructionScreen(
                        name: name,
                        email: email,
                        category: category,
                        quiz: quiz,
                        difficulty: difficulty,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set: ${quiz.set}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
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