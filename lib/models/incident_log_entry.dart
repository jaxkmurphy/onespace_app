import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentLogEntry {
  final String id;
  final String childId;
  final String childName;
  final DateTime timestamp;
  final String description;
  final String actionTaken;
  final String staffId;
  final String staffName;
  final String severity;

  IncidentLogEntry({
    required this.id,
    required this.childId,
    required this.childName,
    required this.timestamp,
    required this.description,
    required this.actionTaken,
    required this.staffId,
    required this.staffName,
    this.severity = 'Low',
  });

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'childName': childName,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'actionTaken': actionTaken,
      'staffId': staffId,
      'staffName': staffName,
      'severity': severity,
    };
  }

  factory IncidentLogEntry.fromMap(String id, Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];

    return IncidentLogEntry(
      id: id,
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      timestamp: rawTimestamp is Timestamp
          ? rawTimestamp.toDate()
          : DateTime.now(),
      description: map['description'] ?? '',
      actionTaken: map['actionTaken'] ?? '',
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      severity: map['severity'] ?? 'Low',
    );
  }
}