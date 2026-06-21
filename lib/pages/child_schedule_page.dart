import 'package:flutter/material.dart';
import '../data/schedule_activity_types.dart';
import '../models/schedule_entry.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';

class ChildSchedulePage extends StatefulWidget {
  const ChildSchedulePage({super.key});

  @override
  State<ChildSchedulePage> createState() =>
      _ChildSchedulePageState();
}

class _ChildSchedulePageState
    extends State<ChildSchedulePage> {
  final FirestoreService _firestoreService =
      FirestoreService();

  final ClassroomSessionService _session =
      ClassroomSessionService.instance;

  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  Map<String, List<ScheduleEntry>> _schedule = {
    for (final day in daysOfWeek) day: [],
  };

  late String _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _initialDay();
    _loadSchedule();
  }

  String _initialDay() {
    final weekday = DateTime.now().weekday;

    if (weekday >= DateTime.monday &&
        weekday <= DateTime.friday) {
      return daysOfWeek[weekday - 1];
    }

    return 'monday';
  }

  String _currentDayKey() {
    final weekday = DateTime.now().weekday;

    if (weekday >= DateTime.monday &&
        weekday <= DateTime.friday) {
      return daysOfWeek[weekday - 1];
    }

    return '';
  }

  bool get _selectedDayIsToday {
    return _selectedDay == _currentDayKey();
  }

  String _dayLabel(String day) {
    return '${day[0].toUpperCase()}${day.substring(1)}';
  }

  String _formatTime(String time) {
    final totalMinutes =
        ScheduleEntry.timeToMinutes(time);

    final hour = totalMinutes ~/ 60;
    final minute =
        (totalMinutes % 60).toString().padLeft(2, '0');

    final suffix = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:$minute $suffix';
  }

  int get _currentMinutes {
    final now = DateTime.now();
    return (now.hour * 60) + now.minute;
  }

  Future<void> _loadSchedule() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final rawSchedule =
          await _firestoreService.getCurrentSchedule();

      final parsedSchedule =
          <String, List<ScheduleEntry>>{
        for (final day in daysOfWeek) day: [],
      };

      for (final day in daysOfWeek) {
        final rawEntries = rawSchedule[day] ?? [];
        final entries = <ScheduleEntry>[];

        for (int index = 0;
            index < rawEntries.length;
            index++) {
          final rawEntry = rawEntries[index];

          entries.add(
            ScheduleEntry.fromMap(
              rawEntry,
              fallbackId:
                  'legacy-$day-$index-'
                  '${rawEntry['start'] ?? ''}-'
                  '${rawEntry['end'] ?? ''}',
            ),
          );
        }

        entries.sort(
          (first, second) =>
              first.startMinutes.compareTo(
            second.startMinutes,
          ),
        );

        parsedSchedule[day] = entries;
      }

      if (!mounted) return;

      setState(() {
        _schedule = parsedSchedule;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The schedule could not be loaded.',
          ),
        ),
      );
    }
  }

  ScheduleEntry? _currentActivity(
    List<ScheduleEntry> entries,
  ) {
    if (!_selectedDayIsToday) return null;

    for (final entry in entries) {
      if (_currentMinutes >= entry.startMinutes &&
          _currentMinutes < entry.endMinutes) {
        return entry;
      }
    }

    return null;
  }

  ScheduleEntry? _nextActivity(
    List<ScheduleEntry> entries,
  ) {
    if (!_selectedDayIsToday) return null;

    for (final entry in entries) {
      if (entry.startMinutes > _currentMinutes) {
        return entry;
      }
    }

    return null;
  }

  _ChildScheduleStatus _statusForEntry(
    ScheduleEntry entry,
    ScheduleEntry? current,
    ScheduleEntry? next,
  ) {
    if (!_selectedDayIsToday) {
      return _ChildScheduleStatus.normal;
    }

    if (entry.id == current?.id) {
      return _ChildScheduleStatus.now;
    }

    if (entry.id == next?.id) {
      return _ChildScheduleStatus.next;
    }

    if (entry.endMinutes <= _currentMinutes) {
      return _ChildScheduleStatus.finished;
    }

    return _ChildScheduleStatus.normal;
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        _schedule[_selectedDay] ?? [];

    final current = _currentActivity(entries);
    final next = _nextActivity(entries);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session.hasClassroomSession
              ? '${_session.currentClassroomName} Schedule'
              : 'My Schedule',
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  _buildSummary(
                    entries,
                    current,
                    next,
                  ),
                  _buildDaySelector(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadSchedule,
                      child: entries.isEmpty
                          ? _buildEmptyDay()
                          : _buildTimeline(
                              entries,
                              current,
                              next,
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummary(
    List<ScheduleEntry> entries,
    ScheduleEntry? current,
    ScheduleEntry? next,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        8,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide =
                  constraints.maxWidth >= 700;

              final introduction = Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 36,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _dayLabel(_selectedDay),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            if (_selectedDayIsToday) ...[
                              const SizedBox(width: 8),
                              const Chip(
                                label: Text('Today'),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          entries.isEmpty
                              ? 'No activities today'
                              : '${entries.length} '
                                  '${entries.length == 1 ? "activity" : "activities"}',
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final nowAndNext =
                  _buildNowAndNext(
                entries,
                current,
                next,
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: introduction),
                    const SizedBox(width: 20),
                    Expanded(child: nowAndNext),
                  ],
                );
              }

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  introduction,
                  if (_selectedDayIsToday &&
                      entries.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    nowAndNext,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNowAndNext(
    List<ScheduleEntry> entries,
    ScheduleEntry? current,
    ScheduleEntry? next,
  ) {
    if (!_selectedDayIsToday) {
      return const SizedBox.shrink();
    }

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    if (current != null) {
      final type =
          scheduleActivityTypeFor(
        current.iconName,
      );

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                Colors.green.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              type.icon,
              color: type.colour,
              size: 31,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Happening Now',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    current.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (next != null)
                    Text(
                      'Next: ${next.description}',
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (next != null) {
      final type =
          scheduleActivityTypeFor(
        next.iconName,
      );

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                Colors.amber.withValues(alpha: 0.40),
          ),
        ),
        child: Row(
          children: [
            Icon(
              type.icon,
              color: type.colour,
              size: 31,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coming Next',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    next.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Starts at ${_formatTime(next.start)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.celebration_rounded,
            color: Colors.blue,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All of today’s activities are finished.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        children: daysOfWeek.map((day) {
          final selected =
              day == _selectedDay;
          final today =
              day == _currentDayKey();

          return Padding(
            padding: const EdgeInsets.only(
              right: 9,
            ),
            child: ChoiceChip(
              selected: selected,
              showCheckmark: false,
              avatar: Icon(
                today
                    ? Icons.today_rounded
                    : Icons.calendar_today_outlined,
                size: 19,
              ),
              label: Text(
                today
                    ? '${_dayLabel(day)} • Today'
                    : _dayLabel(day),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedDay = day;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline(
    List<ScheduleEntry> entries,
    ScheduleEntry? current,
    ScheduleEntry? next,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        30,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];

        return _buildTimelineEntry(
          entry: entry,
          status: _statusForEntry(
            entry,
            current,
            next,
          ),
          isLast: index == entries.length - 1,
        );
      },
    );
  }

  Widget _buildTimelineEntry({
    required ScheduleEntry entry,
    required _ChildScheduleStatus status,
    required bool isLast,
  }) {
    final type =
        scheduleActivityTypeFor(
      entry.iconName,
    );

    final isNow =
        status == _ChildScheduleStatus.now;

    final isNext =
        status == _ChildScheduleStatus.next;

    final isFinished =
        status == _ChildScheduleStatus.finished;

    final statusColour = isNow
        ? Colors.green
        : isNext
            ? Colors.orange
            : type.colour;

    return Opacity(
      opacity: isFinished ? 0.58 : 1,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 19,
                right: 9,
              ),
              child: Text(
                _formatTime(entry.start),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: statusColour,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: statusColour,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColour.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 90,
                    color: statusColour.withValues(
                      alpha: 0.25,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isNow ? 7 : 2,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: statusColour.withValues(
                      alpha: isNow ? 0.16 : 0.08,
                    ),
                    border: Border(
                      left: BorderSide(
                        color: statusColour,
                        width: isNow ? 7 : 5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: type.colour
                              .withValues(alpha: 0.16),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Icon(
                          type.icon,
                          color: type.colour,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (isNow)
                              _buildStatusLabel(
                                'NOW',
                                Colors.green,
                              )
                            else if (isNext)
                              _buildStatusLabel(
                                'NEXT',
                                Colors.orange,
                              )
                            else if (isFinished)
                              _buildStatusLabel(
                                'FINISHED',
                                Colors.grey,
                              ),
                            Text(
                              entry.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatTime(entry.start)} – '
                              '${_formatTime(entry.end)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              type.label,
                              style: TextStyle(
                                color: type.colour,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isFinished)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 30,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(
    String label,
    Color colour,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colour,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        30,
        60,
        30,
        30,
      ),
      children: [
        const Icon(
          Icons.event_available_rounded,
          size: 72,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        Text(
          'Nothing is scheduled for '
          '${_dayLabel(_selectedDay)}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Enjoy your day!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}

enum _ChildScheduleStatus {
  normal,
  now,
  next,
  finished,
}