class StaffProfile {
  final String id;
  final String name;
  final String role;
  final String teacherUid;

  final double circleTimeX;
  final double circleTimeY;
  final String circleTimeSide;

  StaffProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.teacherUid,
    this.circleTimeX = 0.75,
    this.circleTimeY = 0.5,
    this.circleTimeSide = 'school',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'teacherUid': teacherUid,
        'circleTimeX': circleTimeX,
        'circleTimeY': circleTimeY,
        'circleTimeSide': circleTimeSide,
      };

  factory StaffProfile.fromMap(String id, Map<String, dynamic> data) {
    return StaffProfile(
      id: id,
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      teacherUid: data['teacherUid'] ?? '',
      circleTimeX: (data['circleTimeX'] ?? 0.75).toDouble(),
      circleTimeY: (data['circleTimeY'] ?? 0.5).toDouble(),
      circleTimeSide: data['circleTimeSide'] ?? 'school',
    );
  }

  StaffProfile copyWith({
    String? id,
    String? name,
    String? role,
    String? teacherUid,
    double? circleTimeX,
    double? circleTimeY,
    String? circleTimeSide,
  }) {
    return StaffProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      teacherUid: teacherUid ?? this.teacherUid,
      circleTimeX: circleTimeX ?? this.circleTimeX,
      circleTimeY: circleTimeY ?? this.circleTimeY,
      circleTimeSide: circleTimeSide ?? this.circleTimeSide,
    );
  }
}