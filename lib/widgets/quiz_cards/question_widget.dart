import 'package:flutter/material.dart';
import '../../models/quiz_models/question.dart';
import '../../theme/vibrant_theme.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final String quizSetTitle;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.quizSetTitle,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Set: ${widget.quizSetTitle} - Question ${widget.questionNumber}',
                style: VibrantTheme.themeData.textTheme.headlineMedium?.copyWith(
                  color: VibrantTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.question.question,
                style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                  color: VibrantTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _OptionButton(
                    option: option,
                    isSelected: widget.selectedAnswer == option,
                    onTap: () => widget.onAnswerSelected(option),
                    optionLetter: String.fromCharCode(65 + index), // Converts index to A, B, C, D
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatefulWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;
  final String optionLetter;

  const _OptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.optionLetter,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> with SingleTickerProviderStateMixin {
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? VibrantTheme.primaryColor.withOpacity(0.2)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? VibrantTheme.primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Text(
                '${widget.optionLetter}. ',
                style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                  color: widget.isSelected ? VibrantTheme.primaryColor : VibrantTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  widget.option,
                  style: VibrantTheme.themeData.textTheme.bodyLarge?.copyWith(
                    color: widget.isSelected ? VibrantTheme.primaryColor : VibrantTheme.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}