import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/point_history_entry.dart';
import '../services/firestore_service.dart';
import 'point_rewards_page.dart';

class PointsOverviewPage extends StatefulWidget {
  final String? teacherUid;

  const PointsOverviewPage({super.key, this.teacherUid});

  @override
  State<PointsOverviewPage> createState() => _PointsOverviewPageState();
}

class _PointsOverviewPageState extends State<PointsOverviewPage> {
  final FirestoreService firestore = FirestoreService();

  static const List<String> earnedReasons = [
    'Great effort',
    'Completed an activity',
    'Kindness',
    'Helping others',
    'Good listening',
    'Personal goal',
    'Other',
  ];

  static const List<String> removedReasons = [
    'Reward redeemed',
    'Correct previous entry',
    'Other',
  ];

  Future<void> _showPointDialog(ChildProfile child) async {
    final l10n = context.l10n;
    final noteController = TextEditingController();

    bool isAdding = true;
    bool isSaving = false;
    int selectedAmount = 1;
    String selectedReason = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final reasons = isAdding ? earnedReasons : removedReasons;

            final amounts = isAdding ? const [1, 2, 5, 10] : const [1, 2, 5];

            return AlertDialog(
              title: Text(l10n.updateChildPoints(child.name)),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCurrentBalance(child),
                      const SizedBox(height: 20),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment<bool>(
                            value: true,
                            icon: const Icon(Icons.add_circle_rounded),
                            label: Text(l10n.earnPoints),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: const Icon(Icons.remove_circle_rounded),
                            label: Text(l10n.removePoints),
                          ),
                        ],
                        selected: {isAdding},
                        onSelectionChanged:
                            isSaving
                                ? null
                                : (selection) {
                                  setDialogState(() {
                                    isAdding = selection.first;
                                    selectedAmount = 1;
                                    selectedReason = '';
                                  });
                                },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.howManyPoints,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children:
                            amounts.map((amount) {
                              return ChoiceChip(
                                selected: selectedAmount == amount,
                                label: Text(isAdding ? '+$amount' : '-$amount'),
                                onSelected:
                                    isSaving
                                        ? null
                                        : (_) {
                                          setDialogState(() {
                                            selectedAmount = amount;
                                          });
                                        },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.reason,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.reasonRequiredInfo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            reasons.map((reason) {
                              return ChoiceChip(
                                selected: selectedReason == reason,
                                label: Text(_reasonLabel(reason, l10n)),
                                onSelected:
                                    isSaving
                                        ? null
                                        : (_) {
                                          setDialogState(() {
                                            selectedReason = reason;
                                          });
                                        },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: noteController,
                        enabled: !isSaving,
                        maxLength: 120,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.optionalNote,
                          hintText: l10n.pointNoteHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (!isAdding) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(l10n.pointsCannotBelowZero)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving
                          ? null
                          : () {
                            Navigator.pop(dialogContext);
                          },
                  child: Text(l10n.cancel),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isAdding ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            if (selectedReason.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text(l10n.selectReason)),
                              );
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            final amount =
                                isAdding ? selectedAmount : -selectedAmount;

                            try {
                              final balance = await firestore
                                  .addCurrentPointEntry(
                                    childId: child.id,
                                    amount: amount,
                                    reason: selectedReason,
                                    note: noteController.text,
                                  );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              if (!mounted) return;

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.childPointsBalanceUpdated(
                                      child.name,
                                      balance,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (e) {
                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                isSaving = false;
                              });

                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text(_cleanPointError(e))),
                              );
                            }
                          },
                  icon:
                      isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(
                            isAdding ? Icons.add_rounded : Icons.remove_rounded,
                          ),
                  label: Text(
                    isSaving
                        ? l10n.saving
                        : isAdding
                        ? l10n.awardPoints
                        : l10n.removePoints,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    noteController.dispose();
  }

  String _cleanPointError(Object error) {
    final message = error.toString();

    if (message.contains('already has zero points')) {
      return context.l10n.childAlreadyZeroPoints;
    }

    return message
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Invalid argument(s): ', '');
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

  Widget _buildCurrentBalance(ChildProfile child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 38, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.currentBalance,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            child.points.toString(),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _showHistory(ChildProfile child) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.childPointsHistory(child.name),
                        style: Theme.of(sheetContext).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.close,
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<PointHistoryEntry>>(
                  stream: firestore.getCurrentPointHistory(child.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(context.l10n.pointsHistoryLoadError),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final entries = snapshot.data!;

                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 56,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.noPointsHistory,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildHistoryEntry(context, entries[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryEntry(BuildContext context, PointHistoryEntry entry) {
    final earned = entry.amount > 0;
    final colour = earned ? Colors.green : Colors.orange;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colour.withValues(alpha: 0.16),
          foregroundColor: colour,
          child: Icon(earned ? Icons.add_rounded : Icons.remove_rounded),
        ),
        title: Text(
          _reasonLabel(entry.reason, context.l10n),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.note.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(entry.note),
            ],
            const SizedBox(height: 5),
            Text(
              _formatDate(context, entry.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              earned ? '+${entry.amount}' : entry.amount.toString(),
              style: TextStyle(
                color: colour,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.balanceValue(entry.balanceAfter),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return 'Saving...';
    }

    final localDate = date.toLocal();

    final localizations = MaterialLocalizations.of(context);
    final dateText = localizations.formatShortDate(localDate);
    final timeText = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(localDate),
    );
    return '$dateText $timeText';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.points_overview),
        actions: [
          IconButton(
            tooltip: context.l10n.manageRewards,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PointRewardsPage()),
              );
            },
            icon: const Icon(Icons.redeem_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChildProfile>>(
          stream: firestore.getCurrentChildProfiles(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(context.l10n.childPointsLoadFailed));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final children = [...snapshot.data!]
              ..sort((first, second) => first.name.compareTo(second.name));

            if (children.isEmpty) {
              return _buildEmptyState();
            }

            final totalPoints = children.fold<int>(
              0,
              (total, child) => total + child.points,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = constraints.maxWidth >= 850 ? 2 : 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(children.length, totalPoints),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: children.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 230,
                                ),
                            itemBuilder: (context, index) {
                              return _buildChildCard(children[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int childCount, int totalPoints) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.stars_rounded,
                size: 36,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.classroomPoints,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(context.l10n.classroomPointsIntro),
                ],
              ),
            ),
            _buildHeaderStat(
              value: childCount.toString(),
              label: context.l10n.children,
            ),
            const SizedBox(width: 10),
            _buildHeaderStat(
              value: totalPoints.toString(),
              label: context.l10n.totalPoints,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({required String value, required String label}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.amber.withValues(alpha: 0.2),
                  foregroundColor: Colors.amber.shade800,
                  child: Text(
                    child.name.isEmpty ? '?' : child.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    child.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 30,
                    ),
                    Text(
                      child.points.toString(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showPointDialog(child),
              icon: const Icon(Icons.edit_rounded),
              label: Text(context.l10n.updatePoints),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showHistory(child),
              icon: const Icon(Icons.history_rounded),
              label: Text(context.l10n.viewHistory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_outline_rounded,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.noChildProfilesFound,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.createChildBeforePoints,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
