import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../screens/quiz_screens/category_selection_screen.dart';
import '../../theme/vibrant_theme.dart';
import '../../utils/constants.dart';

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

  final List<Map<String, String>> _quizzes = [
    {
      'title': 'General Knowledge Trivia',
      'description': 'Test your knowledge across various topics.',
      'difficulty': 'Easy',
    },
    {
      'title': 'Science & Technology',
      'description': 'Explore concepts in physics, chemistry, and tech.',
      'difficulty': 'Medium',
    },
    {
      'title': 'History Challenge',
      'description': 'Dive into historical events and figures.',
      'difficulty': 'Hard',
    },
  ];

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

  void _viewPreviousStats() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viewing previous stats!'),
        backgroundColor: VibrantTheme.primaryColor,
      ),
    );
    // TODO: Implement stats screen
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
        gradient: LinearGradient(
          colors: [VibrantTheme.backgroundColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
                        color: _selectedTab == 0 ? VibrantTheme.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Quiz',
                          style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                            color: _selectedTab == 0 ? Colors.white : VibrantTheme.textColor,
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
                        color: _selectedTab == 1 ? VibrantTheme.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Test',
                          style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                            color: _selectedTab == 1 ? Colors.white : VibrantTheme.textColor,
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
                  backgroundColor: Colors.grey[200],
                  foregroundColor: VibrantTheme.textColor,
                ),
                child: const Text('View Previous Stats'),
              ),
              ElevatedButton(
                onPressed: _viewLeaderboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: VibrantTheme.textColor,
                ),
                child: const Text('Leaderboard'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Explore Quizzes',
            style: VibrantTheme.themeData.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              final quiz = _quizzes[index];
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                          quiz['title']!,
                          style: VibrantTheme.themeData.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quiz['description']!,
                          style: VibrantTheme.themeData.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Difficulty: ${quiz['difficulty']}',
                          style: VibrantTheme.themeData.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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