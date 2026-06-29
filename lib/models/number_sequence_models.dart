import 'package:cloud_firestore/cloud_firestore.dart';

class NumberSequenceChallenge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int maxNumber;
  final bool timerEnabled;
  final bool active;
  final bool availableToAll;
  final List<String> assignedChildIds;
  final String createdByStaffId;
  final String createdByStaffName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NumberSequenceChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.maxNumber,
    required this.timerEnabled,
    required this.active,
    required this.availableToAll,
    required this.assignedChildIds,
    required this.createdByStaffId,
    required this.createdByStaffName,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory NumberSequenceChallenge.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return NumberSequenceChallenge(
      id: id,
      title: data['title'] as String? ?? 'Number Sequence',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'numbers',
      maxNumber: (data['maxNumber'] as num?)?.toInt() ?? 9,
      timerEnabled: data['timerEnabled'] as bool? ?? true,
      active: data['active'] as bool? ?? true,
      availableToAll: data['availableToAll'] as bool? ?? true,
      assignedChildIds: List<String>.from(data['assignedChildIds'] ?? const []),
      createdByStaffId: data['createdByStaffId'] as String? ?? '',
      createdByStaffName: data['createdByStaffName'] as String? ?? '',
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'maxNumber': maxNumber,
      'timerEnabled': timerEnabled,
      'active': active,
      'availableToAll': availableToAll,
      'assignedChildIds': availableToAll ? <String>[] : assignedChildIds,
      'createdByStaffId': createdByStaffId,
      'createdByStaffName': createdByStaffName,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool isAvailableForChild(String childId) {
    return active && (availableToAll || assignedChildIds.contains(childId));
  }

  NumberSequenceChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? maxNumber,
    bool? timerEnabled,
    bool? active,
    bool? availableToAll,
    List<String>? assignedChildIds,
    String? createdByStaffId,
    String? createdByStaffName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NumberSequenceChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      maxNumber: maxNumber ?? this.maxNumber,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      active: active ?? this.active,
      availableToAll: availableToAll ?? this.availableToAll,
      assignedChildIds: assignedChildIds ?? this.assignedChildIds,
      createdByStaffId: createdByStaffId ?? this.createdByStaffId,
      createdByStaffName: createdByStaffName ?? this.createdByStaffName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
