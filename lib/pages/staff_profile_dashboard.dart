import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';
import '../widgets/staff_dashboard_feature_card.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';
import 'word_learning_page.dart';
import '../services/classroom_session_service.dart';

class StaffProfileDashboard extends StatefulWidget {
  final StaffProfile profile;
  final LocaleNotifier localeNotifier;
  final String? schoolId;
  final String? classroomId;
  final String? classroomName;

  const StaffProfileDashboard({
    super.key,
    required this.profile,
    required this.localeNotifier,
    this.schoolId,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<StaffProfileDashboard> createState() => _StaffProfileDashboardState();
}

class _StaffProfileDashboardState extends State<StaffProfileDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  Classroom? _classroom;
  bool _isLoadingClassroomFeatures = false;

  @override
  void initState() {
    super.initState();
    _loadClassroomFeatures();
  }

  Future<void> _loadClassroomFeatures() async {
    var schoolId = widget.schoolId;
    var classroomId = widget.classroomId;

    if ((schoolId == null || classroomId == null) &&
        _session.hasClassroomSession) {
      schoolId = _session.requireSchoolId;
      classroomId = _session.requireClassroomId;
    }

    if (schoolId == null || classroomId == null) return;

    setState(() {
      _isLoadingClassroomFeatures = true;
    });

    try {
      final classroom = await _firestoreService.getClassroom(
        schoolId: schoolId,
        classroomId: classroomId,
      );

      if (!mounted) return;

      setState(() {
        _classroom = classroom;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingClassroomFeatures = false;
        });
      }
    }
  }

  bool get _shouldWaitForClassroomFeatures {
    return (widget.schoolId != null && widget.classroomId != null) ||
        _session.hasClassroomSession;
  }

  bool _isFeatureEnabled(ClassroomFeature feature) {
    if (_classroom != null) {
      return _classroom!.isFeatureEnabled(feature);
    }

    return !_shouldWaitForClassroomFeatures;
  }

  void _navigateToPointsOverview() {
    Navigator.pushNamed(context, '/points-overview');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final l10n = context.l10n;
        final waitingForFeatures =
            _shouldWaitForClassroomFeatures && _classroom == null;

        final dailyTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.todayOverview))
            StaffDashboardFeatureCard(
              icon: Icons.dashboard,
              title: l10n.todayOverview,
              subtitle: l10n.todayOverviewSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/today-overview',
                  arguments: widget.profile,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.zones))
            StaffDashboardFeatureCard(
              icon: Icons.palette,
              title: l10n.zones_regulation,
              subtitle: l10n.staffZonesSubtitle,
              onTap: () {
                Navigator.pushNamed(context, '/zone-overview');
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.points))
            StaffDashboardFeatureCard(
              icon: Icons.star,
              title: l10n.points_overview,
              subtitle: l10n.staffPointsSubtitle,
              onTap: _navigateToPointsOverview,
            ),
          if (_isFeatureEnabled(ClassroomFeature.schedules))
            StaffDashboardFeatureCard(
              icon: Icons.schedule,
              title: l10n.view_schedule,
              subtitle: l10n.staffScheduleSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffSchedulePage()),
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.whenThen))
            StaffDashboardFeatureCard(
              icon: Icons.view_kanban,
              title: l10n.whenThenSetup,
              subtitle: l10n.staffWhenThenSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/when-then-setup',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.visualTimer))
            StaffDashboardFeatureCard(
              icon: Icons.timer,
              title: l10n.visualTimer,
              subtitle: l10n.staffTimerSubtitle,
              onTap: () {
                Navigator.pushNamed(context, '/visual-timer');
              },
            ),
        ];

        final communicationTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.bodyCheck))
            StaffDashboardFeatureCard(
              icon: Icons.health_and_safety,
              title: l10n.bodyCheckReports,
              subtitle: l10n.bodyCheckReportsSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/body-check-overview',
                  arguments: {
                    'firestoreService': _firestoreService,
                    'teacherUid': widget.profile.teacherUid,
                  },
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.circleTime))
            StaffDashboardFeatureCard(
              icon: Icons.transfer_within_a_station,
              title: l10n.circleTime,
              subtitle: l10n.staffCircleTimeSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/circle-time',
                  arguments: {'teacherUid': widget.profile.teacherUid},
                );
              },
            ),
        ];

        final learningTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.quizzes))
            StaffDashboardFeatureCard(
              icon: Icons.quiz,
              title: l10n.quizzes,
              subtitle: l10n.staffQuizzesSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/quiz-list',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.wordLearning))
            StaffDashboardFeatureCard(
              icon: Icons.menu_book,
              title: l10n.wordLearning,
              subtitle: l10n.staffWordLearningSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => WordLearningPage(
                          firestoreService: _firestoreService,
                          teacherUid: widget.profile.teacherUid,
                          staffId: widget.profile.id,
                          staffName: widget.profile.name,
                        ),
                  ),
                );
              },
            ),
        ];

        final adminTools = <Widget>[
          if (_isFeatureEnabled(ClassroomFeature.incidentLog))
            StaffDashboardFeatureCard(
              icon: Icons.event_note,
              title: l10n.incidentLog,
              subtitle: l10n.staffIncidentLogSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => IncidentLogPage(staffProfile: widget.profile),
                  ),
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.handover))
            StaffDashboardFeatureCard(
              icon: Icons.description,
              title: l10n.handoverHub,
              subtitle: l10n.staffHandoverSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/handover-hub',
                  arguments: widget.profile,
                );
              },
            ),
          if (_isFeatureEnabled(ClassroomFeature.iconReset))
            StaffDashboardFeatureCard(
              icon: Icons.lock_reset,
              title: l10n.iconReset,
              subtitle: l10n.iconResetSubtitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/icon-reset',
                  arguments: widget.profile.teacherUid,
                );
              },
            ),
        ];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profiles',
                  (route) => false,
                );
              },
            ),
            title: Text(l10n.staffHubTitle(widget.profile.name)),
          ),
          body: SafeArea(
            child:
                waitingForFeatures
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 32,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 820,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (_isLoadingClassroomFeatures) ...[
                                      const LinearProgressIndicator(),
                                      const SizedBox(height: 16),
                                    ],
                                    Text(
                                      l10n.staffFeatureHub,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.staffHubIntro,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    _HubSection(
                                      title: l10n.dailyTools,
                                      children: dailyTools,
                                    ),
                                    _HubSection(
                                      title: l10n.communication,
                                      children: communicationTools,
                                    ),
                                    _HubSection(
                                      title: l10n.learning,
                                      children: learningTools,
                                    ),
                                    _HubSection(
                                      title: l10n.staffAdmin,
                                      children: adminTools,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }
}

class _HubSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _HubSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...children.expand((child) => [child, const SizedBox(height: 12)]),
        ],
      ),
    );
  }
}
