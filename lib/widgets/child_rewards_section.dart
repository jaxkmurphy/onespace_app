import 'package:flutter/material.dart';
import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../models/point_reward.dart';
import '../services/firestore_service.dart';

class ChildRewardsSection extends StatelessWidget {
  final int currentPoints;

  const ChildRewardsSection({super.key, required this.currentPoints});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<PointReward>>(
      stream: firestoreService.getCurrentPointRewards(activeOnly: true),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final rewards = snapshot.data!;

        if (rewards.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.deepPurple,
                      size: 32,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        context.l10n.rewardsToWorkToward,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(context.l10n.rewardsChildIntro),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth =
                        constraints.maxWidth >= 800
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth >= 520
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          rewards.map((reward) {
                            return SizedBox(
                              width: cardWidth,
                              child: _buildRewardCard(context, reward),
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(BuildContext context, PointReward reward) {
    final affordable = currentPoints >= reward.cost;

    final progress =
        reward.cost <= 0 ? 0.0 : (currentPoints / reward.cost).clamp(0.0, 1.0);

    final pointsNeeded = reward.cost - currentPoints;

    final icon = appIconForKey(reward.iconName, fallbackKey: 'gift');

    final colour = affordable ? Colors.green : Colors.deepPurple;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colour.withValues(alpha: 0.30),
          width: affordable ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colour.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colour, size: 28),
              ),
              const Spacer(),
              Chip(
                avatar: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 19,
                ),
                label: Text(
                  reward.cost.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reward.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (reward.description.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              reward.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: colour.withValues(alpha: 0.13),
              valueColor: AlwaysStoppedAnimation<Color>(colour),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            affordable
                ? context.l10n.readyToChoose
                : context.l10n.pointsNeeded(pointsNeeded),
            textAlign: TextAlign.center,
            style: TextStyle(color: colour, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
