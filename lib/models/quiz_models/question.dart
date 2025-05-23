class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  String? selectedOption;
  final String explanation;
  final String category;
  final String difficulty;
  final String set;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.selectedOption,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.set,
  });

  factory Question.fromFirestore(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      question: data['question'],
      options: List<String>.from(data['options']),
      correctAnswer: data['correctAnswer'],
      selectedOption: data['selectedOption'],
      explanation: data['explanation'],
      category: data['category'],
      difficulty: data['difficulty'],
      set: data['set'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'selectedOption': selectedOption,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'set': set,
    };
  }

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      id: data['id'],
      question: data['question'],
      options: List<String>.from(data['options']),
      correctAnswer: data['correctAnswer'],
      selectedOption: data['selectedOption'],
      explanation: data['explanation'],
      category: data['category'],
      difficulty: data['difficulty'],
      set: data['set'],
    );
  }
}
