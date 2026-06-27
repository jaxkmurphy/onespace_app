class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String? zone;
  final String teacherUid;
  final int points;
  final String? backgroundColorHex;

  final String accessMode;
  final List<String> iconSequence;

  final bool profileAccessEnabled;
  final int profileAccessRevokedAtMillis;

  // Circle Time
  final double circleTimeX;
  final double circleTimeY;
  final String circleTimeSide;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.teacherUid,
    this.zone,
    this.points = 0,
    this.backgroundColorHex,
    this.accessMode = 'iconSequence',
    this.iconSequence = const [],
    this.profileAccessEnabled = true,
    this.profileAccessRevokedAtMillis = 0,
    this.circleTimeX = 0.25,
    this.circleTimeY = 0.5,
    this.circleTimeSide = 'home',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'zone': zone,
      'teacherUid': teacherUid,
      'points': points,
      'backgroundColorHex': backgroundColorHex,
      'accessMode': accessMode,
      'iconSequence': iconSequence,
      'profileAccessEnabled': profileAccessEnabled,
      'profileAccessRevokedAtMillis': profileAccessRevokedAtMillis,
      'circleTimeX': circleTimeX,
      'circleTimeY': circleTimeY,
      'circleTimeSide': circleTimeSide,
    };
  }

  factory ChildProfile.fromMap(String id, Map<String, dynamic> map) {
    final backgroundColorHex =
        map['backgroundColorHex'] ?? map['backgroundColor'];

    return ChildProfile(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      zone: map['zone'],
      teacherUid: map['teacherUid'] ?? '',
      points: map['points'] ?? 0,
      backgroundColorHex: backgroundColorHex,
      accessMode: map['accessMode'] ?? 'iconSequence',
      iconSequence: List<String>.from(map['iconSequence'] ?? []),
      profileAccessEnabled: map['profileAccessEnabled'] ?? true,
      profileAccessRevokedAtMillis: map['profileAccessRevokedAtMillis'] ?? 0,
      circleTimeX: (map['circleTimeX'] ?? 0.25).toDouble(),
      circleTimeY: (map['circleTimeY'] ?? 0.5).toDouble(),
      circleTimeSide: map['circleTimeSide'] ?? 'home',
    );
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? zone,
    String? teacherUid,
    int? points,
    String? backgroundColorHex,
    String? accessMode,
    List<String>? iconSequence,
    bool? profileAccessEnabled,
    int? profileAccessRevokedAtMillis,
    double? circleTimeX,
    double? circleTimeY,
    String? circleTimeSide,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      zone: zone ?? this.zone,
      teacherUid: teacherUid ?? this.teacherUid,
      points: points ?? this.points,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      accessMode: accessMode ?? this.accessMode,
      iconSequence: iconSequence ?? this.iconSequence,
      profileAccessEnabled: profileAccessEnabled ?? this.profileAccessEnabled,
      profileAccessRevokedAtMillis:
          profileAccessRevokedAtMillis ?? this.profileAccessRevokedAtMillis,
      circleTimeX: circleTimeX ?? this.circleTimeX,
      circleTimeY: circleTimeY ?? this.circleTimeY,
      circleTimeSide: circleTimeSide ?? this.circleTimeSide,
    );
  }
}