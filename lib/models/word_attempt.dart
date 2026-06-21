import 'package:cloud_firestore/cloud_firestore.dart';

class WordAttempt {
  final String id;
  final String childId;
  final String packId;
  final String wordId;
  final String wordText;
  final String selectedAnswer;
  final bool isCorrect;

  final String sessionId;
  final DateTime? createdAt;

  WordAttempt({
    required this.id,
    required this.childId,
    required this.packId,
    required this.wordId,
    required this.wordText,
    required this.selectedAnswer,
    required this.isCorrect,
    this.sessionId = '',
    this.createdAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    return null;
  }

  factory WordAttempt.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return WordAttempt(
      id: id,
      childId: data['childId'] as String? ?? '',
      packId: data['packId'] as String? ?? '',
      wordId: data['wordId'] as String? ?? '',
      wordText: data['wordText'] as String? ?? '',
      selectedAnswer:
          data['selectedAnswer'] as String? ?? '',
      isCorrect: data['isCorrect'] as bool? ?? false,
      sessionId: data['sessionId'] as String? ?? '',
      createdAt: _dateFromValue(data['createdAt']),
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
      'sessionId': sessionId,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}