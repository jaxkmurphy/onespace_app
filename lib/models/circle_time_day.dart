import 'package:cloud_firestore/cloud_firestore.dart';

class CircleTimeDay {
  final String id;
  final String weather;
  final String message;
  final DateTime? updatedAt;

  const CircleTimeDay({
    required this.id,
    this.weather = '',
    this.message = '',
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'weather': weather,
      'message': message,
    };
  }

  factory CircleTimeDay.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final updatedAtValue = map['updatedAt'];

    return CircleTimeDay(
      id: id,
      weather: map['weather'] as String? ?? '',
      message: map['message'] as String? ?? '',
      updatedAt: updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : null,
    );
  }

  CircleTimeDay copyWith({
    String? id,
    String? weather,
    String? message,
    DateTime? updatedAt,
  }) {
    return CircleTimeDay(
      id: id ?? this.id,
      weather: weather ?? this.weather,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}