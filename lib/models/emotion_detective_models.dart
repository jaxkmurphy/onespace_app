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
  final List<EmotionChoice> feelingChoices;
  final int correctFeelingIndex;
  final List<EmotionChoice> bodyClueChoices;
  final int correctBodyClueIndex;
  final List<EmotionChoice> helpfulActionChoices;
  final int correctHelpfulActionIndex;
  final String explanation;
  final int sortOrder;

  const EmotionDetectiveScenario({
    required this.id,
    required this.prompt,
    required this.iconName,
    required this.feelingChoices,
    required this.correctFeelingIndex,
    required this.bodyClueChoices,
    required this.correctBodyClueIndex,
    required this.helpfulActionChoices,
    required this.correctHelpfulActionIndex,
    required this.explanation,
    required this.sortOrder,
  });

  factory EmotionDetectiveScenario.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final oldChoices = _choicesFromValue(data['choices']);
    final feelingChoices = _choicesFromValue(data['feelingChoices']);

    return EmotionDetectiveScenario(
      id: id,
      prompt: data['prompt'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'mood_smile',
      feelingChoices: feelingChoices.isNotEmpty ? feelingChoices : oldChoices,
      correctFeelingIndex:
          (data['correctFeelingIndex'] as num?)?.toInt() ??
          (data['correctIndex'] as num?)?.toInt() ??
          0,
      bodyClueChoices: _choicesFromValue(data['bodyClueChoices']),
      correctBodyClueIndex:
          (data['correctBodyClueIndex'] as num?)?.toInt() ?? 0,
      helpfulActionChoices: _choicesFromValue(data['helpfulActionChoices']),
      correctHelpfulActionIndex:
          (data['correctHelpfulActionIndex'] as num?)?.toInt() ?? 0,
      explanation: data['explanation'] as String? ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static List<EmotionChoice> _choicesFromValue(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (choice) => EmotionChoice.fromMap(Map<String, dynamic>.from(choice)),
        )
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'iconName': iconName,
      'feelingChoices': feelingChoices.map((choice) => choice.toMap()).toList(),
      'correctFeelingIndex': correctFeelingIndex,
      'bodyClueChoices':
          bodyClueChoices.map((choice) => choice.toMap()).toList(),
      'correctBodyClueIndex': correctBodyClueIndex,
      'helpfulActionChoices':
          helpfulActionChoices.map((choice) => choice.toMap()).toList(),
      'correctHelpfulActionIndex': correctHelpfulActionIndex,
      'explanation': explanation,
      'sortOrder': sortOrder,
    };
  }

  bool get isPlayable {
    return prompt.trim().isNotEmpty &&
        _choiceSetPlayable(feelingChoices, correctFeelingIndex) &&
        _choiceSetPlayable(bodyClueChoices, correctBodyClueIndex) &&
        _choiceSetPlayable(helpfulActionChoices, correctHelpfulActionIndex);
  }

  static bool _choiceSetPlayable(
    List<EmotionChoice> choices,
    int correctIndex,
  ) {
    return choices.length == 4 &&
        choices.every((choice) => choice.label.trim().isNotEmpty) &&
        correctIndex >= 0 &&
        correctIndex < choices.length;
  }

  EmotionDetectiveScenario copyWith({
    String? id,
    String? prompt,
    String? iconName,
    List<EmotionChoice>? feelingChoices,
    int? correctFeelingIndex,
    List<EmotionChoice>? bodyClueChoices,
    int? correctBodyClueIndex,
    List<EmotionChoice>? helpfulActionChoices,
    int? correctHelpfulActionIndex,
    String? explanation,
    int? sortOrder,
  }) {
    return EmotionDetectiveScenario(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      iconName: iconName ?? this.iconName,
      feelingChoices: feelingChoices ?? this.feelingChoices,
      correctFeelingIndex: correctFeelingIndex ?? this.correctFeelingIndex,
      bodyClueChoices: bodyClueChoices ?? this.bodyClueChoices,
      correctBodyClueIndex: correctBodyClueIndex ?? this.correctBodyClueIndex,
      helpfulActionChoices: helpfulActionChoices ?? this.helpfulActionChoices,
      correctHelpfulActionIndex:
          correctHelpfulActionIndex ?? this.correctHelpfulActionIndex,
      explanation: explanation ?? this.explanation,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class EmotionChoice {
  final String label;
  final String iconName;

  const EmotionChoice({required this.label, required this.iconName});

  factory EmotionChoice.fromMap(Map<String, dynamic> data) {
    return EmotionChoice(
      label: data['label'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'mood_smile',
    );
  }

  Map<String, dynamic> toMap() {
    return {'label': label, 'iconName': iconName};
  }

  EmotionChoice copyWith({String? label, String? iconName}) {
    return EmotionChoice(
      label: label ?? this.label,
      iconName: iconName ?? this.iconName,
    );
  }
}
