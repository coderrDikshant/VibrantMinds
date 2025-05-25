import 'package:flutter/material.dart';
import '../../theme/vibrant_theme.dart';

class QuestionMapScreen extends StatefulWidget {
  final int totalQuestions;
  final Map<int, String> questionStatus;
  final Function(int) onQuestionSelected;

  const QuestionMapScreen({
    super.key,
    required this.totalQuestions,
    required this.questionStatus,
    required this.onQuestionSelected,
  });

  @override
  State<QuestionMapScreen> createState() => _QuestionMapScreenState();
}

class _QuestionMapScreenState extends State<QuestionMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForStatus(String? status, BuildContext context) {
    final theme = VibrantTheme.themeData;
    switch (status) {
      case 'answered':
        return Colors.green.shade600;
      case 'review':
        return Colors.amber.shade600;
      case 'skipped':
        return Colors.red.shade600;
      case 'unvisited':
      default:
        return theme.colorScheme.surface;
    }
  }

  Color _getTextColor(String? status) {
    switch (status) {
      case 'answered':
      case 'review':
      case 'skipped':
        return Colors.white;
      case 'unvisited':
      default:
        return VibrantTheme.textColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Map'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [VibrantTheme.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.totalQuestions,
          itemBuilder: (context, index) {
            final status = widget.questionStatus[index];
            final color = _getColorForStatus(status, context);
            final textColor = _getTextColor(status);

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(index * 0.02, 1.0, curve: Curves.easeOut),
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
              child: _GridTile(
                index: index,
                color: color,
                textColor: textColor,
                onTap: () => widget.onQuestionSelected(index),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridTile extends StatefulWidget {
  final int index;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _GridTile({
    required this.index,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile> with SingleTickerProviderStateMixin {
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
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            "${widget.index + 1}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.textColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}