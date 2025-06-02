class ScheduleEntry {
  final String day; // e.g., "Monday"
  final String activity; // e.g., "Math class at 10 AM"

  ScheduleEntry({
    required this.day,
    required this.activity,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'activity': activity,
    };
  }

  factory ScheduleEntry.fromMap(Map<String, dynamic> map) {
    return ScheduleEntry(
      day: map['day'],
      activity: map['activity'],
    );
  }
}