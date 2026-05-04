import 'package:cloud_firestore/cloud_firestore.dart';

class HandoverQuickNote {
  final String id;
  final String title;
  final String content;
  final String createdByStaffId;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HandoverQuickNote({
    required this.id,
    required this.title,
    required this.content,
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
      createdByStaffId: data['createdByStaffId'] ?? '',
      createdByName: data['createdByName'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}