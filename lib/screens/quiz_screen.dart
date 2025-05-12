import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/question.dart';
import '../../models/quiz.dart';
import '../../services/firestore_service.dart';
import '../../widgets/question_widget.dart';
import '../models/user_stats.dart';
import 'stats_screen.dart';

class QuizScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final Category category;
  final Quiz quiz;

  const QuizScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.category,
    required this.quiz,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  List<String?> selectedAnswers = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final fetchedQuestions = await firestoreService.getQuestions(widget.category.id, widget.quiz.id);
    setState(() {
      questions = fetchedQuestions;
      selectedAnswers = List<String?>.filled(questions.length, null);
      isLoading = false;
    });
  }

  void _submitQuiz() {
    int score = 0;
    int correctAnswers = 0;
    int wrongAnswers = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswer) {
        score++;
        correctAnswers++;
      } else if (selectedAnswers[i] != null) {
        wrongAnswers++;
      }
    }

    final stats = UserStats(
      userId: widget.userId,
      name: widget.name,
      email: widget.email,
      category: widget.category.id,
      quizId: widget.quiz.id,
      difficulty: widget.quiz.difficulty,
      score: score,
      totalQuestions: questions.length,
      timestamp: DateTime.now(),
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
    );

    Provider.of<FirestoreService>(context, listen: false).saveUserStats(stats);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StatsScreen(stats: stats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quiz - ${widget.category.name}')),
      body: Column(
        children: [
          Expanded(
            child: QuestionWidget(
              question: questions[currentQuestionIndex],
              questionNumber: currentQuestionIndex + 1,
              selectedAnswer: selectedAnswers[currentQuestionIndex],
              onAnswerSelected: (answer) {
                setState(() {
                  selectedAnswers[currentQuestionIndex] = answer;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex--;
                    });
                  },
                  child: const Text('Previous'),
                ),
              if (currentQuestionIndex < questions.length - 1)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex++;
                    });
                  },
                  child: const Text('Next'),
                ),
              if (currentQuestionIndex == questions.length - 1)
                ElevatedButton(
                  onPressed: selectedAnswers.contains(null) ? null : _submitQuiz,
                  child: const Text('Submit'),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}