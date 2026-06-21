import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';
import '../widgets/staff_dashboard_feature_card.dart';
import 'incident_log_page.dart';
import 'staff_schedule_page.dart';
import 'word_learning_page.dart';

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

  void _navigateToPointsOverview() {
    Navigator.pushNamed(context, '/points-overview');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final loc = SimpleLocalizations(locale);

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
            title: Text('${widget.profile.name} Hub'),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Staff Feature Hub',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose a tool for today\'s classroom support.',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            _HubSection(
                              title: 'Daily Tools',
                              children: [
                                StaffDashboardFeatureCard(
                                  icon: Icons.dashboard,
                                  title: 'Today Overview',
                                  subtitle: 'See zones, reports, schedule and incidents at a glance.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/today-overview',
                                      arguments: widget.profile,
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.palette,
                                  title: loc.getString('zones_regulation'),
                                  subtitle: 'View children\'s current zones.',
                                  onTap: () {
                                    Navigator.pushNamed(context, '/zone-overview');
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.star,
                                  title: loc.getString('points_overview'),
                                  subtitle: 'View and update child points.',
                                  onTap: _navigateToPointsOverview,
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.schedule,
                                  title: loc.getString('view_schedule'),
                                  subtitle: 'Create and edit the daily schedule.',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StaffSchedulePage(),
                                      ),
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.view_kanban,
                                  title: loc.getString('when_then_setup'),
                                  subtitle:
                                      'Create When–Then activities and rewards.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/when-then-setup',
                                      arguments: widget.profile.teacherUid,
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.timer,
                                  title: 'Visual Timer',
                                  subtitle: 'Open the classroom timer.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/visual-timer',
                                    );
                                  },
                                ),
                              ],
                            ),

                            _HubSection(
                              title: 'Communication',
                              children: [
                                StaffDashboardFeatureCard(
                                  icon: Icons.health_and_safety,
                                  title: 'Body Check Reports',
                                  subtitle:
                                      'Review body check messages from children.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/body-check-overview',
                                      arguments: {
                                        'firestoreService': _firestoreService,
                                        'teacherUid':
                                            widget.profile.teacherUid,
                                      },
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.transfer_within_a_station,
                                  title: 'Circle Time',
                                  subtitle:
                                      'Move children between home and school.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/circle-time',
                                      arguments: {
                                        'teacherUid':
                                            widget.profile.teacherUid,
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),

                            _HubSection(
                              title: 'Learning',
                              children: [
                                StaffDashboardFeatureCard(
                                  icon: Icons.quiz,
                                  title: 'Quizzes',
                                  subtitle:
                                      'Create, preview and manage quizzes.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/quiz-list',
                                      arguments: widget.profile.teacherUid,
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.menu_book,
                                  title: 'Word Learning',
                                  subtitle:
                                      'Create word packs and view progress.',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WordLearningPage(
                                          firestoreService: _firestoreService,
                                          teacherUid:
                                              widget.profile.teacherUid,
                                          staffId: widget.profile.id,
                                          staffName: widget.profile.name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            _HubSection(
                              title: 'Staff / Admin',
                              children: [
                                StaffDashboardFeatureCard(
                                  icon: Icons.event_note,
                                  title: 'Incident Log',
                                  subtitle:
                                      'Record and review classroom incidents.',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IncidentLogPage(
                                          staffProfile: widget.profile,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.description,
                                  title: 'Handover Hub',
                                  subtitle:
                                      'View overview notes and staff documents.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/handover-hub',
                                      arguments: widget.profile,
                                    );
                                  },
                                ),
                                StaffDashboardFeatureCard(
                                  icon: Icons.lock_reset,
                                  title: 'Icon Reset',
                                  subtitle:
                                      'View or reset child profile unlock icons.',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/icon-reset',
                                      arguments: widget.profile.teacherUid,
                                    );
                                  },
                                ),
                              ],
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

  const _HubSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          ...children.expand(
            (child) => [
              child,
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
