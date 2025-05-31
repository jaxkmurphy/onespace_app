class StaffProfile {
  final String id;
  final String name;
  final String role;
  final String teacherUid;

  StaffProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.teacherUid,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'teacherUid': teacherUid,
  };

  factory StaffProfile.fromMap(String id, Map<String, dynamic> data) {
    return StaffProfile(
      id: id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      teacherUid: data['teacherUid'] ?? '',
    );
  }

  StaffProfile copyWith({String? id, String? name, String? role, String? teacherUid}) {
    return StaffProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      teacherUid: teacherUid ?? this.teacherUid,
    );
  }
}
