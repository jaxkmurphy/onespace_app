import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/child_profile.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';
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
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.palette),
                          label: Text(loc.getString("zones_regulation")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/zone-overview',
                              arguments: {
                                'teacherUid': widget.profile.teacherUid,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.star),
                          label: Text(loc.getString("points_overview")),
                          onPressed: _navigateToPointsOverview,
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(loc.getString("view_schedule")),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StaffSchedulePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.quiz),
                          label: Text(loc.getString("create_quiz")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/quiz-create',
                              arguments: widget.profile,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.quiz),
                          label: Text(loc.getString("manage_quizzes")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/quiz-list',
                              arguments: widget.profile.teacherUid,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.view_kanban),
                          label: Text(loc.getString("first_then_setup")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/first-then-setup',
                              arguments: widget.profile.teacherUid,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock_reset),
                          label: const Text('Icon Reset'),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/icon-reset',
                              arguments: widget.profile.teacherUid,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.transfer_within_a_station),
                          label: const Text('Circle Time'),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/circle-time',
                              arguments: {
                                'teacherUid': widget.profile.teacherUid,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.event_note),
                          label: const Text('Incident Log'),
                          onPressed: () {
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
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Word Learning'),
                          onPressed: () {
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
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.description),
                          label: const Text('Handover Hub'),
                          onPressed: () {
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
                );
              },
            ),
          ),
        );
      },
    );
  }
}