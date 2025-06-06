import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart'; 

class Quiz {
  final String id;
  final String title;
  final String createdBy;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.questions,
  });

  /// For real-time Firestore streams
  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz.fromMap(doc.id, data);
  }

  /// For manual fetching (getQuizzes)
  factory Quiz.fromMap(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      title: data['title'] ?? 'Untitled',
      createdBy: data['createdBy'] ?? 'Unknown',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Used when saving a quiz (e.g. in addQuiz)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}