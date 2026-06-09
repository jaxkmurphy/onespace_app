import 'package:cloud_firestore/cloud_firestore.dart';

class BodyCheckReport {
  final String id;
  final String childId;
  final String childName;
  final String bodyPart;
  final int painLevel;
  final String painType;
  final DateTime timestamp;
  final bool checked;
  final String checkedNote;
  final DateTime? checkedAt;

  BodyCheckReport({
    required this.id,
    required this.childId,
    required this.childName,
    required this.bodyPart,
    required this.painLevel,
    required this.painType,
    required this.timestamp,
    this.checked = false,
    this.checkedNote = '',
    this.checkedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'childName': childName,
      'bodyPart': bodyPart,
      'painLevel': painLevel,
      'painType': painType,
      'timestamp': Timestamp.fromDate(timestamp),
      'checked': checked,
      'checkedNote': checkedNote,
      'checkedAt': checkedAt == null ? null : Timestamp.fromDate(checkedAt!),
    };
  }

  factory BodyCheckReport.fromMap(String id, Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    final rawCheckedAt = map['checkedAt'];

    return BodyCheckReport(
      id: id,
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      bodyPart: map['bodyPart'] ?? '',
      painLevel: map['painLevel'] ?? 0,
      painType: map['painType'] ?? '',
      timestamp: rawTimestamp is Timestamp
          ? rawTimestamp.toDate()
          : DateTime.now(),
      checked: map['checked'] ?? false,
      checkedNote: map['checkedNote'] ?? '',
      checkedAt: rawCheckedAt is Timestamp ? rawCheckedAt.toDate() : null,
    );
  }
}