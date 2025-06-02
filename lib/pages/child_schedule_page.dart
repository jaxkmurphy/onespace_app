import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ChildSchedulePage extends StatefulWidget {
  const ChildSchedulePage({super.key});

  @override
  State<ChildSchedulePage> createState() => _ChildSchedulePageState();
}

class _ChildSchedulePageState extends State<ChildSchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _daysOfWeek.map((day) {
          final entries = _schedule[day] ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
              ...entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('- $e'),
              )),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}