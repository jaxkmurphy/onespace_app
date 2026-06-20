import 'package:cloud_firestore/cloud_firestore.dart';

class PointReward {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String iconName;
  final bool active;
  final DateTime? createdAt;

  const PointReward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.iconName,
    required this.active,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'cost': cost,
      'iconName': iconName,
      'active': active,
    };
  }

  factory PointReward.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final createdAtValue = map['createdAt'];

    return PointReward(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      cost: (map['cost'] as num?)?.toInt() ?? 0,
      iconName: map['iconName'] as String? ?? 'gift',
      active: map['active'] as bool? ?? true,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : null,
    );
  }

  PointReward copyWith({
    String? id,
    String? name,
    String? description,
    int? cost,
    String? iconName,
    bool? active,
    DateTime? createdAt,
  }) {
    return PointReward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      iconName: iconName ?? this.iconName,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}