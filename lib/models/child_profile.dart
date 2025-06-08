class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String? zone;
  final String teacherUid;
  final int points; 

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.teacherUid,
    this.zone,
    this.points = 0, 
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'zone': zone,
      'teacherUid': teacherUid,
      'points': points, 
    };
  }

  factory ChildProfile.fromMap(String id, Map<String, dynamic> map) {
    return ChildProfile(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      zone: map['zone'],
      teacherUid: map['teacherUid'] ?? '',
      points: map['points'] ?? 0, 
    );
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? zone,
    String? teacherUid,
    int? points, 
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      zone: zone ?? this.zone,
      teacherUid: teacherUid ?? this.teacherUid,
      points: points ?? this.points,
    );
  }
}