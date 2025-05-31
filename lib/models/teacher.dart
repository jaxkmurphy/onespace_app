class Teacher {
  final String uid;
  final String email;
  final String name;
  final String? pin; // Optional for backward compatibility

  Teacher({required this.uid, required this.email, required this.name, this.pin});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'pin': pin,
    };
  }

  factory Teacher.fromMap(String uid, Map<String, dynamic> map) {
    return Teacher(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      pin: map['pin'],
    );
  }

  Teacher copyWith({String? uid, String? email, String? name, String? pin}) {
    return Teacher(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      pin: pin ?? this.pin,
    );
  }
}
