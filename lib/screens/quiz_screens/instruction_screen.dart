import 'package:flutter/material.dart';
import '../../models/quiz_models/category.dart';
import '../../models/quiz_models/quiz.dart';
import '../../theme/vibrant_theme.dart';
import 'quiz_screen.dart';

class InstructionScreen extends StatefulWidget {
  final String name;
  final String email;
  final Category category;
  final Quiz quiz;
  final String difficulty;

  const InstructionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.category,
    required this.quiz,
    required this.difficulty,
  });

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VibrantTheme.themeData;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Quiz Instructions',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: VibrantTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...[
                    'Each question has one correct answer.',
                    'You can mark a question for review.',
                    'Use the map icon to navigate between questions.',
                    'Once started, you cannot go back until submission.',
                    'Quiz will auto-submit after the timer runs out.',
                    'No tab switching or taking screenshots allowed.',
                  ].asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
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
                      child: _buildInstructionText('• $text', theme),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Question Status Colors:',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: VibrantTheme.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...[
                    {'text': 'Answered: Green', 'color': Colors.green.shade600},
                    {'text': 'Marked for Review: Yellow', 'color': Colors.amber.shade600},
                    {'text': 'Skipped: Red', 'color': Colors.red.shade600},
                    {
                      'text': 'Unvisited: White',
                      'color': theme.colorScheme.surface,
                      'textColor': Colors.black87
                    },
                  ].asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
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
                      child: _buildColoredInstruction(
                        item['text'] as String,
                        item['color'] as Color,
                        theme,
                        textColor: item['textColor'] as Color?,
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                name: widget.name,
                                email: widget.email,
                                category: widget.category,
                                quiz: widget.quiz,
                                difficulty: widget.difficulty,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start Quiz'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: VibrantTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildColoredInstruction(String text, Color bgColor, ThemeData theme, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor ?? VibrantTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}