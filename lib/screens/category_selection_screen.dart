import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_card.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Select Category')),
      body: FutureBuilder<List<Category>>(
        future: firestoreService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          }
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
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
              );
            },
          );
        },
      ),
    );
  }
}