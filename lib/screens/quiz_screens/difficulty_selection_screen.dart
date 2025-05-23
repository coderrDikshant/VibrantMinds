import 'package:flutter/material.dart';
import '../../models/quiz_models/category.dart';
import '../../../utils/constants.dart';
import '../../../widgets/quiz_cards/difficulty_card.dart';
import '../../../theme/vibrant_theme.dart';
import 'quiz_selection_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final String name;
  final String email;
  final Category category;

  const DifficultySelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: VibrantTheme.backgroundColor,
      body: FutureBuilder<List<String>>(
        future: Future.value(AppConstants.difficulties), // Simulating async data
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
                'Error loading difficulties',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VibrantTheme.errorColor,
                ),
              ),
            );
          }

          final difficulties = snapshot.data ?? [];
          if (difficulties.isEmpty) {
            return Center(
              child: Text(
                'No difficulties available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: VibrantTheme.primaryColor,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: difficulties.length,
            itemBuilder: (context, index) {
              final difficulty = difficulties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DifficultyCard(
                  difficulty: difficulty,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizSelectionScreen(
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
          );
        },
      ),
    );
  }
}