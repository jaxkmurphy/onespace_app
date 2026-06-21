import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentLogEntry {
  final String id;
  final String childId;
  final String childName;
  final DateTime timestamp;

  final String description;
  final String actionTaken;
  final String severity;
  final String category;

  final String staffId;
  final String staffName;

  final String followUpStatus;
  final String followUpNotes;

  final DateTime? updatedAt;
  final String updatedByStaffId;
  final String updatedByStaffName;

  final bool isArchived;
  final DateTime? archivedAt;
  final String archivedByStaffId;
  final String archivedByStaffName;
  final String archiveReason;

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
    this.category = 'other',
    this.followUpStatus = 'none',
    this.followUpNotes = '',
    this.updatedAt,
    this.updatedByStaffId = '',
    this.updatedByStaffName = '',
    this.isArchived = false,
    this.archivedAt,
    this.archivedByStaffId = '',
    this.archivedByStaffName = '',
    this.archiveReason = '',
  });

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
      'childId': childId,
      'childName': childName,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'actionTaken': actionTaken,
      'severity': severity,
      'category': category,
      'staffId': staffId,
      'staffName': staffName,
      'followUpStatus': followUpStatus,
      'followUpNotes': followUpNotes,
      'updatedByStaffId': updatedByStaffId,
      'updatedByStaffName': updatedByStaffName,
      'isArchived': isArchived,
      'archivedByStaffId': archivedByStaffId,
      'archivedByStaffName': archivedByStaffName,
      'archiveReason': archiveReason,
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
      if (archivedAt != null)
        'archivedAt': Timestamp.fromDate(archivedAt!),
    };
  }

  factory IncidentLogEntry.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return IncidentLogEntry(
      id: id,
      childId: map['childId'] as String? ?? '',
      childName: map['childName'] as String? ?? '',
      timestamp:
          _dateFromValue(map['timestamp']) ?? DateTime.now(),
      description: map['description'] as String? ?? '',
      actionTaken: map['actionTaken'] as String? ?? '',
      severity: map['severity'] as String? ?? 'Low',
      category: map['category'] as String? ?? 'other',
      staffId: map['staffId'] as String? ?? '',
      staffName: map['staffName'] as String? ?? '',
      followUpStatus:
          map['followUpStatus'] as String? ?? 'none',
      followUpNotes:
          map['followUpNotes'] as String? ?? '',
      updatedAt: _dateFromValue(map['updatedAt']),
      updatedByStaffId:
          map['updatedByStaffId'] as String? ?? '',
      updatedByStaffName:
          map['updatedByStaffName'] as String? ?? '',
      isArchived: map['isArchived'] as bool? ?? false,
      archivedAt: _dateFromValue(map['archivedAt']),
      archivedByStaffId:
          map['archivedByStaffId'] as String? ?? '',
      archivedByStaffName:
          map['archivedByStaffName'] as String? ?? '',
      archiveReason:
          map['archiveReason'] as String? ?? '',
    );
  }

  IncidentLogEntry copyWith({
    String? id,
    String? childId,
    String? childName,
    DateTime? timestamp,
    String? description,
    String? actionTaken,
    String? severity,
    String? category,
    String? staffId,
    String? staffName,
    String? followUpStatus,
    String? followUpNotes,
    DateTime? updatedAt,
    String? updatedByStaffId,
    String? updatedByStaffName,
    bool? isArchived,
    DateTime? archivedAt,
    String? archivedByStaffId,
    String? archivedByStaffName,
    String? archiveReason,
  }) {
    return IncidentLogEntry(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      actionTaken: actionTaken ?? this.actionTaken,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      followUpStatus:
          followUpStatus ?? this.followUpStatus,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByStaffId:
          updatedByStaffId ?? this.updatedByStaffId,
      updatedByStaffName:
          updatedByStaffName ?? this.updatedByStaffName,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedByStaffId:
          archivedByStaffId ?? this.archivedByStaffId,
      archivedByStaffName:
          archivedByStaffName ?? this.archivedByStaffName,
      archiveReason: archiveReason ?? this.archiveReason,
    );
  }
}