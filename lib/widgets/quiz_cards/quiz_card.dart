import 'package:flutter/material.dart';
import '../../models/quiz_models/quiz.dart';
import '../../theme/vibrant_theme.dart';

class QuizCard extends StatefulWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Card(
          elevation: 4,
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
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                widget.quiz.title,
                style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                  color: VibrantTheme.textColor,
                ),
              ),
              subtitle: Text(
                'Set: ${widget.quiz.set} | Difficulty: ${widget.quiz.difficulty.toUpperCase()}',
                style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                  color: VibrantTheme.greyTextColor,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: VibrantTheme.primaryColor,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}