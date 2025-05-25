import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../models/quiz_models/category.dart';
import '../../models/quiz_models/question.dart';
import '../../models/quiz_models/quiz.dart';
import '../../models/quiz_models/user_stats.dart';
import '../../services/firestore_service.dart';
import '../../theme/vibrant_theme.dart';
import '../../widgets/quiz_cards/question_widget.dart';
import 'question_map_screen.dart';
import 'stats_screen.dart';

class QuizScreen extends StatefulWidget {
  final String name;
  final String email;
  final Category category;
  final Quiz quiz;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.name,
    required this.email,
    required this.category,
    required this.quiz,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Question> _questions = [];
  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 125; // 10 minutes
  final Map<int, String> _questionStatus = {};
  late DateTime _startTime;
  bool _showWarning = false;
  bool _showTimeUp = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _fetchQuestions();
    _startTimer();
    _startTime = DateTime.now();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await FirestoreService(FirebaseFirestore.instance).getQuestions(
        widget.category.id,
        widget.difficulty,
        widget.quiz.id,
      );

      if (!mounted) return;
      setState(() {
        _questions = questions;
        for (int i = 0; i < _questions.length; i++) {
          _questionStatus[i] = "unvisited";
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching questions: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _showWarning = _remainingSeconds <= 120;
        });
      } else {
        _timer?.cancel();
        setState(() => _showTimeUp = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _submitQuiz(autoSubmit: true);
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void _markAnswered() => _questionStatus[_currentIndex] = "answered";

  void _markSkipped() {
    _questionStatus[_currentIndex] = "skipped";
    _goToNextQuestion();
  }

  void _markForReview() {
    _questionStatus[_currentIndex] = "review";
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _animationController.forward(from: 0);
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _animationController.forward(from: 0);
      });
    }
  }

  void _goToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionMapScreen(
          totalQuestions: _questions.length,
          questionStatus: _questionStatus,
          onQuestionSelected: (index) {
            setState(() {
              _currentIndex = index;
              _animationController.forward(from: 0);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    _timer?.cancel();
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime).inSeconds;

    int correct = 0;
    int wrong = 0;

    for (var q in _questions) {
      if (q.selectedOption == q.correctAnswer) {
        correct++;
      } else if (q.selectedOption != null) {
        wrong++;
      }
    }

    final stats = UserStats(
      userId: widget.email,
      name: widget.name,
      email: widget.email,
      category: widget.category.name,
      quizId: widget.quiz.id,
      difficulty: widget.difficulty,
      questions: _questions,
      timeTakenSeconds: duration,
      score: correct,
      totalQuestions: _questions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      timestamp: endTime,
    );

    if (stats.userId.isEmpty || stats.quizId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid email or quiz ID')),
        );
      }
      return;
    }

    try {
      await FirestoreService(FirebaseFirestore.instance).saveUserStats(stats);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StatsScreen(stats: stats),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving stats: $e')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StatsScreen(stats: stats),
          ),
        );
      }
    }
  }

  Future<bool> _handleBackPress() async {
    if (_showTimeUp) {
      return false; // Prevent back press during time-up state
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
            'You cannot exit the quiz without submitting. Would you like to submit the quiz now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Quiz'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit and Exit'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _submitQuiz();
      return true; // Allow navigation after submission
    }
    return false; // Prevent back navigation
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/animations/loading_animation.json',
            width: 100,
            height: 100,
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.set, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view),
              tooltip: 'Question Map',
              onPressed: _goToMapScreen,
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [VibrantTheme.backgroundColor, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Centered clock icon + timer below AppBar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 28, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds <= 60 ? Colors.red : Colors.black87,
                          ),
                        ),
                        if (_showWarning) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Lottie.asset('assets/animations/warning.json'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: QuestionWidget(
                        question: question,
                        questionNumber: _currentIndex + 1,
                        quizSetTitle: widget.quiz.title,
                        selectedAnswer: question.selectedOption,
                        onAnswerSelected: (value) {
                          setState(() {
                            question.selectedOption = value;
                            _markAnswered();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        text: 'Prev',
                        onPressed: _goToPreviousQuestion,
                        enabled: _currentIndex > 0,
                      ),
                      _ActionButton(
                        text: 'Skip',
                        onPressed: _markSkipped,
                      ),
                      _ActionButton(
                        text: 'Mark Review',
                        onPressed: _markForReview,
                      ),
                      _ActionButton(
                        text: 'Next',
                        onPressed: _goToNextQuestion,
                        enabled: _currentIndex < _questions.length - 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: _ActionButton(
                      text: 'Submit Quiz',
                      icon: Icons.check,
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Submit Quiz?'),
                            content: const Text(
                                'Are you sure you want to submit the quiz? You cannot change your answers after submission.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await _submitQuiz();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_showTimeUp)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/time_up.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Time’s Up!',
                        style: VibrantTheme.themeData.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _ActionButton({
    required this.text,
    this.icon,
    this.onPressed,
    this.enabled = true,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
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
      onTapDown: widget.enabled ? (_) => _controller.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
        _controller.reverse();
        widget.onPressed?.call();
      }
          : null,
      onTapCancel: widget.enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.enabled
                ? VibrantTheme.primaryColor
                : VibrantTheme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                widget.text,
                style: VibrantTheme.themeData.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}