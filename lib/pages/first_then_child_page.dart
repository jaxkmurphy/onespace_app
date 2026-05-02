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

  IconData _iconForKey(String key) {
    switch (key) {
      case 'quiz':
        return Icons.quiz;
      case 'book':
      case 'homework':
        return Icons.book;
      case 'clean':
      case 'clean_up':
        return Icons.cleaning_services;
      case 'task':
      case 'finish_work':
        return Icons.task_alt;
      case 'music':
      case 'calming_sounds':
        return Icons.music_note;
      case 'toys':
      case 'playtime':
        return Icons.toys;
      case 'outside':
      case 'outside_time':
        return Icons.park;
      case 'break':
        return Icons.free_breakfast;
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
          if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

  if (snapshot.hasError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong loading First–Then.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

    final firstThen = snapshot.data;

    if (firstThen == null || firstThen.isEmpty) {
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

      final isActive = firstThen['isActive'] == true;

      final rawActivity = firstThen['activity'];
      final activity = rawActivity is Map
        ? Map<String, dynamic>.from(rawActivity)
        : null;

      final rawRewards = firstThen['rewards'];
      final rewards = rawRewards is List
        ? rawRewards
          .whereType<Map>()
          .map((reward) => Map<String, dynamic>.from(reward))
          .toList()
        : <Map<String, dynamic>>[];

      final selectedRewardId = firstThen['selectedRewardId'] as String?;

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

          final activityLabel = activity['label'] ?? '';
          final activityIcon = activity['iconName'] ?? 'task';

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
                        Icon(_iconForKey(activityIcon), size: 48),
                        const SizedBox(height: 10),
                        Text(
                          activityLabel,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
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
                    final rewardId = reward['id'] as String? ?? '';
                    final rewardLabel = reward['label'] ?? '';
                    final rewardIcon = reward['iconName'] ?? 'task';

                    final isSelected = rewardId == selectedRewardId;
                    final locked = selectedRewardId != null;

                    return SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : _iconForKey(rewardIcon),
                        ),
                        label: Text(
                          rewardLabel,
                          textAlign: TextAlign.center,
                        ),
                        onPressed: locked
                            ? null
                            : () async {
                                await firestoreService.selectFirstThenReward(
                                  teacherUid: child.teacherUid,
                                  childId: child.id,
                                  rewardId: rewardId,
                                );
                              },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                if (selectedRewardId != null)
                  Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 56,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${loc.getString('then')}: ${rewards.firstWhere(
                          (reward) => reward['id'] == selectedRewardId,
                          orElse: () => {'label': ''},
                        )['label']}',
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