import 'package:cloud_firestore/cloud_firestore.dart';

enum ChildNoteVisibility {
  shared('shared'),
  private('private');

  final String value;

  const ChildNoteVisibility(this.value);

  static ChildNoteVisibility fromValue(String? value) {
    return ChildNoteVisibility.values.firstWhere(
      (visibility) => visibility.value == value,
      orElse: () => ChildNoteVisibility.shared,
    );
  }
}

enum ChildNoteCategory {
  general('general'),
  behaviour('behaviour'),
  communication('communication'),
  learning('learning'),
  sensory('sensory'),
  health('health'),
  parent('parent');

  final String value;

  const ChildNoteCategory(this.value);

  static ChildNoteCategory fromValue(String? value) {
    return ChildNoteCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => ChildNoteCategory.general,
    );
  }
}

class ChildNote {
  final String id;
  final String schoolId;
  final String classroomId;
  final String childId;
  final String childName;
  final String content;
  final ChildNoteCategory category;
  final ChildNoteVisibility visibility;
  final String createdByStaffId;
  final String createdByStaffName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChildNote({
    required this.id,
    required this.schoolId,
    required this.classroomId,
    required this.childId,
    required this.childName,
    required this.content,
    required this.category,
    required this.visibility,
    required this.createdByStaffId,
    required this.createdByStaffName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPrivate => visibility == ChildNoteVisibility.private;

  bool isVisibleToStaff(String staffId) {
    return visibility == ChildNoteVisibility.shared ||
        createdByStaffId == staffId;
  }

  factory ChildNote.fromMap(String id, Map<String, dynamic> data) {
    return ChildNote(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      classroomId: data['classroomId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      category: ChildNoteCategory.fromValue(data['category'] as String?),
      visibility: ChildNoteVisibility.fromValue(data['visibility'] as String?),
      createdByStaffId: data['createdByStaffId'] as String? ?? '',
      createdByStaffName: data['createdByStaffName'] as String? ?? '',
      createdAt:
          data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'schoolId': schoolId,
      'classroomId': classroomId,
      'childId': childId,
      'childName': childName,
      'content': content,
      'category': category.value,
      'visibility': visibility.value,
      'createdByStaffId': createdByStaffId,
      'createdByStaffName': createdByStaffName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'childName': childName,
      'content': content,
      'category': category.value,
      'visibility': visibility.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ChildNote copyWith({
    String? id,
    String? schoolId,
    String? classroomId,
    String? childId,
    String? childName,
    String? content,
    ChildNoteCategory? category,
    ChildNoteVisibility? visibility,
    String? createdByStaffId,
    String? createdByStaffName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildNote(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classroomId: classroomId ?? this.classroomId,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      content: content ?? this.content,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      createdByStaffId: createdByStaffId ?? this.createdByStaffId,
      createdByStaffName: createdByStaffName ?? this.createdByStaffName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
