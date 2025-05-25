import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/category.dart';
import '../../utils/constants.dart';
import '../../widgets/quiz_cards/difficulty_card.dart';
import '../../theme/vibrant_theme.dart';
import 'quiz_selection_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
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
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<String>>(
          future: Future.value(AppConstants.difficulties),
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
                      'Error loading difficulties',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: VibrantTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final difficulties = snapshot.data ?? [];
            if (difficulties.isEmpty) {
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
                      'No difficulties available',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: difficulties.length,
              itemBuilder: (context, index) {
                final difficulty = difficulties[index];
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
                  child: DifficultyCard(
                    difficulty: difficulty,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizSelectionScreen(
                            name: widget.name,
                            email: widget.email,
                            category: widget.category,
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
      ),
    );
  }
}