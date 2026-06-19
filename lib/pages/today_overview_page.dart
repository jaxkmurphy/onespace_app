import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../models/child_profile.dart';
import '../models/incident_log_entry.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';

class TodayOverviewPage extends StatefulWidget {
  final StaffProfile staffProfile;

  const TodayOverviewPage({
    super.key,
    required this.staffProfile,
  });

  @override
  State<TodayOverviewPage> createState() => _TodayOverviewPageState();
}

class _TodayOverviewPageState extends State<TodayOverviewPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  String get _teacherUid => widget.staffProfile.teacherUid;

  Stream<List<ChildProfile>> _childrenStream() {
    if (_session.hasClassroomSession) {
      return _firestoreService.getClassroomChildProfiles(
        schoolId: _session.requireSchoolId,
        classroomId: _session.requireClassroomId,
      );
    }

    return _firestoreService.getChildProfiles(_teacherUid);
  }

  String _todayKey() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
      default:
        return 'sunday';
    }
  }

  String _prettyDay(String day) {
    if (day.isEmpty) return day;
    return '${day[0].toUpperCase()}${day.substring(1)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _zoneColor(String? zone) {
    switch (zone?.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return Colors.green;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.health_and_safety),
          label: const Text('View Body Check Reports'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/body-check-overview',
              arguments: {
                'firestoreService': _firestoreService,
                'teacherUid': _teacherUid,
              },
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.event_note),
          label: const Text('Open Incident Log'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncidentLogPage(
                  staffProfile: widget.staffProfile,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.schedule),
          label: const Text('Open Schedule'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaffSchedulePage(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.palette),
          label: const Text('Open Zones Overview'),
          onPressed: () {
            Navigator.pushNamed(context, '/zone-overview');
          },
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildChildrenSummary(List<ChildProfile> children) {
    final childrenWithZones = children
        .where((child) => child.zone != null && child.zone!.isNotEmpty)
        .length;

    return Column(
      children: [
        _summaryCard(
          icon: Icons.groups,
          title: 'Children',
          value: children.length.toString(),
          subtitle: 'Total child profiles',
        ),
        _summaryCard(
          icon: Icons.palette,
          title: 'Zones checked in',
          value: '$childrenWithZones/${children.length}',
          subtitle: 'Children with a selected zone',
        ),
      ],
    );
  }

  Widget _buildZoneSnapshot(List<ChildProfile> children) {
    if (children.isEmpty) {
      return const Text('No child profiles yet.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children.map((child) {
        final zone = child.zone ?? 'No zone';

        return Chip(
          avatar: CircleAvatar(
            backgroundColor: _zoneColor(child.zone),
          ),
          label: Text('${child.name}: $zone'),
        );
      }).toList(),
    );
  }

  Widget _buildBodyCheckSummary() {
    return StreamBuilder<List<BodyCheckReport>>(
      stream: _firestoreService.getCurrentBodyCheckReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final unchecked = reports.where((report) => !report.checked).toList();

        if (unchecked.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('No unchecked Body Check reports'),
              subtitle: Text('Nothing currently needs review.'),
            ),
          );
        }

        return Column(
          children: [
            _summaryCard(
              icon: Icons.health_and_safety,
              title: 'Body Check Reports',
              value: unchecked.length.toString(),
              subtitle: 'Unchecked reports needing staff review',
            ),
            ...unchecked.take(3).map(
                  (report) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: Text(report.childName),
                      subtitle: Text(
                        '${report.bodyPart} • ${report.painType} • ${_formatDate(report.timestamp)}',
                      ),
                    ),
                  ),
                ),
            if (unchecked.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/body-check-overview',
                    arguments: {
                      'firestoreService': _firestoreService,
                      'teacherUid': _teacherUid,
                    },
                  );
                },
                child: Text('View all ${unchecked.length} Body Check reports'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTodaySchedule() {
  final today = _todayKey();

  return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
    future: _firestoreService.getCurrentSchedule(),
    builder: (context, snapshot) {
      final schedule = snapshot.data ?? {};
      final entries = schedule[today] ?? [];

      if (entries.isEmpty) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('No schedule entries for ${_prettyDay(today)}'),
            subtitle: const Text('Nothing has been added for today yet.'),
          ),
        );
      }

      return Column(
        children: entries.map((entry) {
          final start = entry['start'] ?? '';
          final end = entry['end'] ?? '';
          final description = entry['description'] ?? '';

          return Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(description),
              subtitle: Text('$start - $end'),
            ),
          );
        }).toList(),
      );
    },
  );
}

  Widget _buildRecentIncidents() {
  return StreamBuilder<List<IncidentLogEntry>>(
    stream: _firestoreService.getCurrentIncidentLogEntries(),
    builder: (context, snapshot) {
      final incidents = snapshot.data ?? [];

      final importantIncidents = incidents
          .where(
            (incident) =>
                _isToday(incident.timestamp) ||
                incident.severity == 'High' ||
                incident.severity == 'Medium',
          )
          .take(4)
          .toList();

      if (importantIncidents.isEmpty) {
        return const Card(
          child: ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('No important recent incidents'),
            subtitle: Text('No medium/high incidents found for review.'),
          ),
        );
      }

      return Column(
        children: importantIncidents.map((incident) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _severityColor(incident.severity),
                child: const Icon(
                  Icons.event_note,
                  color: Colors.white,
                ),
              ),
              title: Text(incident.childName),
              subtitle: Text(
                '${incident.severity} • ${_formatDate(incident.timestamp)}\n${incident.description}',
              ),
              isThreeLine: true,
            ),
          );
        }).toList(),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: const Text('Today Overview'),
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _childrenStream(),
        builder: (context, snapshot) {
          final children = snapshot.data ?? [];

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Today Overview',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quick classroom overview for ${widget.staffProfile.name}.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _sectionTitle('Quick Actions'),
                _buildQuickActions(),
                _buildChildrenSummary(children),
                _sectionTitle('Zones Snapshot'),
                _buildZoneSnapshot(children),
                _sectionTitle('Body Check Attention'),
                _buildBodyCheckSummary(),
                _sectionTitle('Today\'s Schedule'),
                _buildTodaySchedule(),
                _sectionTitle('Recent / Important Incidents'),
                _buildRecentIncidents(),
              ],
            ),
          );
        },
      ),
    );
  }
}