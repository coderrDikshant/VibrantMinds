import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/category.dart';
import '../../services/firestore_service.dart';
import '../../widgets/quiz_cards/category_card.dart';
import '../../theme/vibrant_theme.dart';
import 'difficulty_selection_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String name;
  final String email;

  const CategorySelectionScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _categoriesFuture = Provider.of<FirestoreService>(context, listen: false).getCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = Provider.of<FirestoreService>(context, listen: false).getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCategories,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Color(0xFFF9F9F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshCategories,
          color: VibrantTheme.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Select a Quiz Category',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: VibrantTheme.textColor,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Lottie.asset(
                          'assets/animations/connection_animation.json',
                          width: 80,
                          height: 80,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/error_animation.json',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load categories',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: VibrantTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refreshCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VibrantTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/empty_state_animation.json',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No categories found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: VibrantTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _refreshCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VibrantTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final animation = CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                index * 0.05,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            );
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: CategoryCard(
                            category: category,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DifficultySelectionScreen(
                                    name: widget.name,
                                    email: widget.email,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}