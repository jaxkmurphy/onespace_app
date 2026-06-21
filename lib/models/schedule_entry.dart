class ScheduleEntry {
  final String id;
  final String start;
  final String end;
  final String description;
  final String iconName;

  const ScheduleEntry({
    required this.id,
    required this.start,
    required this.end,
    required this.description,
    this.iconName = 'other',
  });

  factory ScheduleEntry.fromMap(
    Map<String, dynamic> map, {
    required String fallbackId,
  }) {
    return ScheduleEntry(
      id: map['id'] as String? ?? fallbackId,
      start: map['start'] as String? ?? '',
      end: map['end'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'other',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start,
      'end': end,
      'description': description,
      'iconName': iconName,
    };
  }

  int get startMinutes => timeToMinutes(start);

  int get endMinutes => timeToMinutes(end);

  bool overlaps(ScheduleEntry other) {
    return startMinutes < other.endMinutes &&
        endMinutes > other.startMinutes;
  }

  ScheduleEntry copyWith({
    String? id,
    String? start,
    String? end,
    String? description,
    String? iconName,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
    );
  }

  static int timeToMinutes(String time) {
    final parts = time.split(':');

    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return (hour * 60) + minute;
  }
}