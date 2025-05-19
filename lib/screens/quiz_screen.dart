import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';
import '../../models/user_stats.dart';
import '../../services/firestore_service.dart';
import 'question_map_screen.dart';
import 'stats_screen.dart';

class QuizScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final Category category;
  final Quiz quiz;
  final String difficulty;

  const QuizScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
    required this.quiz,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 600; // 10 minutes
  final Map<int, String> _questionStatus = {};
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _startTimer();
    _startTime = DateTime.now();
  }

  Future<void> _fetchQuestions() async {
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
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitQuiz(autoSubmit: true);
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
      setState(() => _currentIndex++);
    }
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
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
            setState(() => _currentIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _submitQuiz({bool autoSubmit = false}) async {
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
      userId: widget.userId,
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

    await FirestoreService(FirebaseFirestore.instance).saveUserStats(stats);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StatsScreen(stats: stats),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        automaticallyImplyLeading: false,
        title: Text('Quiz - ${widget.quiz.title}'),
        actions: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view),
                onPressed: _goToMapScreen,
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Q${_currentIndex + 1}: ${question.question}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ...question.options.map((option) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: question.selectedOption == option
                        ? Colors.deepOrange
                        : Colors.orange.shade100,
                    foregroundColor: question.selectedOption == option
                        ? Colors.white
                        : Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      question.selectedOption = option;
                      _markAnswered();
                    });
                  },
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: _goToPreviousQuestion, child: const Text("Prev")),
                OutlinedButton(onPressed: _markSkipped, child: const Text("Skip")),
                OutlinedButton(onPressed: _markForReview, child: const Text("Mark Review")),
                ElevatedButton(onPressed: _goToNextQuestion, child: const Text("Next")),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Submit Quiz"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Submit Quiz?'),
                      content: const Text('Are you sure you want to submit the quiz? You cannot change your answers after submission.'),
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
                  if (confirm == true) {
                    _submitQuiz();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
