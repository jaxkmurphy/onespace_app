class WordPack {
  final String id;
  final String name;
  final String description;
  final String createdByStaffId;
  final String createdByStaffName;
  final List<String> assignedChildIds;

  WordPack({
    required this.id,
    required this.name,
    required this.description,
    required this.createdByStaffId,
    required this.createdByStaffName,
    required this.assignedChildIds,
  });

  factory WordPack.fromMap(String id, Map<String, dynamic> data) {
    return WordPack(
      id: id,
      name: data['name'] ?? 'Untitled Word Pack',
      description: data['description'] ?? '',
      createdByStaffId: data['createdByStaffId'] ?? '',
      createdByStaffName: data['createdByStaffName'] ?? '',
      assignedChildIds: List<String>.from(data['assignedChildIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdByStaffId': createdByStaffId,
      'createdByStaffName': createdByStaffName,
      'assignedChildIds': assignedChildIds,
    };
  }

  WordPack copyWith({
    String? id,
    String? name,
    String? description,
    String? createdByStaffId,
    String? createdByStaffName,
    List<String>? assignedChildIds,
  }) {
    return WordPack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByStaffId: createdByStaffId ?? this.createdByStaffId,
      createdByStaffName: createdByStaffName ?? this.createdByStaffName,
      assignedChildIds: assignedChildIds ?? this.assignedChildIds,
    );
  }
}