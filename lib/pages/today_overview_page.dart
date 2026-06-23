import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../models/child_profile.dart';
import '../models/incident_log_entry.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';
import '../l10n/body_check_localizations.dart';
import '../l10n/l10n.dart';
import '../l10n/zone_localizations.dart';

class TodayOverviewPage extends StatefulWidget {
  final StaffProfile staffProfile;

  const TodayOverviewPage({super.key, required this.staffProfile});

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
    return switch (day) {
      'monday' => context.l10n.scheduleMonday,
      'tuesday' => context.l10n.scheduleTuesday,
      'wednesday' => context.l10n.scheduleWednesday,
      'thursday' => context.l10n.scheduleThursday,
      'friday' => context.l10n.scheduleFriday,
      'saturday' => context.l10n.scheduleSaturday,
      'sunday' => context.l10n.scheduleSunday,
      _ => day,
    };
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

  String _severityLabel(String severity) => switch (severity) {
    'High' => context.l10n.severityHigh,
    'Medium' => context.l10n.severityMedium,
    _ => context.l10n.severityLow,
  };

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
          label: Text(context.l10n.viewBodyCheckReports),
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
          label: Text(context.l10n.openIncidentLog),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => IncidentLogPage(staffProfile: widget.staffProfile),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.schedule),
          label: Text(context.l10n.openSchedule),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StaffSchedulePage()),
            );
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.palette),
          label: Text(context.l10n.openZonesOverview),
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
            CircleAvatar(child: Icon(icon)),
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
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
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
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChildrenSummary(List<ChildProfile> children) {
    final childrenWithZones =
        children
            .where((child) => child.zone != null && child.zone!.isNotEmpty)
            .length;

    return Column(
      children: [
        _summaryCard(
          icon: Icons.groups,
          title: context.l10n.children,
          value: children.length.toString(),
          subtitle: context.l10n.totalChildProfiles,
        ),
        _summaryCard(
          icon: Icons.palette,
          title: context.l10n.zonesCheckedIn,
          value: '$childrenWithZones/${children.length}',
          subtitle: context.l10n.childrenWithSelectedZone,
        ),
      ],
    );
  }

  Widget _buildZoneSnapshot(List<ChildProfile> children) {
    if (children.isEmpty) {
      return Text(context.l10n.noChildProfilesYet);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          children.map((child) {
            final zone =
                child.zone == null
                    ? context.l10n.noZone
                    : localizedZoneName(context.l10n, child.zone!);

            return Chip(
              avatar: CircleAvatar(backgroundColor: _zoneColor(child.zone)),
              label: Text(context.l10n.childZoneSummary(child.name, zone)),
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
          return Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(context.l10n.noUncheckedBodyChecks),
              subtitle: Text(context.l10n.nothingNeedsReview),
            ),
          );
        }

        return Column(
          children: [
            _summaryCard(
              icon: Icons.health_and_safety,
              title: context.l10n.bodyCheckReports,
              value: unchecked.length.toString(),
              subtitle: context.l10n.uncheckedBodyChecksIntro,
            ),
            ...unchecked
                .take(3)
                .map(
                  (report) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: Text(report.childName),
                      subtitle: Text(
                        context.l10n.bodyCheckSummary(
                          localizedBodyPart(context.l10n, report.bodyPart),
                          localizedPainType(context.l10n, report.painType),
                          _formatDate(report.timestamp),
                        ),
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
                child: Text(context.l10n.viewAllBodyChecks(unchecked.length)),
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
              title: Text(
                context.l10n.noScheduleEntriesForDay(_prettyDay(today)),
              ),
              subtitle: Text(context.l10n.nothingScheduledTodayYet),
            ),
          );
        }

        return Column(
          children:
              entries.map((entry) {
                final start = entry['start'] ?? '';
                final end = entry['end'] ?? '';
                final description = entry['description'] ?? '';

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(description),
                    subtitle: Text(context.l10n.scheduleTimeRange(start, end)),
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

        final importantIncidents =
            incidents
                .where(
                  (incident) =>
                      _isToday(incident.timestamp) ||
                      incident.severity == 'High' ||
                      incident.severity == 'Medium',
                )
                .take(4)
                .toList();

        if (importantIncidents.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(context.l10n.noImportantIncidents),
              subtitle: Text(context.l10n.noImportantIncidentsIntro),
            ),
          );
        }

        return Column(
          children:
              importantIncidents.map((incident) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _severityColor(incident.severity),
                      child: const Icon(Icons.event_note, color: Colors.white),
                    ),
                    title: Text(incident.childName),
                    subtitle: Text(
                      context.l10n.incidentSummary(
                        _severityLabel(incident.severity),
                        _formatDate(incident.timestamp),
                        incident.description,
                      ),
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
      appBar: AppBar(title: Text(context.l10n.todayOverview)),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _childrenStream(),
        builder: (context, snapshot) {
          final children = snapshot.data ?? [];

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  context.l10n.todayOverview,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.todayOverviewForStaff(widget.staffProfile.name),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _sectionTitle(context.l10n.quickActions),
                _buildQuickActions(),
                _buildChildrenSummary(children),
                _sectionTitle(context.l10n.zonesSnapshot),
                _buildZoneSnapshot(children),
                _sectionTitle(context.l10n.bodyCheckAttention),
                _buildBodyCheckSummary(),
                _sectionTitle(context.l10n.todaysSchedule),
                _buildTodaySchedule(),
                _sectionTitle(context.l10n.recentImportantIncidents),
                _buildRecentIncidents(),
              ],
            ),
          );
        },
      ),
    );
  }
}
