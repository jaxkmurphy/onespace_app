import 'package:cloud_firestore/cloud_firestore.dart';

class HandoverOverview {
  final String classroomSnapshot;
  final String todayRoutine;
  final String mustKnow;
  final String safetySupports;
  final String checkFirst;
  final String urgentGuidance;
  final String legacyContent;
  final String updatedByName;
  final DateTime? updatedAt;

  const HandoverOverview({
    this.classroomSnapshot = '',
    this.todayRoutine = '',
    this.mustKnow = '',
    this.safetySupports = '',
    this.checkFirst = '',
    this.urgentGuidance = '',
    this.legacyContent = '',
    this.updatedByName = '',
    this.updatedAt,
  });

  factory HandoverOverview.empty() {
    return const HandoverOverview();
  }

  factory HandoverOverview.fromMap(Map<String, dynamic>? data) {
    if (data == null) return HandoverOverview.empty();

    return HandoverOverview(
      classroomSnapshot: data['classroomSnapshot'] ?? '',
      todayRoutine: data['todayRoutine'] ?? '',
      mustKnow: data['mustKnow'] ?? '',
      safetySupports: data['safetySupports'] ?? '',
      checkFirst: data['checkFirst'] ?? '',
      urgentGuidance: data['urgentGuidance'] ?? '',
      legacyContent: data['content'] ?? '',
      updatedByName: data['updatedByName'] ?? '',
      updatedAt:
          data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  bool get hasStructuredContent {
    return classroomSnapshot.trim().isNotEmpty ||
        todayRoutine.trim().isNotEmpty ||
        mustKnow.trim().isNotEmpty ||
        safetySupports.trim().isNotEmpty ||
        checkFirst.trim().isNotEmpty ||
        urgentGuidance.trim().isNotEmpty;
  }

  bool get isEmpty {
    return !hasStructuredContent && legacyContent.trim().isEmpty;
  }

  Map<String, dynamic> toMap({required String updatedByName}) {
    return {
      'classroomSnapshot': classroomSnapshot.trim(),
      'todayRoutine': todayRoutine.trim(),
      'mustKnow': mustKnow.trim(),
      'safetySupports': safetySupports.trim(),
      'checkFirst': checkFirst.trim(),
      'urgentGuidance': urgentGuidance.trim(),
      'updatedByName': updatedByName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  HandoverOverview copyWith({
    String? classroomSnapshot,
    String? todayRoutine,
    String? mustKnow,
    String? safetySupports,
    String? checkFirst,
    String? urgentGuidance,
    String? legacyContent,
    String? updatedByName,
    DateTime? updatedAt,
  }) {
    return HandoverOverview(
      classroomSnapshot: classroomSnapshot ?? this.classroomSnapshot,
      todayRoutine: todayRoutine ?? this.todayRoutine,
      mustKnow: mustKnow ?? this.mustKnow,
      safetySupports: safetySupports ?? this.safetySupports,
      checkFirst: checkFirst ?? this.checkFirst,
      urgentGuidance: urgentGuidance ?? this.urgentGuidance,
      legacyContent: legacyContent ?? this.legacyContent,
      updatedByName: updatedByName ?? this.updatedByName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
