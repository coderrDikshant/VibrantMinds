import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/quiz.dart';
import '../../services/firestore_service.dart';
import 'instruction_screen.dart'; // Navigate to instruction screen instead of quiz
import '../../theme/vibrant_theme.dart'; // Make sure you have your orange theme here

class QuizSelectionScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final Category category;
  final String difficulty;

  const QuizSelectionScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes - ${category.name}'),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Quiz>>(
        future: firestoreService.getQuizzes(category.id, difficulty, difficulty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading quizzes: ${snapshot.error}'));
          }

          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available'));
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.separated(
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
                          userId: userId,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: VibrantTheme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: VibrantTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
