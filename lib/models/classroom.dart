class Classroom {
  final String id;
  final String schoolId;
  final String name;
  final String classroomCode;
  final String pin;
  final bool active;
  final DateTime? createdAt;

  Classroom({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.classroomCode,
    required this.pin,
    required this.active,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'name': name,
      'classroomCode': classroomCode,
      'pin': pin,
      'active': active,
      'createdAt': createdAt,
    };
  }

  factory Classroom.fromMap(String id, Map<String, dynamic> map) {
    return Classroom(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      classroomCode: map['classroomCode'] ?? '',
      pin: map['pin'] ?? '',
      active: map['active'] ?? true,
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Classroom copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? classroomCode,
    String? pin,
    bool? active,
    DateTime? createdAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      classroomCode: classroomCode ?? this.classroomCode,
      pin: pin ?? this.pin,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}