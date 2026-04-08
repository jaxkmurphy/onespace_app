import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';

class FirstThenChildPage extends StatelessWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const FirstThenChildPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  String _labelForKey(SimpleLocalizations loc, String key) {
    switch (key) {
      case 'quiz':
        return loc.getString('quiz');
      case 'homework':
        return loc.getString('homework');
      case 'clean_up':
        return loc.getString('clean_up');
      case 'finish_work':
        return loc.getString('finish_work');
      case 'calming_sounds':
        return loc.getString('calming_sounds');
      case 'playtime':
        return loc.getString('playtime');
      case 'outside_time':
        return loc.getString('outside_time');
      case 'break':
        return loc.getString('break');
      case 'music':
        return loc.getString('music');
      default:
        return key;
    }
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'quiz':
        return Icons.quiz;
      case 'homework':
        return Icons.book;
      case 'clean_up':
        return Icons.cleaning_services;
      case 'finish_work':
        return Icons.task_alt;
      case 'calming_sounds':
        return Icons.music_note;
      case 'playtime':
        return Icons.toys;
      case 'outside_time':
        return Icons.park;
      case 'break':
        return Icons.free_breakfast;
      case 'music':
        return Icons.library_music;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.getString('first_then')),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: firestoreService.getFirstThenStream(
          teacherUid: child.teacherUid,
          childId: child.id,
        ),
        builder: (context, snapshot) {
          final firstThen = snapshot.data;
          final isActive = firstThen?['isActive'] == true;
          final activity = firstThen?['activity'] as String?;
          final rewards = (firstThen?['rewards'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final selectedReward = firstThen?['selectedReward'] as String?;

          if (!isActive || activity == null || rewards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  loc.getString('no_active_first_then'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.getString('first'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(_iconForKey(activity), size: 48),
                        const SizedBox(height: 10),
                        Text(
                          _labelForKey(loc, activity),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  loc.getString('then_choose_reward'),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: rewards.map((reward) {
                    final isSelected = reward == selectedReward;
                    final locked = selectedReward != null;

                    return SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isSelected ? Icons.check_circle : _iconForKey(reward),
                        ),
                        label: Text(
                          _labelForKey(loc, reward),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: locked
                            ? null
                            : () async {
                                await firestoreService.selectFirstThenReward(
                                  teacherUid: child.teacherUid,
                                  childId: child.id,
                                  reward: reward,
                                );
                              },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                if (selectedReward != null)
                  Column(
                    children: [
                      Icon(Icons.check_circle, size: 56, color: Colors.green.shade600),
                      const SizedBox(height: 10),
                      Text(
                        '${loc.getString('then')}: ${_labelForKey(loc, selectedReward)}',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}