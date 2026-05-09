import 'dart:async';
import 'package:flutter/material.dart';
import '../locale_notifier.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';
import '../utils/hex_colour.dart';
import 'background_color_picker_page.dart';
import 'calming_sounds_page.dart';
import 'child_word_learning_page.dart';

class ChildProfileDashboard extends StatefulWidget {
  final ChildProfile profile;
  final FirestoreService firestoreService;
  final LocaleNotifier localeNotifier;

  const ChildProfileDashboard({
    super.key,
    required this.profile,
    required this.firestoreService,
    required this.localeNotifier,
  });

  @override
  State<ChildProfileDashboard> createState() => _ChildProfileDashboardState();
}

class _ChildProfileDashboardState extends State<ChildProfileDashboard> {
  late ChildProfile profile;
  Color backgroundColor = Colors.white;
  StreamSubscription<ChildProfile>? _profileSubscription;

  @override
  void initState() {
    super.initState();

    profile = widget.profile;
    backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');

    _profileSubscription = widget.firestoreService
        .getChildProfileStream(profile.teacherUid, profile.id)
        .listen((updatedProfile) {
      if (!mounted) return;

      setState(() {
        profile = updatedProfile;
        backgroundColor = HexColor(profile.backgroundColorHex ?? '#FFFFFF');
      });
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: widget.localeNotifier,
      builder: (context, locale, _) {
        final loc = SimpleLocalizations(locale);

        return Scaffold(
          backgroundColor: backgroundColor,
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
            title: Text('${profile.name}\'s Dashboard'),
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
                        Text(
                          '${loc.getString("welcome")}, ${profile.name}!',
                          style: const TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
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
                                'teacherUid': profile.teacherUid,
                                'child': profile,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.color_lens),
                          label: Text(loc.getString("zones_regulation")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/zone-select',
                              arguments: {
                                'teacherUid': profile.teacherUid,
                                'child': profile,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.star),
                          label: Text(loc.getString("my_points")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/child-points',
                              arguments: profile,
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text(loc.getString("my_schedule")),
                          onPressed: () {
                            Navigator.pushNamed(context, '/childSchedule');
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.music_note),
                          label: Text(loc.getString("calming_sounds")),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CalmingSoundsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.timer),
                          label: Text(loc.getString("visual_timer")),
                          onPressed: () {
                            Navigator.pushNamed(context, '/visual-timer');
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.quiz),
                          label: Text(loc.getString("take_quiz")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/student-quiz-list',
                              arguments: {
                                'firestoreService': widget.firestoreService,
                                'child': profile,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Word Practice'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChildWordLearningPage(
                                  firestoreService: widget.firestoreService,
                                  child: widget.profile,
                                ),
                              ),
                            );
                          },
                        ),              
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.accessibility_new),
                          label: const Text('Body Check'),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/body-check',
                              arguments: {
                                'firestoreService': widget.firestoreService,
                                'child': profile,
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.view_agenda),
                          label: Text(loc.getString("first_then")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/first-then-child',
                              arguments: {
                                'firestoreService': widget.firestoreService,
                                'child': profile,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.record_voice_over),
                          label: Text(loc.getString("voice_lines")),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/voice-lines',
                              arguments: {
                                'firestoreService': widget.firestoreService,
                                'child': profile,
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.format_paint),
                          label: Text(loc.getString("change_background")),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BackgroundColorPickerPage(
                                  child: profile,
                                  firestoreService: widget.firestoreService,
                                ),
                              ),
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