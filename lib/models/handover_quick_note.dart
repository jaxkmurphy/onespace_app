import 'package:cloud_firestore/cloud_firestore.dart';

enum HandoverQuickNotePriority {
  normal('normal'),
  important('important'),
  urgent('urgent');

  final String value;

  const HandoverQuickNotePriority(this.value);

  static HandoverQuickNotePriority fromValue(String? value) {
    return HandoverQuickNotePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => HandoverQuickNotePriority.normal,
    );
  }
}

class HandoverQuickNote {
  final String id;
  final String title;
  final String content;
  final HandoverQuickNotePriority priority;
  final bool pinned;
  final String createdByStaffId;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HandoverQuickNote({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.pinned,
    required this.createdByStaffId,
    required this.createdByName,
    this.createdAt,
    this.updatedAt,
  });

  factory HandoverQuickNote.fromMap(String id, Map<String, dynamic> data) {
    return HandoverQuickNote(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      priority: HandoverQuickNotePriority.fromValue(data['priority']),
      pinned: data['pinned'] == true,
      createdByStaffId: data['createdByStaffId'] ?? '',
      createdByName: data['createdByName'] ?? '',
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
}
