import 'package:flutter/material.dart';

class ScheduleActivityType {
  final String key;
  final String label;
  final IconData icon;
  final Color colour;

  const ScheduleActivityType({
    required this.key,
    required this.label,
    required this.icon,
    required this.colour,
  });
}

const List<ScheduleActivityType> scheduleActivityTypes = [
  ScheduleActivityType(
    key: 'learning',
    label: 'Learning',
    icon: Icons.menu_book_rounded,
    colour: Colors.blue,
  ),
  ScheduleActivityType(
    key: 'break',
    label: 'Break',
    icon: Icons.free_breakfast_rounded,
    colour: Colors.teal,
  ),
  ScheduleActivityType(
    key: 'food',
    label: 'Food',
    icon: Icons.restaurant_rounded,
    colour: Colors.orange,
  ),
  ScheduleActivityType(
    key: 'movement',
    label: 'Movement',
    icon: Icons.directions_run_rounded,
    colour: Colors.green,
  ),
  ScheduleActivityType(
    key: 'therapy',
    label: 'Therapy',
    icon: Icons.health_and_safety_rounded,
    colour: Colors.purple,
  ),
  ScheduleActivityType(
    key: 'creative',
    label: 'Creative',
    icon: Icons.palette_rounded,
    colour: Colors.pink,
  ),
  ScheduleActivityType(
    key: 'arrival',
    label: 'Arrival',
    icon: Icons.login_rounded,
    colour: Colors.indigo,
  ),
  ScheduleActivityType(
    key: 'home',
    label: 'Home Time',
    icon: Icons.home_rounded,
    colour: Colors.deepOrange,
  ),
  ScheduleActivityType(
    key: 'other',
    label: 'Other',
    icon: Icons.event_note_rounded,
    colour: Colors.blueGrey,
  ),
];

ScheduleActivityType scheduleActivityTypeFor(
  String key,
) {
  for (final type in scheduleActivityTypes) {
    if (type.key == key) {
      return type;
    }
  }

  return scheduleActivityTypes.last;
}