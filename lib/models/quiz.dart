import 'question.dart';

class Quiz {
  final String id; // Firestore document ID
  final String title;
  final String createdBy; // teacher UID
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.questions,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    var questionsFromMap = (map['questions'] as List<dynamic>)
        .map((q) => Question.fromMap(q as Map<String, dynamic>))
        .toList();

    return Quiz(
      id: id,
      title: map['title'] as String,
      createdBy: map['createdBy'] as String,
      questions: (map['questions'] as List<dynamic>? ?? [])
      .map((q) => Question.fromMap(q as Map<String, dynamic>))
      .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}