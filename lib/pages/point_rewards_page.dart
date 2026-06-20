import 'package:flutter/material.dart';
import '../models/point_reward.dart';
import '../services/firestore_service.dart';

class PointRewardsPage extends StatefulWidget {
  const PointRewardsPage({super.key});

  @override
  State<PointRewardsPage> createState() => _PointRewardsPageState();
}

class _PointRewardsPageState extends State<PointRewardsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  static const Map<String, IconData> rewardIcons = {
    'gift': Icons.card_giftcard_rounded,
    'game': Icons.sports_esports_rounded,
    'music': Icons.music_note_rounded,
    'art': Icons.palette_rounded,
    'outdoors': Icons.park_rounded,
    'choice': Icons.touch_app_rounded,
    'break': Icons.free_breakfast_rounded,
    'star': Icons.star_rounded,
  };

  Future<void> _showRewardDialog({
    PointReward? reward,
  }) async {
    final nameController = TextEditingController(
      text: reward?.name ?? '',
    );

    final descriptionController = TextEditingController(
      text: reward?.description ?? '',
    );

    final costController = TextEditingController(
      text: reward?.cost.toString() ?? '',
    );

    String selectedIcon = reward?.iconName ?? 'gift';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                reward == null ? 'Create Reward' : 'Edit Reward',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        enabled: !isSaving,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Reward name',
                          hintText: 'Example: Extra computer time',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        enabled: !isSaving,
                        maxLength: 120,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Add a short explanation of the reward.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: costController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Points needed',
                          prefixIcon: Icon(Icons.star_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Choose an icon',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: rewardIcons.entries.map((entry) {
                          final selected =
                              selectedIcon == entry.key;

                          return ChoiceChip(
                            selected: selected,
                            avatar: Icon(
                              entry.value,
                              size: 21,
                            ),
                            label: Text(
                              _iconLabel(entry.key),
                            ),
                            onSelected: isSaving
                                ? null
                                : (_) {
                                    setDialogState(() {
                                      selectedIcon = entry.key;
                                    });
                                  },
                          );
                        }).toList(),
                      ),
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
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final description =
                              descriptionController.text.trim();
                          final cost = int.tryParse(
                            costController.text.trim(),
                          );

                          if (name.isEmpty) {
                            _showDialogMessage(
                              dialogContext,
                              'Please enter a reward name.',
                            );
                            return;
                          }

                          if (cost == null || cost <= 0) {
                            _showDialogMessage(
                              dialogContext,
                              'Please enter a valid points cost.',
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            if (reward == null) {
                              await _firestoreService
                                  .addCurrentPointReward(
                                name: name,
                                description: description,
                                cost: cost,
                                iconName: selectedIcon,
                              );
                            } else {
                              await _firestoreService
                                  .updateCurrentPointReward(
                                reward.copyWith(
                                  name: name,
                                  description: description,
                                  cost: cost,
                                  iconName: selectedIcon,
                                ),
                              );
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            _showDialogMessage(
                              dialogContext,
                              'Could not save the reward: $e',
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
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save Reward',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Allow the dialog's closing animation to finish before disposing
    // controllers still attached to its text fields.
    await Future<void>.delayed(
      const Duration(milliseconds: 350),
    );

    nameController.dispose();
    descriptionController.dispose();
    costController.dispose();
  }

  void _showDialogMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _changeRewardStatus(
    PointReward reward,
  ) async {
    if (reward.active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Archive Reward?'),
            content: Text(
              '"${reward.name}" will no longer appear to children. '
              'Its previous history will be preserved.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Archive'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;
    }

    try {
      await _firestoreService.setCurrentPointRewardActive(
        rewardId: reward.id,
        active: !reward.active,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update reward: $e'),
        ),
      );
    }
  }

  String _iconLabel(String iconName) {
    switch (iconName) {
      case 'game':
        return 'Game';
      case 'music':
        return 'Music';
      case 'art':
        return 'Art';
      case 'outdoors':
        return 'Outdoors';
      case 'choice':
        return 'Choice';
      case 'break':
        return 'Break';
      case 'star':
        return 'Star';
      case 'gift':
      default:
        return 'Gift';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Manager'),
        actions: [
          IconButton(
            tooltip: 'Create reward',
            onPressed: _showRewardDialog,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRewardDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Reward'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PointReward>>(
          stream: _firestoreService.getCurrentPointRewards(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load classroom rewards.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final rewards = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 620
                        ? 2
                        : 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    100,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 20),
                          if (rewards.isEmpty)
                            _buildEmptyState(context)
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: rewards.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 300,
                              ),
                              itemBuilder: (context, index) {
                                return _buildRewardCard(
                                  context,
                                  rewards[index],
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

  Widget _buildHeader(BuildContext context) {
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
                color: Colors.deepPurple.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.redeem_rounded,
                size: 36,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classroom Rewards',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create rewards children can work toward with their points.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    PointReward reward,
  ) {
    final icon = rewardIcons[reward.iconName] ??
        Icons.card_giftcard_rounded;

    return Opacity(
      opacity: reward.active ? 1 : 0.58,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          Colors.deepPurple.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.deepPurple,
                      size: 31,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    avatar: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    label: Text(
                      '${reward.cost} points',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                reward.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  reward.description.isEmpty
                      ? 'No description provided.'
                      : reward.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!reward.active)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRewardDialog(reward: reward);
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _changeRewardStatus(reward);
                      },
                      icon: Icon(
                        reward.active
                            ? Icons.archive_rounded
                            : Icons.unarchive_rounded,
                      ),
                      label: Text(
                        reward.active ? 'Archive' : 'Restore',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              size: 64,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 14),
            Text(
              'No rewards created yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Create the first classroom reward for children to work toward.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _showRewardDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Reward'),
            ),
          ],
        ),
      ),
    );
  }
}