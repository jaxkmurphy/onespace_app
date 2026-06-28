import 'package:cloud_firestore/cloud_firestore.dart';

class OddOneOutPack {
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

  const OddOneOutPack({
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

  factory OddOneOutPack.fromMap(String id, Map<String, dynamic> data) {
    return OddOneOutPack(
      id: id,
      title: data['title'] as String? ?? 'Odd One Out',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'target',
      active: data['active'] as bool? ?? true,
      availableToAll: data['availableToAll'] as bool? ?? true,
      assignedChildIds: List<String>.from(
        data['assignedChildIds'] ?? const [],
      ),
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

  OddOneOutPack copyWith({
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
    return OddOneOutPack(
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

class OddOneOutRound {
  final String id;
  final String prompt;
  final List<OddOneOutItem> items;
  final int oddIndex;
  final int sortOrder;

  const OddOneOutRound({
    required this.id,
    required this.prompt,
    required this.items,
    required this.oddIndex,
    required this.sortOrder,
  });

  factory OddOneOutRound.fromMap(String id, Map<String, dynamic> data) {
    final rawItems = data['items'];

    return OddOneOutRound(
      id: id,
      prompt: data['prompt'] as String? ?? '',
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((item) => OddOneOutItem.fromMap(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      oddIndex: (data['oddIndex'] as num?)?.toInt() ?? 0,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'items': items.map((item) => item.toMap()).toList(),
      'oddIndex': oddIndex,
      'sortOrder': sortOrder,
    };
  }

  OddOneOutRound copyWith({
    String? id,
    String? prompt,
    List<OddOneOutItem>? items,
    int? oddIndex,
    int? sortOrder,
  }) {
    return OddOneOutRound(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      items: items ?? this.items,
      oddIndex: oddIndex ?? this.oddIndex,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class OddOneOutItem {
  final String label;
  final String iconName;

  const OddOneOutItem({
    required this.label,
    required this.iconName,
  });

  factory OddOneOutItem.fromMap(Map<String, dynamic> data) {
    return OddOneOutItem(
      label: data['label'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'star',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'iconName': iconName,
    };
  }

  OddOneOutItem copyWith({
    String? label,
    String? iconName,
  }) {
    return OddOneOutItem(
      label: label ?? this.label,
      iconName: iconName ?? this.iconName,
    );
  }
}