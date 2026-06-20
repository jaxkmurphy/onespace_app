import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/point_history_entry.dart';
import '../services/firestore_service.dart';
import 'point_rewards_page.dart';

class PointsOverviewPage extends StatefulWidget {
  final String? teacherUid;

  const PointsOverviewPage({
    super.key,
    this.teacherUid,
  });

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
            final reasons =
                isAdding ? earnedReasons : removedReasons;

            final amounts = isAdding
                ? const [1, 2, 5, 10]
                : const [1, 2, 5];

            return AlertDialog(
              title: Text('Update ${child.name}’s Points'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCurrentBalance(child),
                      const SizedBox(height: 20),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.add_circle_rounded),
                            label: Text('Earn Points'),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.remove_circle_rounded),
                            label: Text('Remove Points'),
                          ),
                        ],
                        selected: {isAdding},
                        onSelectionChanged: isSaving
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
                        'How many points?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: amounts.map((amount) {
                          return ChoiceChip(
                            selected: selectedAmount == amount,
                            label: Text(
                              isAdding ? '+$amount' : '-$amount',
                            ),
                            onSelected: isSaving
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
                        'Reason',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A reason is required for the points history.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: reasons.map((reason) {
                          return ChoiceChip(
                            selected: selectedReason == reason,
                            label: Text(reason),
                            onSelected: isSaving
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
                        decoration: const InputDecoration(
                          labelText: 'Optional note',
                          hintText:
                              'Add any useful detail about this entry.',
                          border: OutlineInputBorder(),
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
                              color:
                                  Colors.orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Points cannot fall below zero.',
                                ),
                              ),
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
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isAdding ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (selectedReason.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a reason.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          final amount = isAdding
                              ? selectedAmount
                              : -selectedAmount;

                          try {
                            final balance =
                                await firestore.addCurrentPointEntry(
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
                                  '${child.name} now has $balance points.',
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
                              SnackBar(
                                content: Text(
                                  _cleanPointError(e),
                                ),
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isAdding
                              ? Icons.add_rounded
                              : Icons.remove_rounded,
                        ),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : isAdding
                            ? 'Award Points'
                            : 'Remove Points',
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
      return 'This child already has zero points.';
    }

    return message
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Invalid argument(s): ', '');
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
          const Icon(
            Icons.star_rounded,
            size: 38,
            color: Colors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Current balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            child.points.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                    const Icon(
                      Icons.history_rounded,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${child.name}’s Points History',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
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
                  stream:
                      firestore.getCurrentPointHistory(child.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Could not load points history.',
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final entries = snapshot.data!;

                    if (entries.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No points history yet.',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildHistoryEntry(
                          context,
                          entries[index],
                        );
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

  Widget _buildHistoryEntry(
    BuildContext context,
    PointHistoryEntry entry,
  ) {
    final earned = entry.amount > 0;
    final colour = earned ? Colors.green : Colors.orange;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: colour.withValues(alpha: 0.16),
          foregroundColor: colour,
          child: Icon(
            earned
                ? Icons.add_rounded
                : Icons.remove_rounded,
          ),
        ),
        title: Text(
          entry.reason,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
              _formatDate(entry.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              earned
                  ? '+${entry.amount}'
                  : entry.amount.toString(),
              style: TextStyle(
                color: colour,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Balance: ${entry.balanceAfter}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Saving...';
    }

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year} at '
        '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points Overview'),
        actions: [
          IconButton(
            tooltip: 'Manage rewards',
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PointRewardsPage(),
                ),
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
              return const Center(
                child: Text('Could not load child points.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final children = [...snapshot.data!]
              ..sort(
                (first, second) =>
                    first.name.compareTo(second.name),
              );

            if (children.isEmpty) {
              return _buildEmptyState();
            }

            final totalPoints = children.fold<int>(
              0,
              (total, child) => total + child.points,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final columnCount =
                    constraints.maxWidth >= 850 ? 2 : 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(
                            children.length,
                            totalPoints,
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: children.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columnCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 230,
                            ),
                            itemBuilder: (context, index) {
                              return _buildChildCard(
                                children[index],
                              );
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

  Widget _buildHeader(
    int childCount,
    int totalPoints,
  ) {
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
                    'Classroom Points',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Recognise effort, progress and positive achievements.',
                  ),
                ],
              ),
            ),
            _buildHeaderStat(
              value: childCount.toString(),
              label: 'Children',
            ),
            const SizedBox(width: 10),
            _buildHeaderStat(
              value: totalPoints.toString(),
              label: 'Total points',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required String value,
    required String label,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 92,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
                  backgroundColor:
                      Colors.amber.withValues(alpha: 0.2),
                  foregroundColor: Colors.amber.shade800,
                  child: Text(
                    child.name.isEmpty
                        ? '?'
                        : child.name[0].toUpperCase(),
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
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _showPointDialog(child),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Update Points'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showHistory(child),
              icon: const Icon(Icons.history_rounded),
              label: const Text('View History'),
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
              'No child profiles found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a child profile before awarding points.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}