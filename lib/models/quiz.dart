import 'package:cloud_firestore/cloud_firestore.dart';

import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final List<Question> questions;

  final String iconName;
  final String colorHex;

  final bool availableToAll;
  final List<String> assignedChildIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.questions,
    this.description = '',
    this.iconName = 'quiz',
    this.colorHex = '#7E57C2',
    this.availableToAll = true,
    this.assignedChildIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Quiz.fromMap(doc.id, data);
  }

  factory Quiz.fromMap(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      title: data['title'] as String? ?? 'Untitled Quiz',
      description: data['description'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      questions: (data['questions'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (question) => Question.fromMap(
              Map<String, dynamic>.from(question),
            ),
          )
          .toList(),
      iconName: data['iconName'] as String? ?? 'quiz',
      colorHex: data['colorHex'] as String? ?? '#7E57C2',

      // Existing quizzes remain available to every child.
      availableToAll: data['availableToAll'] as bool? ?? true,

      assignedChildIds: List<String>.from(
        data['assignedChildIds'] ?? const [],
      ),
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'questions': questions.map((question) {
        return question.toMap();
      }).toList(),
      'iconName': iconName,
      'colorHex': colorHex,
      'availableToAll': availableToAll,
      'assignedChildIds': assignedChildIds,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool isAvailableForChild(String childId) {
    return availableToAll || assignedChildIds.contains(childId);
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    List<Question>? questions,
    String? iconName,
    String? colorHex,
    bool? availableToAll,
    List<String>? assignedChildIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      questions: questions ?? this.questions,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      availableToAll: availableToAll ?? this.availableToAll,
      assignedChildIds:
          assignedChildIds ?? this.assignedChildIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}