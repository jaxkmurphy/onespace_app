import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionDetectivePack {
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

  const EmotionDetectivePack({
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

  factory EmotionDetectivePack.fromMap(String id, Map<String, dynamic> data) {
    return EmotionDetectivePack(
      id: id,
      title: data['title'] as String? ?? 'Emotion Detective',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'mood_smile',
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

  EmotionDetectivePack copyWith({
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
    return EmotionDetectivePack(
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

class EmotionDetectiveScenario {
  final String id;
  final String prompt;
  final String iconName;
  final List<EmotionChoice> choices;
  final int correctIndex;
  final String explanation;
  final int sortOrder;

  const EmotionDetectiveScenario({
    required this.id,
    required this.prompt,
    required this.iconName,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    required this.sortOrder,
  });

  factory EmotionDetectiveScenario.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawChoices = data['choices'];

    return EmotionDetectiveScenario(
      id: id,
      prompt: data['prompt'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'mood_smile',
      choices: rawChoices is List
          ? rawChoices
              .whereType<Map>()
              .map(
                (choice) => EmotionChoice.fromMap(
                  Map<String, dynamic>.from(choice),
                ),
              )
              .toList()
          : const [],
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: data['explanation'] as String? ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'iconName': iconName,
      'choices': choices.map((choice) => choice.toMap()).toList(),
      'correctIndex': correctIndex,
      'explanation': explanation,
      'sortOrder': sortOrder,
    };
  }

  EmotionDetectiveScenario copyWith({
    String? id,
    String? prompt,
    String? iconName,
    List<EmotionChoice>? choices,
    int? correctIndex,
    String? explanation,
    int? sortOrder,
  }) {
    return EmotionDetectiveScenario(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      iconName: iconName ?? this.iconName,
      choices: choices ?? this.choices,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class EmotionChoice {
  final String label;
  final String iconName;

  const EmotionChoice({
    required this.label,
    required this.iconName,
  });

  factory EmotionChoice.fromMap(Map<String, dynamic> data) {
    return EmotionChoice(
      label: data['label'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'mood_smile',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'iconName': iconName,
    };
  }

  EmotionChoice copyWith({
    String? label,
    String? iconName,
  }) {
    return EmotionChoice(
      label: label ?? this.label,
      iconName: iconName ?? this.iconName,
    );
  }
}