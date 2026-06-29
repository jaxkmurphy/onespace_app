import 'package:cloud_firestore/cloud_firestore.dart';

class ManagedAssociationPairPack {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool active;
  final bool availableToAll;
  final List<String> assignedChildIds;
  final String createdByStaffId;
  final String createdByStaffName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ManagedAssociationPairPack({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
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

  factory ManagedAssociationPairPack.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ManagedAssociationPairPack(
      id: id,
      title: data['title'] as String? ?? 'Association Pairs',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'cards',
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

  ManagedAssociationPairPack copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    bool? active,
    bool? availableToAll,
    List<String>? assignedChildIds,
    String? createdByStaffId,
    String? createdByStaffName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagedAssociationPairPack(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
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

class ManagedAssociationPair {
  final String id;
  final ManagedAssociationPairItem first;
  final ManagedAssociationPairItem second;
  final int sortOrder;

  const ManagedAssociationPair({
    required this.id,
    required this.first,
    required this.second,
    required this.sortOrder,
  });

  factory ManagedAssociationPair.fromMap(String id, Map<String, dynamic> data) {
    return ManagedAssociationPair(
      id: id,
      first: ManagedAssociationPairItem.fromMap(
        Map<String, dynamic>.from(data['first'] as Map? ?? const {}),
      ),
      second: ManagedAssociationPairItem.fromMap(
        Map<String, dynamic>.from(data['second'] as Map? ?? const {}),
      ),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first': first.toMap(),
      'second': second.toMap(),
      'sortOrder': sortOrder,
    };
  }

  ManagedAssociationPair copyWith({
    String? id,
    ManagedAssociationPairItem? first,
    ManagedAssociationPairItem? second,
    int? sortOrder,
  }) {
    return ManagedAssociationPair(
      id: id ?? this.id,
      first: first ?? this.first,
      second: second ?? this.second,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ManagedAssociationPairItem {
  final String label;
  final String iconName;

  const ManagedAssociationPairItem({
    required this.label,
    required this.iconName,
  });

  factory ManagedAssociationPairItem.fromMap(Map<String, dynamic> data) {
    return ManagedAssociationPairItem(
      label: data['label'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'star',
    );
  }

  Map<String, dynamic> toMap() {
    return {'label': label, 'iconName': iconName};
  }
}
