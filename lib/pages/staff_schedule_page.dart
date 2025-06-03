import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _descriptionController = TextEditingController();

  final _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  final List<String> _timeOptions = List.generate(
    24 * 4,
    (i) => '${(i ~/ 4).toString().padLeft(2, '0')}:${(i % 4 * 15).toString().padLeft(2, '0')}',
  );

  String _selectedDay = 'monday';
  String? _selectedStartTime;
  String? _selectedEndTime;
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  String? _teacherUid;

  @override
  void initState() {
    super.initState();
    _teacherUid = FirebaseAuth.instance.currentUser?.uid;
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    if (_teacherUid == null) return;
    final rawSchedule = await _firestoreService.getSchedule(_teacherUid!);
    setState(() {
      _schedule = rawSchedule.map((day, entries) {
        final parsed = entries.cast<Map<String, dynamic>>();
        parsed.sort((a, b) => (a['start'] ?? '').compareTo(b['start'] ?? ''));
        return MapEntry(day, parsed);
      });
    });
  }

  Future<void> _addOrUpdateEntry({Map<String, dynamic>? oldEntry}) async {
    final desc = _descriptionController.text.trim();
    if (_teacherUid == null || _selectedStartTime == null || _selectedEndTime == null || desc.isEmpty) return;

    final newEntry = {
      'start': _selectedStartTime,
      'end': _selectedEndTime,
      'description': desc,
    };

    final updatedEntries = [...?_schedule[_selectedDay]];
    if (oldEntry != null) updatedEntries.remove(oldEntry);
    updatedEntries.add(newEntry);
    updatedEntries.sort((a, b) => a['start'].compareTo(b['start']));

    await _firestoreService.setScheduleForDay(_teacherUid!, _selectedDay, updatedEntries);

    _descriptionController.clear();
    _selectedStartTime = null;
    _selectedEndTime = null;

    _loadSchedule();
  }

  Future<void> _removeEntry(Map<String, dynamic> entry) async {
    if (_teacherUid == null) return;
    final updatedEntries = [...?_schedule[_selectedDay]];
    updatedEntries.remove(entry);
    await _firestoreService.setScheduleForDay(_teacherUid!, _selectedDay, updatedEntries);
    _loadSchedule();
  }

  void _startEdit(Map<String, dynamic> entry) {
    setState(() {
      _descriptionController.text = entry['description'];
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
  Widget build(BuildContext context) {
    final entries = _schedule[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedDay,
              onChanged: (value) => setState(() => _selectedDay = value!),
              items: _daysOfWeek
                  .map((day) => DropdownMenuItem(value: day, child: Text(day.toUpperCase())))
                  .toList(),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStartTime,
                    hint: const Text("Start Time"),
                    items: _timeOptions.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                    onChanged: (value) => setState(() => _selectedStartTime = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEndTime,
                    hint: const Text("End Time"),
                    items: _timeOptions.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                    onChanged: (value) => setState(() => _selectedEndTime = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Save Entry'),
              onPressed: () => _addOrUpdateEntry(),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    color: _getColorByTime(entry['start']),
                    child: ListTile(
                      title: Text('${entry['start']}–${entry['end']}: ${entry['description']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _startEdit(entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeEntry(entry),
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