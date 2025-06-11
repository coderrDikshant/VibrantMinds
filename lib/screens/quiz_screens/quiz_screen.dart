import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemNavigator.pop() or other platform services
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
import '../../services/screenshot_service.dart'; // Your custom screenshot protection service

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

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Question> _questions = [];
  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 125; // Quiz duration, e.g., 2 minutes 5 seconds
  final Map<int, String> _questionStatus = {}; // Tracks 'unvisited', 'answered', 'skipped', 'review'
  late DateTime _startTime;
  bool _showTimeUp = false; // Controls "Time's Up!" overlay
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Flag to prevent multiple quiz exit triggers due to rapid screenshot attempts
  bool _isExitingDueToScreenshot = false;

  @override
  void initState() {
    super.initState();
    // Subscribe to app lifecycle changes (e.g., app going to background)
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward(); // Start animation when the screen loads
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _fetchQuestions(); // Load quiz questions
    _startTimer(); // Start quiz timer
    _startTime = DateTime.now(); // Record quiz start time

    _setupScreenshotProtection(); // Initialize screenshot prevention/detection
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the quiz timer
    _animationController.dispose(); // Dispose animation controller
    WidgetsBinding.instance.removeObserver(this); // Unsubscribe from app lifecycle events

    // Essential: Re-enable screenshots when leaving the quiz screen
    ScreenshotService.enableScreenshots();
    // Essential: Reset screenshot attempt counter for future quiz sessions
    ScreenshotService.resetScreenshotAttempts();
    super.dispose();
  }

  // --- Screenshot Protection Management ---
  void _setupScreenshotProtection() {
    // Attempt to disable screenshots on Android (prevents capture)
    ScreenshotService.disableScreenshots();

    // Set up a listener for screenshot detection from native code (primarily iOS)
    ScreenshotService.setupMethodCallHandler((message, shouldExit) {
      if (mounted) {
        // Display a warning message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: shouldExit ? Colors.red.shade700 : Colors.orange.shade700,
            duration: const Duration(seconds: 4), // Allow time for user to read
          ),
        );

        // Debugging: Log the state of flags before potential exit
        debugPrint('QuizScreen Callback: Received shouldExit: $shouldExit, current _isExitingDueToScreenshot: $_isExitingDueToScreenshot');

        // If an exit is triggered by screenshot and we haven't already initiated one
        if (shouldExit && !_isExitingDueToScreenshot) {
          _isExitingDueToScreenshot = true; // Set flag to prevent re-triggering
          debugPrint('QuizScreen Callback: shouldExit is true, initiating forced exit.');

          // Delay the exit to allow the user to see the warning message
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              debugPrint('QuizScreen Callback: Delay complete, calling _submitQuiz for exit.');
              // Submit quiz (without saving stats) and exit the quiz screen
              _submitQuiz(autoSubmit: true, exitOnScreenshot: true);
            } else {
              debugPrint('QuizScreen Callback: Widget unmounted during delayed exit.');
            }
          });
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('QuizScreen Lifecycle: App state changed to $state');
    // You can add logic here to pause the quiz or obscure content
    // when the app goes into the background (e.g., AppLifecycleState.paused)
    super.didChangeAppLifecycleState(state);
  }

  // --- Quiz Logic ---
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
        // Initialize status for each question as 'unvisited'
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
          // Show warning when 1 minute or less remains
          // No need for a separate _showWarning flag as it's directly used in Text color
        });
      } else {
        _timer?.cancel(); // Stop timer when time is up
        setState(() => _showTimeUp = true); // Show "Time's Up!" overlay
        // Automatically submit quiz after a short delay
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
        _animationController.forward(from: 0); // Replay fade animation
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _animationController.forward(from: 0); // Replay fade animation
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
            Navigator.pop(context); // Close map screen
          },
        ),
      ),
    );
  }

  Future<void> _submitQuiz({bool autoSubmit = false, bool exitOnScreenshot = false}) async {
    _timer?.cancel(); // Always cancel timer when quiz submission is initiated

    // Debugging: Confirm _submitQuiz parameters
    debugPrint('_submitQuiz called. autoSubmit: $autoSubmit, exitOnScreenshot: $exitOnScreenshot');

    // Handle forced exit due to screenshot policy
    if (exitOnScreenshot) {
      debugPrint('_submitQuiz: Performing forced exit due to screenshot policy.');
      if (mounted) {
        // Option 1: Pop all routes until the very first one (e.g., login/home)
        // This is commonly used to return to the application's root screen.
        Navigator.of(context).popUntil((route) => route.isFirst);
        debugPrint('_submitQuiz: Navigator.popUntil((route) => route.isFirst) called.');

        // Option 2: Replace the entire navigation stack with a new screen.
        // This is more robust if `popUntil` isn't behaving as expected or
        // if you want to ensure a specific screen is shown as the exit point.
        // Uncomment and replace `YourHomeScreen()` with your actual main entry screen widget:
        /*
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => YourHomeScreen()), // Replace YourHomeScreen() with your actual entry widget
          (Route<dynamic> route) => false, // This predicate removes all previous routes
        );
        debugPrint('_submitQuiz: Navigator.pushAndRemoveUntil called.');
        */

        // Option 3: Hard exit the entire app (use with extreme caution, generally bad UX)
        // SystemNavigator.pop();
        // debugPrint('_submitQuiz: SystemNavigator.pop() called.');
      }
      return; // Crucial: Stop further execution for screenshot-induced exit
    }

    // --- Standard Quiz Submission Logic ---
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
      questions: _questions, // Include all questions with selected answers for review
      timeTakenSeconds: duration,
      score: correct,
      totalQuestions: _questions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      timestamp: endTime,
    );

    // Validate user and quiz IDs before saving stats
    if (stats.userId.isEmpty || stats.quizId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid user or quiz ID to save stats.')),
        );
      }
      return;
    }

    try {
      await FirestoreService(FirebaseFirestore.instance).saveUserStats(stats);
      if (mounted) {
        // Navigate to the StatsScreen after successful submission
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
        // Even if saving fails, still transition to stats screen to show current score
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
    // Prevent back navigation if time is up or if exiting due to screenshot policy
    if (_showTimeUp || _isExitingDueToScreenshot) {
      return false;
    }

    // Show a confirmation dialog before allowing the user to exit
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

    // If user confirms to submit and exit, submit the quiz
    if (confirm == true && mounted) {
      await _submitQuiz();
      return true; // Allow back navigation after submission
    }
    return false; // Prevent back navigation by default
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading animation while questions are being fetched
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

    // Use WillPopScope to control back button behavior
    return PopScope(
      canPop: false, // Prevents default back button behavior
      onPopInvoked: (didPop) async {
        if (didPop) return; // If pop is already handled by system, do nothing
        await _handleBackPress(); // Custom back press handling
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.set,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view),
              tooltip: 'Question Map',
              onPressed: _goToMapScreen, // Navigate to question map
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
                  // Timer display with warning animation
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
                        // Show warning Lottie animation if time is running out
                        if (_remainingSeconds <= 60) ...[
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
                  // Current question display with fade animation
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
                            _markAnswered(); // Mark question as answered
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons for navigation and review
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        text: 'Prev',
                        onPressed: _goToPreviousQuestion,
                        enabled: _currentIndex > 0, // Enable only if not on first question
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
                        enabled: _currentIndex < _questions.length - 1, // Enable only if not on last question
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Submit Quiz button
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
                          await _submitQuiz(); // Submit quiz if user confirms
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Overlay for "Time's Up!" animation
            if (_showTimeUp)
              Container(
                color: Colors.black54, // Semi-transparent black background
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/time_up.json', // Your "Time's Up" animation
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

// Re-using your existing _ActionButton widget for consistent styling and animation
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
              widget.onPressed?.call(); // Call the provided onPressed callback
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