class SchoolMember {
  final String uid;
  final String schoolId;
  final String email;
  final String role;
  final bool active;
  final DateTime? createdAt;

  SchoolMember({
    required this.uid,
    required this.schoolId,
    required this.email,
    required this.role,
    required this.active,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'email': email,
      'role': role,
      'active': active,
      'createdAt': createdAt,
    };
  }

  factory SchoolMember.fromMap(String uid, Map<String, dynamic> map) {
    return SchoolMember(
      uid: uid,
      schoolId: map['schoolId'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'schoolAdmin',
      active: map['active'] ?? true,
      createdAt: map['createdAt']?.toDate(),
    );
  }

  SchoolMember copyWith({
    String? uid,
    String? schoolId,
    String? email,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return SchoolMember(
      uid: uid ?? this.uid,
      schoolId: schoolId ?? this.schoolId,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}