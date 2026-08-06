import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/point_history_entry.dart';
import '../services/firestore_service.dart';
import '../widgets/child_rewards_section.dart';

class ChildPointsPage extends StatelessWidget {
  final ChildProfile child;

  const ChildPointsPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.my_points)),
      body: SafeArea(
        child: StreamBuilder<ChildProfile>(
          stream: firestoreService.getCurrentChildProfileStream(child.id),
          initialData: child,
          builder: (context, childSnapshot) {
            if (childSnapshot.hasError) {
              return Center(child: Text(context.l10n.pointsLoadFailed));
            }

            final currentChild = childSnapshot.data ?? child;

            return StreamBuilder<List<PointHistoryEntry>>(
              stream: firestoreService.getCurrentPointHistory(child.id),
              builder: (context, historySnapshot) {
                if (historySnapshot.hasError) {
                  return Center(
                    child: Text(context.l10n.pointsHistoryLoadFailed),
                  );
                }

                final history =
                    historySnapshot.data ?? const <PointHistoryEntry>[];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 780;

                    return SingleChildScrollView(
                      key: const PageStorageKey<String>('child-points'),
                      padding: const EdgeInsets.all(18),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildWelcome(context, currentChild),
                              const SizedBox(height: 18),
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildPointsCard(
                                            context,
                                            currentChild.points,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildMilestoneCard(
                                            context,
                                            currentChild.points,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: _buildHistoryCard(
                                        context,
                                        history,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildPointsCard(context, currentChild.points),
                                const SizedBox(height: 16),
                                _buildMilestoneCard(
                                  context,
                                  currentChild.points,
                                ),
                                const SizedBox(height: 16),
                                _buildHistoryCard(context, history),
                              ],

                              const SizedBox(height: 18),
                              ChildRewardsSection(
                                currentPoints: currentChild.points,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, ChildProfile child) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 35,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.wellDoneChild(child.name),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.pointsCelebrateEffort,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, size: 78, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            points.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.pointLabel(points),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, int points) {
    final pointsIntoMilestone = points % 10;
    final nextMilestone = ((points ~/ 10) + 1) * 10;
    final completedMilestones = points ~/ 10;
    final progress = pointsIntoMilestone / 10;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.nextStarMilestone,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 18,
                backgroundColor: Colors.amber.withValues(alpha: 0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.milestoneProgress(
                pointsIntoMilestone,
                nextMilestone,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (completedMilestones > 0) ...[
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: List.generate(
                  completedMilestones.clamp(0, 20),
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.l10n.milestonesCompleted(completedMilestones),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    List<PointHistoryEntry> history,
  ) {
    final recentEntries = history.take(6).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.recentAchievements,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentEntries.isEmpty)
              _buildEmptyHistory(context)
            else
              ...recentEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHistoryEntry(context, entry),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryEntry(BuildContext context, PointHistoryEntry entry) {
    final earned = entry.amount > 0;
    final colour = earned ? Colors.green : Colors.deepPurple;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colour.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colour.withValues(alpha: 0.16),
            foregroundColor: colour,
            child: Icon(earned ? Icons.star_rounded : Icons.redeem_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reasonLabel(entry.reason, context.l10n),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    entry.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  _formatDate(context, entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            earned ? '+${entry.amount}' : entry.amount.toString(),
            style: TextStyle(
              color: colour,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_outline_rounded, size: 50, color: Colors.amber),
          const SizedBox(height: 10),
          Text(
            context.l10n.achievementsWillAppear,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _reasonLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'Great effort':
        return l10n.reasonGreatEffort;
      case 'Completed an activity':
        return l10n.reasonCompletedActivity;
      case 'Kindness':
        return l10n.reasonKindness;
      case 'Helping others':
        return l10n.reasonHelpingOthers;
      case 'Good listening':
        return l10n.reasonGoodListening;
      case 'Personal goal':
        return l10n.reasonPersonalGoal;
      case 'Reward redeemed':
        return l10n.reasonRewardRedeemed;
      case 'Correct previous entry':
        return l10n.reasonCorrectEntry;
      case 'Other':
        return l10n.reasonOther;
      default:
        return value;
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return context.l10n.justNow;
    }

    final localDate = date.toLocal();
    final today = DateTime.now();

    final isToday =
        localDate.year == today.year &&
        localDate.month == today.month &&
        localDate.day == today.day;

    if (isToday) {
      final time = MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay.fromDateTime(localDate));
      return context.l10n.todayAt(time);
    }

    return MaterialLocalizations.of(context).formatShortDate(localDate);
  }
}
