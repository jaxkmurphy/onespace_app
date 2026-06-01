import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/child_profile.dart';
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

  const StaffProfileDashboard({
    super.key,
    required this.profile,
    required this.localeNotifier,
  });

  @override
  State<StaffProfileDashboard> createState() => _StaffProfileDashboardState();
}

class _StaffProfileDashboardState extends State<StaffProfileDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToPointsOverview() async {
    try {
      final List<ChildProfile> children = await _firestoreService
          .getChildProfiles(widget.profile.teacherUid)
          .first;

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/points-overview',
        arguments: {
          'teacherUid': widget.profile.teacherUid,
          'children': children,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load children profiles: $e')),
      );
    }
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
            title: Text('${widget.profile.name} Dashboard'),
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
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StaffDashboardFeatureCard(
                              icon: Icons.palette,
                              title: loc.getString("zones_regulation"),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/zone-overview',
                                  arguments: {
                                    'teacherUid': widget.profile.teacherUid,
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.star,
                              title: loc.getString("points_overview"),
                              onTap: _navigateToPointsOverview,
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.schedule,
                              title: loc.getString("view_schedule"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StaffSchedulePage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.quiz,
                              title: loc.getString("create_quiz"),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/quiz-create',
                                  arguments: widget.profile,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.fact_check,
                              title: loc.getString("manage_quizzes"),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/quiz-list',
                                  arguments: widget.profile.teacherUid,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.view_kanban,
                              title: loc.getString("first_then_setup"),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/first-then-setup',
                                  arguments: widget.profile.teacherUid,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.lock_reset,
                              title: 'Icon Reset',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/icon-reset',
                                  arguments: widget.profile.teacherUid,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.transfer_within_a_station,
                              title: 'Circle Time',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/circle-time',
                                  arguments: {
                                    'teacherUid': widget.profile.teacherUid,
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.event_note,
                              title: 'Incident Log',
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
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.menu_book,
                              title: 'Word Learning',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WordLearningPage(
                                      firestoreService: _firestoreService,
                                      teacherUid: widget.profile.teacherUid,
                                      staffId: widget.profile.id,
                                      staffName: widget.profile.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.health_and_safety,
                              title: 'Body Check Reports',
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
                            const SizedBox(height: 14),

                            StaffDashboardFeatureCard(
                              icon: Icons.description,
                              title: 'Handover Hub',
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/handover-hub',
                                  arguments: widget.profile,
                                );
                              },
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