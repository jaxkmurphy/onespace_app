import 'package:flutter/material.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;
  final _descriptionController = TextEditingController();

  final _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

  final List<String> _timeOptions = List.generate(
    24 * 4,
    (i) =>
        '${(i ~/ 4).toString().padLeft(2, '0')}:${(i % 4 * 15).toString().padLeft(2, '0')}',
  );

  String _selectedDay = 'monday';
  String? _selectedStartTime;
  String? _selectedEndTime;
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rawSchedule = await _firestoreService.getCurrentSchedule();

      if (!mounted) return;

      setState(() {
        _schedule = rawSchedule.map((day, entries) {
          final parsed = entries.cast<Map<String, dynamic>>();
          parsed.sort(
            (a, b) => (a['start'] ?? '').compareTo(b['start'] ?? ''),
          );
          return MapEntry(day, parsed);
        });
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load schedule: $e')),
      );
    }
  }

  Future<void> _addOrUpdateEntry({Map<String, dynamic>? oldEntry}) async {
    final desc = _descriptionController.text.trim();

    if (_selectedStartTime == null ||
        _selectedEndTime == null ||
        desc.isEmpty ||
        _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newEntry = {
      'start': _selectedStartTime,
      'end': _selectedEndTime,
      'description': desc,
    };

    try {
      final updatedEntries = [...?_schedule[_selectedDay]];

      if (oldEntry != null) {
        updatedEntries.removeWhere(
          (entry) =>
              entry['start'] == oldEntry['start'] &&
              entry['end'] == oldEntry['end'] &&
              entry['description'] == oldEntry['description'],
        );
      }

      updatedEntries.add(newEntry);
      updatedEntries.sort(
        (a, b) => (a['start'] ?? '').compareTo(b['start'] ?? ''),
      );

      await _firestoreService.setCurrentScheduleForDay(
        day: _selectedDay,
        entries: updatedEntries,
      );

      _descriptionController.clear();

      if (!mounted) return;

      setState(() {
        _selectedStartTime = null;
        _selectedEndTime = null;
      });

      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save schedule entry: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _removeEntry(Map<String, dynamic> entry) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedEntries = [...?_schedule[_selectedDay]];

      updatedEntries.removeWhere(
        (existing) =>
            existing['start'] == entry['start'] &&
            existing['end'] == entry['end'] &&
            existing['description'] == entry['description'],
      );

      await _firestoreService.setCurrentScheduleForDay(
        day: _selectedDay,
        entries: updatedEntries,
      );

      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove schedule entry: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _startEdit(Map<String, dynamic> entry) {
    setState(() {
      _descriptionController.text = entry['description'] ?? '';
      _selectedStartTime = entry['start'];
      _selectedEndTime = entry['end'];
    });

    _removeEntry(entry);
  }

  Color _getColorByTime(String start) {
    final hour = int.tryParse(start.split(':').first) ?? 0;

    if (hour < 10) return Colors.green[100]!;
    if (hour < 14) return Colors.orange[100]!;
    return Colors.blue[100]!;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _schedule[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session.hasClassroomSession
              ? '${_session.currentClassroomName} Schedule'
              : 'Staff Schedule',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedDay,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedDay = value;
                      });
                    },
                    items: _daysOfWeek
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text(day.toUpperCase()),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('start-$_selectedStartTime'),
                          initialValue: _selectedStartTime,
                          hint: const Text('Start Time'),
                          items: _timeOptions
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStartTime = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('end-$_selectedEndTime'),
                          initialValue: _selectedEndTime,
                          hint: const Text('End Time'),
                          items: _timeOptions
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEndTime = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isSaving ? 'Saving...' : 'Save Entry'),
                    onPressed: _isSaving ? null : () => _addOrUpdateEntry(),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: entries.isEmpty
                        ? const Center(
                            child: Text('No schedule entries for this day.'),
                          )
                        : ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final start = entry['start'] ?? '';
                              final end = entry['end'] ?? '';
                              final description = entry['description'] ?? '';

                              return Card(
                                color: _getColorByTime(start),
                                child: ListTile(
                                  title: Text(
                                    '$start–$end: $description',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: _isSaving
                                            ? null
                                            : () => _startEdit(entry),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: _isSaving
                                            ? null
                                            : () => _removeEntry(entry),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}