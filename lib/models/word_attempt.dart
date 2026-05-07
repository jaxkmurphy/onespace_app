class WordAttempt {
  final String id;
  final String childId;
  final String packId;
  final String wordId;
  final String wordText;
  final String selectedAnswer;
  final bool isCorrect;

  WordAttempt({
    required this.id,
    required this.childId,
    required this.packId,
    required this.wordId,
    required this.wordText,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  factory WordAttempt.fromMap(String id, Map<String, dynamic> data) {
    return WordAttempt(
      id: id,
      childId: data['childId'] ?? '',
      packId: data['packId'] ?? '',
      wordId: data['wordId'] ?? '',
      wordText: data['wordText'] ?? '',
      selectedAnswer: data['selectedAnswer'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'packId': packId,
      'wordId': wordId,
      'wordText': wordText,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }
}