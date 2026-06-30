import 'package:cloud_firestore/cloud_firestore.dart';

class CalmTool {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool active;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CalmTool({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.active,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory CalmTool.fromMap(String id, Map<String, dynamic> data) {
    return CalmTool(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'leaf',
      active: data['active'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'active': active,
      'sortOrder': sortOrder,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  CalmTool copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    bool? active,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalmTool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum CalmRequestStatus {
  active('active'),
  resolved('resolved');

  final String value;

  const CalmRequestStatus(this.value);

  static CalmRequestStatus fromValue(String? value) {
    return CalmRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CalmRequestStatus.active,
    );
  }
}

class CalmRequest {
  final String id;
  final String childId;
  final String childName;
  final String toolId;
  final String toolName;
  final String toolIconName;
  final CalmRequestStatus status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String resolvedByStaffId;
  final String resolvedByStaffName;

  const CalmRequest({
    required this.id,
    required this.childId,
    required this.childName,
    required this.toolId,
    required this.toolName,
    required this.toolIconName,
    required this.status,
    this.createdAt,
    this.resolvedAt,
    required this.resolvedByStaffId,
    required this.resolvedByStaffName,
  });

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory CalmRequest.fromMap(String id, Map<String, dynamic> data) {
    return CalmRequest(
      id: id,
      childId: data['childId'] as String? ?? '',
      childName: data['childName'] as String? ?? '',
      toolId: data['toolId'] as String? ?? '',
      toolName: data['toolName'] as String? ?? '',
      toolIconName: data['toolIconName'] as String? ?? 'leaf',
      status: CalmRequestStatus.fromValue(data['status'] as String?),
      createdAt: _dateFromValue(data['createdAt']),
      resolvedAt: _dateFromValue(data['resolvedAt']),
      resolvedByStaffId: data['resolvedByStaffId'] as String? ?? '',
      resolvedByStaffName: data['resolvedByStaffName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'childName': childName,
      'toolId': toolId,
      'toolName': toolName,
      'toolIconName': toolIconName,
      'status': status.value,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      'resolvedByStaffId': resolvedByStaffId,
      'resolvedByStaffName': resolvedByStaffName,
    };
  }

  CalmRequest copyWith({
    String? id,
    String? childId,
    String? childName,
    String? toolId,
    String? toolName,
    String? toolIconName,
    CalmRequestStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolvedByStaffId,
    String? resolvedByStaffName,
  }) {
    return CalmRequest(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      toolIconName: toolIconName ?? this.toolIconName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedByStaffId: resolvedByStaffId ?? this.resolvedByStaffId,
      resolvedByStaffName: resolvedByStaffName ?? this.resolvedByStaffName,
    );
  }
}

const List<CalmTool> defaultCalmTools = [
  CalmTool(
    id: 'quiet-space',
    name: 'Quiet space',
    description: 'Go somewhere calm and quiet.',
    iconName: 'leaf',
    active: true,
    sortOrder: 0,
  ),
  CalmTool(
    id: 'headphones',
    name: 'Headphones',
    description: 'Use headphones to make things quieter.',
    iconName: 'headphones',
    active: true,
    sortOrder: 1,
  ),
  CalmTool(
    id: 'drink-water',
    name: 'Drink water',
    description: 'Have a drink of water.',
    iconName: 'droplet',
    active: true,
    sortOrder: 2,
  ),
  CalmTool(
    id: 'breathing',
    name: 'Breathing',
    description: 'Take slow breaths.',
    iconName: 'leaf',
    active: true,
    sortOrder: 3,
  ),
  CalmTool(
    id: 'movement-break',
    name: 'Movement break',
    description: 'Move your body safely.',
    iconName: 'run',
    active: true,
    sortOrder: 4,
  ),
  CalmTool(
    id: 'sensory-item',
    name: 'Sensory item',
    description: 'Use a sensory item that helps.',
    iconName: 'puzzle',
    active: true,
    sortOrder: 5,
  ),
  CalmTool(
    id: 'talk-to-teacher',
    name: 'Talk to teacher',
    description: 'Ask a teacher for help.',
    iconName: 'school',
    active: true,
    sortOrder: 6,
  ),
  CalmTool(
    id: 'timer',
    name: 'Timer',
    description: 'Use a timer for a short break.',
    iconName: 'clock',
    active: true,
    sortOrder: 7,
  ),
  CalmTool(
    id: 'draw-write',
    name: 'Draw or write',
    description: 'Draw or write what you need.',
    iconName: 'pencil',
    active: true,
    sortOrder: 8,
  ),
  CalmTool(
    id: 'calming-sound',
    name: 'Calming sound',
    description: 'Listen to a calming sound.',
    iconName: 'music',
    active: true,
    sortOrder: 9,
  ),
];