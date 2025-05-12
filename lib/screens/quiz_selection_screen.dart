import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/quiz.dart';
import '../../services/firestore_service.dart';
import '../../widgets/quiz_card.dart';
import 'quiz_screen.dart';

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
      appBar: AppBar(title: Text('Select Quiz - ${category.name}')),
      body: FutureBuilder<List<Quiz>>(
        future: firestoreService.getQuizzes(category.id, difficulty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading quizzes'));
          }
          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available'));
          }
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return QuizCard(
                quiz: quiz,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        userId: userId,
                        name: name,
                        email: email,
                        category: category,
                        quiz: quiz,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}