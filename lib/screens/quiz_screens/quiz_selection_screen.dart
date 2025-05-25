import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/category.dart';
import '../../models/quiz_models/quiz.dart';
import '../../services/firestore_service.dart';
import '../../widgets/quiz_cards/quiz_card.dart';
import '../../theme/vibrant_theme.dart';
import 'instruction_screen.dart';

class QuizSelectionScreen extends StatefulWidget {
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
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _quizzesFuture = Provider.of<FirestoreService>(context, listen: false)
        .getQuizzes(widget.category.id, widget.difficulty, widget.difficulty);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshQuizzes() async {
    setState(() {
      _quizzesFuture = Provider.of<FirestoreService>(context, listen: false)
          .getQuizzes(widget.category.id, widget.difficulty, widget.difficulty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes - ${widget.category.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshQuizzes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshQuizzes,
          color: VibrantTheme.primaryColor,
          child: FutureBuilder<List<Quiz>>(
            future: _quizzesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset(
                    'assets/animations/loading_animation.json',
                    // 'https://assets.lottiefiles.com/packages/lf20_y8jzcz9v.json',
                    width: 100,
                    height: 100,
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
                        // 'https://assets.lottiefiles.com/packages/lf20_3ruxiflw.json',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading quizzes',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: VibrantTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshQuizzes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final quizzes = snapshot.data ?? [];
              if (quizzes.isEmpty) {
                return Center(
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
                        'No quizzes available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: VibrantTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshQuizzes,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final animation = CurvedAnimation(
                        parent: _animationController,
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
                    child: QuizCard(
                      quiz: quiz,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InstructionScreen(
                              name: widget.name,
                              email: widget.email,
                              category: widget.category,
                              quiz: quiz,
                              difficulty: widget.difficulty,
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
      ),
    );
  }
}