import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/schedule_activity_types.dart';
import '../models/schedule_entry.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() =>
      _StaffSchedulePageState();
}

class _StaffSchedulePageState
    extends State<StaffSchedulePage> {
  final FirestoreService _firestoreService =
      FirestoreService();

  final ClassroomSessionService _session =
      ClassroomSessionService.instance;

  static const int dayStartMinutes = (8 * 60) + 30;
  static const int dayEndMinutes = 17 * 60;
  static const int slotMinutes = 30;
  static const int durationStepMinutes = 15;

  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  String _selectedDay = 'monday';

  Map<String, List<ScheduleEntry>> _schedule = {
    for (final day in daysOfWeek) day: [],
  };

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  String _dayLabel(String day) {
    return '${day[0].toUpperCase()}${day.substring(1)}';
  }

  String _minutesToTime(int totalMinutes) {
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeFromMinutes(int totalMinutes) {
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

  String _formatTime(String time) {
    return _formatTimeFromMinutes(
      ScheduleEntry.timeToMinutes(time),
    );
  }

  String _durationLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return hours == 1 ? '1 hour' : '$hours hours';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  String _newEntryId() {
    return DateTime.now()
        .microsecondsSinceEpoch
        .toString();
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
            'The classroom schedule could not be loaded.',
          ),
        ),
      );
    }
  }

  Future<void> _saveDay(
    String day,
    List<ScheduleEntry> entries,
  ) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final sortedEntries = [...entries]
        ..sort(
          (first, second) =>
              first.startMinutes.compareTo(
            second.startMinutes,
          ),
        );

      await _firestoreService.setCurrentScheduleForDay(
        day: day,
        entries: sortedEntries
            .map((entry) => entry.toMap())
            .toList(),
      );

      if (!mounted) return;

      setState(() {
        _schedule[day] = sortedEntries;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _hasOverlap(
    ScheduleEntry candidate, {
    String? ignoredId,
  }) {
    final entries = _schedule[_selectedDay] ?? [];

    return entries.any((entry) {
      if (entry.id == ignoredId) return false;
      return candidate.overlaps(entry);
    });
  }

  List<_ScheduleTimelineItem> _buildTimeline(
    List<ScheduleEntry> entries,
  ) {
    final sortedEntries = [...entries]
      ..sort(
        (first, second) =>
            first.startMinutes.compareTo(
          second.startMinutes,
        ),
      );

    final items = <_ScheduleTimelineItem>[];
    int cursor = dayStartMinutes;

    for (final entry in sortedEntries) {
      final start = entry.startMinutes;
      final end = entry.endMinutes;

      if (end <= dayStartMinutes ||
          start >= dayEndMinutes) {
        continue;
      }

      if (start > cursor) {
        _addEmptySlots(
          items,
          cursor,
          math.min(start, dayEndMinutes),
        );
      }

      items.add(
        _ScheduleTimelineItem.activity(entry),
      );

      cursor = math.max(cursor, end);

      if (cursor >= dayEndMinutes) {
        break;
      }
    }

    if (cursor < dayEndMinutes) {
      _addEmptySlots(
        items,
        cursor,
        dayEndMinutes,
      );
    }

    return items;
  }

  void _addEmptySlots(
    List<_ScheduleTimelineItem> items,
    int start,
    int end,
  ) {
    int cursor = start;

    while (cursor < end) {
      final slotEnd = math.min(
        cursor + slotMinutes,
        end,
      );

      items.add(
        _ScheduleTimelineItem.empty(
          startMinutes: cursor,
          endMinutes: slotEnd,
        ),
      );

      cursor = slotEnd;
    }
  }

  Future<void> _showActivityEditor({
    ScheduleEntry? existingEntry,
    int? initialStartMinutes,
    int? availableSlotMinutes,
  }) async {
    final descriptionController =
        TextEditingController(
      text: existingEntry?.description ?? '',
    );

    final startMinutes = existingEntry?.startMinutes ??
        initialStartMinutes ??
        dayStartMinutes;

    int durationMinutes = existingEntry == null
        ? math.min(
            slotMinutes,
            availableSlotMinutes ??
                (dayEndMinutes - startMinutes),
          )
        : existingEntry.endMinutes -
            existingEntry.startMinutes;

    if (durationMinutes < durationStepMinutes) {
      durationMinutes = durationStepMinutes;
    }

    String selectedIcon =
        existingEntry?.iconName ?? 'learning';

    bool dialogSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final maximumDuration =
                dayEndMinutes - startMinutes;

            final endMinutes =
                startMinutes + durationMinutes;

            return AlertDialog(
              title: Text(
                existingEntry == null
                    ? 'Fill Time Slot'
                    : 'Edit Activity',
              ),
              content: SizedBox(
                width: 570,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _dayLabel(_selectedDay),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatTimeFromMinutes(startMinutes)}'
                              ' – '
                              '${_formatTimeFromMinutes(endMinutes)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _durationLabel(
                                durationMinutes,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Duration',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  dialogSaving ||
                                          durationMinutes <=
                                              durationStepMinutes
                                      ? null
                                      : () {
                                          setDialogState(
                                            () {
                                              durationMinutes -=
                                                  durationStepMinutes;
                                            },
                                          );
                                        },
                              icon: const Icon(
                                Icons.remove_rounded,
                              ),
                              label: const Text(
                                '15 minutes',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            constraints:
                                const BoxConstraints(
                              minWidth: 95,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Text(
                              _durationLabel(
                                durationMinutes,
                              ),
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  dialogSaving ||
                                          durationMinutes +
                                                  durationStepMinutes >
                                              maximumDuration
                                      ? null
                                      : () {
                                          setDialogState(
                                            () {
                                              durationMinutes +=
                                                  durationStepMinutes;
                                            },
                                          );
                                        },
                              icon: const Icon(
                                Icons.add_rounded,
                              ),
                              label: const Text(
                                '15 minutes',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller:
                            descriptionController,
                        enabled: !dialogSaving,
                        maxLength: 80,
                        textCapitalization:
                            TextCapitalization.sentences,
                        decoration:
                            const InputDecoration(
                          labelText: 'Activity name',
                          hintText:
                              'Example: Morning reading',
                          prefixIcon: Icon(
                            Icons.edit_note_rounded,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Activity type',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            scheduleActivityTypes
                                .map((type) {
                          return ChoiceChip(
                            selected:
                                selectedIcon ==
                                    type.key,
                            avatar: Icon(
                              type.icon,
                              color: type.colour,
                              size: 20,
                            ),
                            label:
                                Text(type.label),
                            onSelected:
                                dialogSaving
                                    ? null
                                    : (_) {
                                        setDialogState(
                                          () {
                                            selectedIcon =
                                                type.key;
                                          },
                                        );
                                      },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogSaving
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: dialogSaving
                      ? null
                      : () async {
                          final description =
                              descriptionController
                                  .text
                                  .trim();

                          if (description.isEmpty) {
                            _showDialogMessage(
                              dialogContext,
                              'Please enter an activity name.',
                            );
                            return;
                          }

                          final endMinutes =
                              startMinutes +
                                  durationMinutes;

                          final entry =
                              ScheduleEntry(
                            id: existingEntry?.id ??
                                _newEntryId(),
                            start: _minutesToTime(
                              startMinutes,
                            ),
                            end: _minutesToTime(
                              endMinutes,
                            ),
                            description:
                                description,
                            iconName:
                                selectedIcon,
                          );

                          if (_hasOverlap(
                            entry,
                            ignoredId:
                                existingEntry?.id,
                          )) {
                            _showDialogMessage(
                              dialogContext,
                              'This duration overlaps another scheduled activity.',
                            );
                            return;
                          }

                          setDialogState(() {
                            dialogSaving = true;
                          });

                          try {
                            final entries = [
                              ...?_schedule[
                                  _selectedDay],
                            ];

                            if (existingEntry ==
                                null) {
                              entries.add(entry);
                            } else {
                              final index =
                                  entries.indexWhere(
                                (item) =>
                                    item.id ==
                                    existingEntry.id,
                              );

                              if (index >= 0) {
                                entries[index] =
                                    entry;
                              }
                            }

                            await _saveDay(
                              _selectedDay,
                              entries,
                            );

                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                            );
                          } catch (e) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              dialogSaving =
                                  false;
                            });

                            _showDialogMessage(
                              dialogContext,
                              'The activity could not be saved.',
                            );
                          }
                        },
                  icon: dialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save_rounded,
                        ),
                  label: Text(
                    dialogSaving
                        ? 'Saving...'
                        : existingEntry == null
                            ? 'Fill Slot'
                            : 'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 350),
    );

    descriptionController.dispose();
  }

  void _showDialogMessage(
    BuildContext dialogContext,
    String message,
  ) {
    ScaffoldMessenger.of(dialogContext).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteEntry(
    ScheduleEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear This Slot?'),
          content: Text(
            'Remove "${entry.description}" from '
            '${_dayLabel(_selectedDay)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Clear Slot'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final entries = [
      ...?_schedule[_selectedDay],
    ]..removeWhere(
        (item) => item.id == entry.id,
      );

    try {
      await _saveDay(
        _selectedDay,
        entries,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The activity could not be removed.',
          ),
        ),
      );
    }
  }

  Future<void> _copyCurrentDay() async {
    final availableDays = daysOfWeek
        .where((day) => day != _selectedDay)
        .toList();

    String selectedTarget = availableDays.first;

    final targetDay = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Copy Schedule'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Copy all activities from '
                      '${_dayLabel(_selectedDay)} to:',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTarget,
                      decoration:
                          const InputDecoration(
                        labelText: 'Target day',
                        border:
                            OutlineInputBorder(),
                      ),
                      items: availableDays
                          .map(
                            (day) =>
                                DropdownMenuItem(
                              value: day,
                              child: Text(
                                _dayLabel(day),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedTarget = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selectedTarget,
                    );
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                  ),
                  label: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    if (targetDay == null || !mounted) return;

    final targetEntries =
        _schedule[targetDay] ?? [];

    if (targetEntries.isNotEmpty) {
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Replace Existing Schedule?',
            ),
            content: Text(
              '${_dayLabel(targetDay)} already has '
              '${targetEntries.length} '
              '${targetEntries.length == 1 ? "activity" : "activities"}.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child: const Text('Replace'),
              ),
            ],
          );
        },
      );

      if (overwrite != true || !mounted) return;
    }

    final sourceEntries =
        _schedule[_selectedDay] ?? [];

    final copiedEntries = List.generate(
      sourceEntries.length,
      (index) => sourceEntries[index].copyWith(
        id: '${_newEntryId()}-$index',
      ),
    );

    try {
      await _saveDay(
        targetDay,
        copiedEntries,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_dayLabel(_selectedDay)} was copied to '
            '${_dayLabel(targetDay)}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The schedule could not be copied.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        _schedule[_selectedDay] ?? [];

    final timeline = _buildTimeline(entries);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session.hasClassroomSession
              ? '${_session.currentClassroomName} Schedule'
              : 'Staff Schedule',
        ),
        actions: [
          IconButton(
            tooltip: 'Copy this day',
            onPressed:
                _isSaving || entries.isEmpty
                    ? null
                    : _copyCurrentDay,
            icon: const Icon(
              Icons.copy_all_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : Column(
                children: [
                  _buildHeader(entries),
                  _buildDaySelector(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadSchedule,
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          10,
                          18,
                          30,
                        ),
                        itemCount: timeline.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                          height: 6,
                        ),
                        itemBuilder:
                            (context, index) {
                          final item =
                              timeline[index];

                          if (item.entry != null) {
                            return _buildActivitySlot(
                              item.entry!,
                            );
                          }

                          return _buildEmptySlot(
                            item,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(
    List<ScheduleEntry> entries,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        8,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(19),
                ),
                child: Icon(
                  Icons.view_timeline_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,
                  size: 33,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayLabel(_selectedDay),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    Text(
                      entries.isEmpty
                          ? 'Tap a blank slot to begin'
                          : '${entries.length} '
                              '${entries.length == 1 ? "activity" : "activities"} scheduled',
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed:
                    _isSaving || entries.isEmpty
                        ? null
                        : _copyCurrentDay,
                icon: const Icon(
                  Icons.copy_rounded,
                ),
                label: const Text('Copy Day'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        children: daysOfWeek.map((day) {
          final selected =
              day == _selectedDay;

          return Padding(
            padding:
                const EdgeInsets.only(
              right: 9,
            ),
            child: ChoiceChip(
              selected: selected,
              showCheckmark: false,
              avatar: Icon(
                selected
                    ? Icons
                        .calendar_today_rounded
                    : Icons
                        .calendar_today_outlined,
                size: 19,
              ),
              label: Text(
                _dayLabel(day),
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

  Widget _buildEmptySlot(
    _ScheduleTimelineItem item,
  ) {
    final duration =
        item.endMinutes - item.startMinutes;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 18,
              right: 10,
            ),
            child: Text(
              _formatTimeFromMinutes(
                item.startMinutes,
              ),
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _isSaving
                  ? null
                  : () {
                      _showActivityEditor(
                        initialStartMinutes:
                            item.startMinutes,
                        availableSlotMinutes:
                            duration,
                      );
                    },
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      duration <= 15 ? 54 : 68,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLowest,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant,
                    style: BorderStyle.solid,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        duration <= 15
                            ? 'Add 15-minute activity'
                            : 'Tap to add activity',
                        style: TextStyle(
                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .primary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _durationLabel(duration),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySlot(
    ScheduleEntry entry,
  ) {
    final type =
        scheduleActivityTypeFor(
      entry.iconName,
    );

    final duration =
        entry.endMinutes - entry.startMinutes;

    final minimumHeight =
        math.max(82.0, duration * 1.65);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 19,
              right: 10,
            ),
            child: Text(
              _formatTime(entry.start),
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _isSaving
                  ? null
                  : () {
                      _showActivityEditor(
                        existingEntry: entry,
                      );
                    },
              child: Container(
                constraints: BoxConstraints(
                  minHeight: minimumHeight,
                ),
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: type.colour
                      .withValues(alpha: 0.12),
                  border: Border(
                    left: BorderSide(
                      color: type.colour,
                      width: 7,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: type.colour
                            .withValues(
                          alpha: 0.17,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),
                      child: Icon(
                        type.icon,
                        color: type.colour,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.description,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatTime(entry.start)}'
                            ' – '
                            '${_formatTime(entry.end)}'
                            ' • '
                            '${_durationLabel(duration)}',
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
                    IconButton(
                      tooltip: 'Edit activity',
                      onPressed: _isSaving
                          ? null
                          : () {
                              _showActivityEditor(
                                existingEntry:
                                    entry,
                              );
                            },
                      icon: const Icon(
                        Icons.edit_rounded,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Clear slot',
                      onPressed: _isSaving
                          ? null
                          : () =>
                              _deleteEntry(entry),
                      icon: const Icon(
                        Icons
                            .delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleTimelineItem {
  final int startMinutes;
  final int endMinutes;
  final ScheduleEntry? entry;

  const _ScheduleTimelineItem._({
    required this.startMinutes,
    required this.endMinutes,
    required this.entry,
  });

  factory _ScheduleTimelineItem.empty({
    required int startMinutes,
    required int endMinutes,
  }) {
    return _ScheduleTimelineItem._(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      entry: null,
    );
  }

  factory _ScheduleTimelineItem.activity(
    ScheduleEntry entry,
  ) {
    return _ScheduleTimelineItem._(
      startMinutes: entry.startMinutes,
      endMinutes: entry.endMinutes,
      entry: entry,
    );
  }
}