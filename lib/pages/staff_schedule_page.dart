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
  final _entryController = TextEditingController();
  final _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

  String _selectedDay = 'monday';
  Map<String, List<String>> _schedule = {};
  String? _teacherUid;

  @override
  void initState() {
    super.initState();
    _teacherUid = FirebaseAuth.instance.currentUser?.uid;
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    if (_teacherUid == null) return;
    final schedule = await _firestoreService.getSchedule(_teacherUid!);
    setState(() {
      _schedule = schedule;
    });
  }

  Future<void> _addEntry() async {
    final text = _entryController.text.trim();
    if (text.isEmpty || _teacherUid == null) return;

    await _firestoreService.addScheduleEntry(_teacherUid!, _selectedDay, text);
    _entryController.clear();
    _loadSchedule();
  }

  Future<void> _removeEntry(String entry) async {
    if (_teacherUid == null) return;
    await _firestoreService.removeScheduleEntry(_teacherUid!, _selectedDay, entry);
    _loadSchedule();
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _entryController,
                    decoration: const InputDecoration(labelText: 'Add schedule entry'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEntry,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // *** Replace ListView.builder with ReorderableListView ***
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final updatedList = List<String>.from(entries);
                  final item = updatedList.removeAt(oldIndex);
                  updatedList.insert(newIndex, item);

                  setState(() {
                    _schedule[_selectedDay] = updatedList;
                  });

                  if (_teacherUid != null) {
                    await _firestoreService.setScheduleForDay(_teacherUid!, _selectedDay, updatedList);
                  }
                },
                children: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  return ListTile(
                    key: ValueKey(entry),
                    title: Text(entry),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeEntry(entry),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}