import 'package:flutter/material.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';

class ChildSchedulePage extends StatefulWidget {
  const ChildSchedulePage({super.key});

  @override
  State<ChildSchedulePage> createState() => _ChildSchedulePageState();
}

class _ChildSchedulePageState extends State<ChildSchedulePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  final _daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

  Map<String, List<Map<String, dynamic>>> _schedule = {};
  bool _isLoading = true;

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
      final schedule = await _firestoreService.getCurrentSchedule();

      if (!mounted) return;

      setState(() {
        _schedule = schedule;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session.hasClassroomSession
              ? '${_session.currentClassroomName} Schedule'
              : 'Your Schedule',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _daysOfWeek.map((day) {
                  final entries = _schedule[day] ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (entries.isEmpty)
                            const Text('No schedule entries.')
                          else
                            ...entries.map((entry) {
                              final start = entry['start'] ?? '';
                              final end = entry['end'] ?? '';
                              final desc = entry['description'] ?? '';

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text('- $start – $end : $desc'),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}