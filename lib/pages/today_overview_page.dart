import 'package:flutter/material.dart';
import '../l10n/body_check_localizations.dart';
import '../l10n/l10n.dart';
import '../l10n/zone_localizations.dart';
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
    return switch (DateTime.now().weekday) {
      DateTime.monday => 'monday',
      DateTime.tuesday => 'tuesday',
      DateTime.wednesday => 'wednesday',
      DateTime.thursday => 'thursday',
      DateTime.friday => 'friday',
      DateTime.saturday => 'saturday',
      _ => 'sunday',
    };
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

  int? _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());

    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  List<Map<String, dynamic>> _sortedEntries(
    List<Map<String, dynamic>> entries,
  ) {
    final sorted = [...entries];

    sorted.sort((a, b) {
      final aStart = _timeToMinutes((a['start'] ?? '').toString()) ?? 99999;
      final bStart = _timeToMinutes((b['start'] ?? '').toString()) ?? 99999;
      return aStart.compareTo(bStart);
    });

    return sorted;
  }

  Color _zoneColor(String? zone) {
    return switch (zone?.toLowerCase()) {
      'blue' => const Color(0xFF42A5F5),
      'green' => const Color(0xFF66BB6A),
      'yellow' => const Color(0xFFFFCA28),
      'red' => const Color(0xFFEF5350),
      _ => const Color(0xFFB0BEC5),
    };
  }

  Color _severityColor(String severity) {
    return switch (severity) {
      'High' => const Color(0xFFE53935),
      'Medium' => const Color(0xFFFF9800),
      _ => const Color(0xFF43A047),
    };
  }

  String _severityLabel(String severity) {
    return switch (severity) {
      'High' => context.l10n.severityHigh,
      'Medium' => context.l10n.severityMedium,
      _ => context.l10n.severityLow,
    };
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildHero(List<ChildProfile> children) {
    final zonesSelected =
        children
            .where((child) => child.zone != null && child.zone!.isNotEmpty)
            .length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8E7CFF), Color(0xFFFFB199)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _prettyDay(_todayKey()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.todayOverview,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.todayOverviewForStaff(widget.staffProfile.name),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroMetric(
                icon: Icons.groups_rounded,
                value: children.length.toString(),
                label: context.l10n.children,
              ),
              _heroMetric(
                icon: Icons.palette_rounded,
                value: '$zonesSelected/${children.length}',
                label: context.l10n.zonesCheckedIn,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 9),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.sizeOf(context).width >= 760 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: MediaQuery.sizeOf(context).width >= 760 ? 2.7 : 2.25,
      children: [
        _quickActionCard(
          icon: Icons.health_and_safety_rounded,
          label: context.l10n.viewBodyCheckReports,
          color: const Color(0xFFE53935),
          onTap: () {
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
        _quickActionCard(
          icon: Icons.event_note_rounded,
          label: context.l10n.openIncidentLog,
          color: const Color(0xFFFF9800),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => IncidentLogPage(staffProfile: widget.staffProfile),
              ),
            );
          },
        ),
        _quickActionCard(
          icon: Icons.schedule_rounded,
          label: context.l10n.openSchedule,
          color: const Color(0xFF5E6AD2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StaffSchedulePage()),
            );
          },
        ),
        _quickActionCard(
          icon: Icons.palette_rounded,
          label: context.l10n.openZonesOverview,
          color: const Color(0xFF00A884),
          onTap: () {
            Navigator.pushNamed(context, '/zone-overview');
          },
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    height: 1.12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5E6AD2), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF24213D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _surface({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E3FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildChildrenSummary(List<ChildProfile> children) {
    final childrenWithZones =
        children
            .where((child) => child.zone != null && child.zone!.isNotEmpty)
            .length;

    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFF5E6AD2),
            value: children.length.toString(),
            title: context.l10n.children,
            subtitle: context.l10n.totalChildProfiles,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFF00A884),
            value: '$childrenWithZones/${children.length}',
            title: context.l10n.zonesCheckedIn,
            subtitle: context.l10n.childrenWithSelectedZone,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
  }) {
    return _surface(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF24213D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSnapshot(List<ChildProfile> children) {
    if (children.isEmpty) {
      return _emptyCard(
        icon: Icons.child_care_rounded,
        title: context.l10n.noChildProfilesYet,
        subtitle: context.l10n.totalChildProfiles,
      );
    }

    return _surface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            children.map((child) {
              final zone =
                  child.zone == null || child.zone!.isEmpty
                      ? context.l10n.noZone
                      : localizedZoneName(context.l10n, child.zone!);
              final zoneColor = _zoneColor(child.zone);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: zoneColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: zoneColor.withValues(alpha: 0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 7, backgroundColor: zoneColor),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.childZoneSummary(child.name, zone),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBodyCheckSummary() {
    return StreamBuilder<List<BodyCheckReport>>(
      stream: _firestoreService.getCurrentBodyCheckReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final unchecked = reports.where((report) => !report.checked).toList();

        if (unchecked.isEmpty) {
          return _emptyCard(
            icon: Icons.check_circle_rounded,
            title: context.l10n.noUncheckedBodyChecks,
            subtitle: context.l10n.nothingNeedsReview,
            color: const Color(0xFF43A047),
          );
        }

        return Column(
          children: [
            _attentionSummary(
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFFE53935),
              value: unchecked.length.toString(),
              title: context.l10n.bodyCheckReports,
              subtitle: context.l10n.uncheckedBodyChecksIntro,
            ),
            const SizedBox(height: 10),
            ...unchecked.take(3).map((report) {
              return _detailCard(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFE53935),
                title: report.childName,
                subtitle: context.l10n.bodyCheckSummary(
                  localizedBodyPart(context.l10n, report.bodyPart),
                  localizedPainType(context.l10n, report.painType),
                  _formatDate(report.timestamp),
                ),
              );
            }),
            if (unchecked.length > 3)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
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
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(context.l10n.viewAllBodyChecks(unchecked.length)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _attentionSummary({
    required IconData icon,
    required Color color,
    required String value,
    required String title,
    required String subtitle,
  }) {
    return _surface(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    final today = _todayKey();

    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _firestoreService.getCurrentSchedule(),
      builder: (context, snapshot) {
        final schedule = snapshot.data ?? {};
        final entries = _sortedEntries(schedule[today] ?? []);

        if (entries.isEmpty) {
          return _emptyCard(
            icon: Icons.schedule_rounded,
            title: context.l10n.noScheduleEntriesForDay(_prettyDay(today)),
            subtitle: context.l10n.nothingScheduledTodayYet,
            color: const Color(0xFF5E6AD2),
          );
        }

        final now = DateTime.now();
        final nowMinutes = now.hour * 60 + now.minute;

        return _surface(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children:
                entries.map((entry) {
                  final start = (entry['start'] ?? '').toString();
                  final end = (entry['end'] ?? '').toString();
                  final description = (entry['description'] ?? '').toString();
                  final startMinutes = _timeToMinutes(start);
                  final endMinutes = _timeToMinutes(end);
                  final isCurrent =
                      startMinutes != null &&
                      endMinutes != null &&
                      nowMinutes >= startMinutes &&
                      nowMinutes <= endMinutes;
                  final isUpcoming =
                      startMinutes != null && nowMinutes < startMinutes;
                  final color =
                      isCurrent
                          ? const Color(0xFF00A884)
                          : isUpcoming
                          ? const Color(0xFF5E6AD2)
                          : const Color(0xFF9E9E9E);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isCurrent ? 0.13 : 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.14)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description.isEmpty
                                    ? context.l10n.todaysSchedule
                                    : description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.scheduleTimeRange(start, end),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.schedule_rounded, color: color),
                      ],
                    ),
                  );
                }).toList(),
          ),
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
          return _emptyCard(
            icon: Icons.check_circle_rounded,
            title: context.l10n.noImportantIncidents,
            subtitle: context.l10n.noImportantIncidentsIntro,
            color: const Color(0xFF43A047),
          );
        }

        return Column(
          children:
              importantIncidents.map((incident) {
                final color = _severityColor(incident.severity);

                return _detailCard(
                  icon: Icons.event_note_rounded,
                  color: color,
                  title: incident.childName,
                  subtitle: context.l10n.incidentSummary(
                    _severityLabel(incident.severity),
                    _formatDate(incident.timestamp),
                    incident.description,
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _detailCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _surface(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = const Color(0xFF5E6AD2),
  }) {
    return _surface(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text(context.l10n.todayOverview),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _childrenStream(),
        builder: (context, snapshot) {
          final children = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _buildHero(children),
                _sectionTitle(context.l10n.quickActions, Icons.bolt_rounded),
                _buildQuickActions(),
                const SizedBox(height: 14),
                _buildChildrenSummary(children),
                _sectionTitle(
                  context.l10n.zonesSnapshot,
                  Icons.palette_rounded,
                ),
                _buildZoneSnapshot(children),
                _sectionTitle(
                  context.l10n.bodyCheckAttention,
                  Icons.health_and_safety_rounded,
                ),
                _buildBodyCheckSummary(),
                _sectionTitle(
                  context.l10n.todaysSchedule,
                  Icons.schedule_rounded,
                ),
                _buildTodaySchedule(),
                _sectionTitle(
                  context.l10n.recentImportantIncidents,
                  Icons.event_note_rounded,
                ),
                _buildRecentIncidents(),
              ],
            ),
          );
        },
      ),
    );
  }
}
