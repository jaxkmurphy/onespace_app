class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    int? correctAnswerIndex,
    this.explanation = '',
  }) : correctAnswerIndex = _resolveCorrectIndex(
          options,
          correctAnswer,
          correctAnswerIndex,
        );

  static int _resolveCorrectIndex(
    List<String> options,
    String correctAnswer,
    int? suppliedIndex,
  ) {
    if (suppliedIndex != null &&
        suppliedIndex >= 0 &&
        suppliedIndex < options.length) {
      return suppliedIndex;
    }

    final matchingIndex = options.indexOf(correctAnswer);
    return matchingIndex >= 0 ? matchingIndex : 0;
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    final options = List<String>.from(map['options'] ?? const []);

    final storedAnswer = map['correctAnswer'] as String? ?? '';
    final storedIndex = map['correctAnswerIndex'] as int?;

    final resolvedIndex = _resolveCorrectIndex(
      options,
      storedAnswer,
      storedIndex,
    );

    final resolvedAnswer = storedAnswer.isNotEmpty
        ? storedAnswer
        : options.isNotEmpty
            ? options[resolvedIndex]
            : '';

    return Question(
      question: map['question'] as String? ?? '',
      options: options,
      correctAnswer: resolvedAnswer,
      correctAnswerIndex: resolvedIndex,
      explanation: map['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  Question copyWith({
    String? question,
    List<String>? options,
    String? correctAnswer,
    int? correctAnswerIndex,
    String? explanation,
  }) {
    return Question(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      correctAnswerIndex:
          correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
    );
  }
}