import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/quiz_screens/category_selection_screen.dart';
import '../../screens/quiz_screens/previous_stats_screen.dart';
import '../../screens/quiz_screens/instruction_screen.dart';
import '../../theme/vibrant_theme.dart';
import '../../utils/constants.dart';
import '../../services/firestore_service.dart';
import '../../models/quiz_models/quiz.dart';
import '../../models/quiz_models/category.dart';

class QuizEntryScreen extends StatefulWidget {
  final String name;
  final String email;

  const QuizEntryScreen({super.key, required this.name, required this.email});

  @override
  State<QuizEntryScreen> createState() => _QuizEntryScreenState();
}

class _QuizEntryScreenState extends State<QuizEntryScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Quiz> _randomQuizzes = [];
  List<Category> _randomQuizCategories = [];
  List<String> _randomQuizDifficulties = [];
  bool _isLoadingRandomQuiz = false;

  final List<Map<String, String>> _tests = [
    {
      'title': 'Math Olympiad Prep',
      'description': 'Practice for competitive math exams.',
      'difficulty': 'Hard',
    },
    {
      'title': 'Coding Challenge',
      'description': 'Test your programming skills.',
      'difficulty': 'Medium',
    },
  ];

  final bool _hasActiveTests = true;
  final FirestoreService _firestoreService = FirestoreService(FirebaseFirestore.instance);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRandomQuiz() async {
    setState(() {
      _isLoadingRandomQuiz = true;
      _randomQuizzes = [];
      _randomQuizCategories = [];
      _randomQuizDifficulties = [];
    });

    try {
      // Fetch all categories
      final categories = await _firestoreService.getCategories();
      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No categories available')),
        );
        setState(() {
          _isLoadingRandomQuiz = false;
        });
        return;
      }

      final random = Random();
      const int quizCount = 5;
      List<Quiz> selectedQuizzes = [];
      List<Category> selectedCategories = [];
      List<String> selectedDifficulties = [];

      // Fetch up to 5 distinct quizzes
      for (int i = 0; i < quizCount && categories.isNotEmpty; i++) {
        // Randomly select a category
        final randomCategory = categories[random.nextInt(categories.length)];
        final categoryId = randomCategory.id;

        // Fetch difficulties for the category
        final difficultySnapshot = await FirebaseFirestore.instance
            .collection(AppConstants.categoriesCollection)
            .doc(categoryId)
            .collection(AppConstants.difficultyCollection)
            .get();
        if (difficultySnapshot.docs.isEmpty) continue;

        // Randomly select a difficulty
        final randomDifficulty = difficultySnapshot.docs[random.nextInt(difficultySnapshot.docs.length)];
        final difficulty = randomDifficulty.data()['difficulty'] ?? 'Medium';
        final difficultyId = randomDifficulty.id;

        // Fetch quizzes for the selected category and difficulty
        final quizzes = await _firestoreService.getQuizzes(categoryId, difficultyId, difficulty);
        if (quizzes.isEmpty) continue;

        // Select a random quiz
        final quiz = quizzes[random.nextInt(quizzes.length)];
        selectedQuizzes.add(quiz);
        selectedCategories.add(randomCategory);
        selectedDifficulties.add(difficulty);
      }

      if (selectedQuizzes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quizzes available')),
        );
        setState(() {
          _isLoadingRandomQuiz = false;
        });
        return;
      }

      setState(() {
        _randomQuizzes = selectedQuizzes;
        _randomQuizCategories = selectedCategories;
        _randomQuizDifficulties = selectedDifficulties;
        _isLoadingRandomQuiz = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRandomQuiz = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching random quizzes: $e')),
      );
    }
  }

  void _navigateToCategorySelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          name: widget.name,
          email: widget.email,
        ),
      ),
    );
  }

  void _navigateToInstructionScreen(Quiz quiz, Category category, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructionScreen(
          name: widget.name,
          email: widget.email,
          category: category,
          quiz: quiz,
          difficulty: difficulty,
        ),
      ),
    );
  }

  void _viewPreviousStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousStatsScreen(
          name: widget.name,
          email: widget.email,
        ),
      ),
    );
  }

  void _viewLeaderboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing leaderboard!'),
        backgroundColor: VibrantTheme.primaryColor,
      ),
    );
    // TODO: Implement leaderboard screen
  }

  void _startPracticeMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting practice mode!'),
        backgroundColor: VibrantTheme.primaryColor,
      ),
    );
    // TODO: Implement practice mode
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: VibrantTheme.backgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTab == 0 ? Colors.red : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Quiz',
                          style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                            color: _selectedTab == 0 ? Colors.red : VibrantTheme.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTab == 1 ? Colors.red : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Test',
                          style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                            color: _selectedTab == 1 ? Colors.red : VibrantTheme.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _selectedTab == 0 ? _buildQuizTab() : _buildTestTab(),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildQuizTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/quiz_animation.json',
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get Started',
            style: VibrantTheme.themeData.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _navigateToCategorySelection,
                child: const Text('Take Quiz'),
              ),
              ElevatedButton(
                onPressed: _viewPreviousStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: VibrantTheme.textColor,
                ),
                child: const Text('View Previous Stats'),
              ),
              ElevatedButton(
                onPressed: _viewLeaderboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: VibrantTheme.textColor,
                ),
                child: const Text('Leaderboard'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Quizzes',
                style: VibrantTheme.themeData.textTheme.headlineLarge,
              ),
              ElevatedButton(
                onPressed: _isLoadingRandomQuiz ? null : _fetchRandomQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VibrantTheme.primaryColor,
                  padding: const EdgeInsets.all(12),
                  shape: const CircleBorder(),
                ),
                child: _isLoadingRandomQuiz
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.shuffle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingRandomQuiz)
            Center(
              child: Lottie.asset(
                'assets/animations/loading_animation.json', // Ensure the path is correct
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )
          else if (_randomQuizzes.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _randomQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = _randomQuizzes[index];
                final category = _randomQuizCategories[index];
                final difficulty = _randomQuizDifficulties[index];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animation = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    child: InkWell(
                      onTap: () => _navigateToInstructionScreen(
                        quiz,
                        category,
                        difficulty,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFF9F9F9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.set,
                              style: VibrantTheme.themeData.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Category: ${category.name}',
                              style: VibrantTheme.themeData.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Difficulty: $difficulty',
                              style: VibrantTheme.themeData.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'No quizzes selected. Press Randomize to get started!',
                    style: VibrantTheme.themeData.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildTestTab() {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      color: VibrantTheme.primaryColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Tests',
              style: VibrantTheme.themeData.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            _hasActiveTests
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tests.length,
              itemBuilder: (context, index) {
                final test = _tests[index];
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animation = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF9F9F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['title']!,
                            style: VibrantTheme.themeData.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test['description']!,
                            style: VibrantTheme.themeData.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Difficulty: ${test['difficulty']}',
                            style: VibrantTheme.themeData.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/empty_state_animation.json',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active tests available',
                    style: VibrantTheme.themeData.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}