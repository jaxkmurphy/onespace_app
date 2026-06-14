class School {
  final String id;
  final String name;
  final String schoolCode;
  final int classroomLimit;
  final bool active;
  final DateTime? createdAt;

  School({
    required this.id,
    required this.name,
    required this.schoolCode,
    required this.classroomLimit,
    required this.active,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'schoolCode': schoolCode,
      'classroomLimit': classroomLimit,
      'active': active,
      'createdAt': createdAt,
    };
  }

  factory School.fromMap(String id, Map<String, dynamic> map) {
    return School(
      id: id,
      name: map['name'] ?? '',
      schoolCode: map['schoolCode'] ?? '',
      classroomLimit: map['classroomLimit'] ?? 3,
      active: map['active'] ?? true,
      createdAt: map['createdAt']?.toDate(),
    );
  }

  School copyWith({
    String? id,
    String? name,
    String? schoolCode,
    int? classroomLimit,
    bool? active,
    DateTime? createdAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolCode: schoolCode ?? this.schoolCode,
      classroomLimit: classroomLimit ?? this.classroomLimit,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}