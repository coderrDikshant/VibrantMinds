import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_card.dart';
import '../../theme/vibrant_theme.dart';
import 'difficulty_selection_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;

  const CategorySelectionScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
        backgroundColor: VibrantTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: VibrantTheme.backgroundColor,
      body: FutureBuilder<List<Category>>(
        future: firestoreService.getCategories(),
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
                'Error loading categories',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: VibrantTheme.errorColor,
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'No categories available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: VibrantTheme.primaryColor,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DifficultySelectionScreen(
                          userId: userId,
                          name: name,
                          email: email,
                          category: category,
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