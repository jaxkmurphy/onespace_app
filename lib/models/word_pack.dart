import 'package:cloud_firestore/cloud_firestore.dart';

class WordPack {
  final String id;
  final String name;
  final String description;

  final String createdByStaffId;
  final String createdByStaffName;

  final bool availableToAll;
  final List<String> assignedChildIds;

  final String iconName;
  final String colorHex;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  WordPack({
    required this.id,
    required this.name,
    required this.description,
    required this.createdByStaffId,
    required this.createdByStaffName,
    required this.assignedChildIds,
    this.availableToAll = false,
    this.iconName = 'words',
    this.colorHex = '#66BB6A',
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    return null;
  }

  factory WordPack.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return WordPack(
      id: id,
      name: data['name'] as String? ?? 'Untitled Word Pack',
      description: data['description'] as String? ?? '',
      createdByStaffId:
          data['createdByStaffId'] as String? ?? '',
      createdByStaffName:
          data['createdByStaffName'] as String? ?? '',
      availableToAll:
          data['availableToAll'] as bool? ?? false,
      assignedChildIds: List<String>.from(
        data['assignedChildIds'] ?? const [],
      ),
      iconName: data['iconName'] as String? ?? 'words',
      colorHex: data['colorHex'] as String? ?? '#66BB6A',
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdByStaffId': createdByStaffId,
      'createdByStaffName': createdByStaffName,
      'availableToAll': availableToAll,
      'assignedChildIds':
          availableToAll ? <String>[] : assignedChildIds,
      'iconName': iconName,
      'colorHex': colorHex,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  bool isAvailableForChild(String childId) {
    return availableToAll || assignedChildIds.contains(childId);
  }

  WordPack copyWith({
    String? id,
    String? name,
    String? description,
    String? createdByStaffId,
    String? createdByStaffName,
    bool? availableToAll,
    List<String>? assignedChildIds,
    String? iconName,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordPack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByStaffId:
          createdByStaffId ?? this.createdByStaffId,
      createdByStaffName:
          createdByStaffName ?? this.createdByStaffName,
      availableToAll:
          availableToAll ?? this.availableToAll,
      assignedChildIds:
          assignedChildIds ?? this.assignedChildIds,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}