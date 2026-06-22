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

  String _t(String en, String ga) =>
      Localizations.localeOf(context).languageCode == 'ga' ? ga : en;

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

  Future<void> _showRewardDialog({PointReward? reward}) async {
    final nameController = TextEditingController(text: reward?.name ?? '');

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
                reward == null
                    ? _t('Create Reward', 'Cruthaigh Luaíocht')
                    : _t('Edit Reward', 'Cuir Luaíocht in Eagar'),
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
                        decoration: InputDecoration(
                          labelText: _t('Reward name', 'Ainm na luaíochta'),
                          hintText: _t(
                            'Example: Extra computer time',
                            'Sampla: Am breise ar an ríomhaire',
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        enabled: !isSaving,
                        maxLength: 120,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: _t('Description', 'Cur síos'),
                          hintText: _t(
                            'Add a short explanation of the reward.',
                            'Cuir míniú gearr ar an luaíocht leis.',
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: costController,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _t('Points needed', 'Pointí de dhíth'),
                          prefixIcon: const Icon(Icons.star_rounded),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _t('Choose an icon', 'Roghnaigh deilbhín'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children:
                            rewardIcons.entries.map((entry) {
                              final selected = selectedIcon == entry.key;

                              return ChoiceChip(
                                selected: selected,
                                avatar: Icon(entry.value, size: 21),
                                label: Text(_iconLabel(entry.key)),
                                onSelected:
                                    isSaving
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
                  onPressed:
                      isSaving
                          ? null
                          : () {
                            Navigator.pop(dialogContext);
                          },
                  child: Text(_t('Cancel', 'Cealaigh')),
                ),
                FilledButton.icon(
                  onPressed:
                      isSaving
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
                                _t(
                                  'Please enter a reward name.',
                                  'Cuir ainm luaíochta isteach.',
                                ),
                              );
                              return;
                            }

                            if (cost == null || cost <= 0) {
                              _showDialogMessage(
                                dialogContext,
                                _t(
                                  'Please enter a valid points cost.',
                                  'Cuir costas bailí pointí isteach.',
                                ),
                              );
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              if (reward == null) {
                                await _firestoreService.addCurrentPointReward(
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
                                _t(
                                  'Could not save the reward: $e',
                                  'Níorbh fhéidir an luaíocht a shábháil: $e',
                                ),
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
                          : const Icon(Icons.save_rounded),
                  label: Text(
                    isSaving
                        ? _t('Saving...', 'Á shábháil...')
                        : _t('Save Reward', 'Sábháil Luaíocht'),
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
    await Future<void>.delayed(const Duration(milliseconds: 350));

    nameController.dispose();
    descriptionController.dispose();
    costController.dispose();
  }

  void _showDialogMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeRewardStatus(PointReward reward) async {
    if (reward.active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              _t('Archive Reward?', 'Cuir an Luaíocht sa Chartlann?'),
            ),
            content: Text(
              _t(
                '"${reward.name}" will no longer appear to children. Its previous history will be preserved.',
                'Ní bheidh "${reward.name}" le feiceáil ag páistí a thuilleadh. Coinneofar an stair roimhe seo.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(_t('Cancel', 'Cealaigh')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(_t('Archive', 'Cuir sa Chartlann')),
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
          content: Text(
            _t(
              'Could not update reward: $e',
              'Níorbh fhéidir an luaíocht a nuashonrú: $e',
            ),
          ),
        ),
      );
    }
  }

  String _iconLabel(String iconName) {
    switch (iconName) {
      case 'game':
        return _t('Game', 'Cluiche');
      case 'music':
        return _t('Music', 'Ceol');
      case 'art':
        return _t('Art', 'Ealaín');
      case 'outdoors':
        return _t('Outdoors', 'Lasmuigh');
      case 'choice':
        return _t('Choice', 'Rogha');
      case 'break':
        return _t('Break', 'Sos');
      case 'star':
        return _t('Star', 'Réalta');
      case 'gift':
      default:
        return _t('Gift', 'Bronntanas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Reward Manager', 'Bainisteoir Luaíochtaí')),
        actions: [
          IconButton(
            tooltip: _t('Create reward', 'Cruthaigh luaíocht'),
            onPressed: _showRewardDialog,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRewardDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(_t('Create Reward', 'Cruthaigh Luaíocht')),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PointReward>>(
          stream: _firestoreService.getCurrentPointRewards(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  _t(
                    'Could not load classroom rewards.',
                    'Níorbh fhéidir luaíochtaí an tseomra ranga a lódáil.',
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final rewards = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 620
                        ? 2
                        : 1;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
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
                              physics: const NeverScrollableScrollPhysics(),
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
                    _t('Classroom Rewards', 'Luaíochtaí an tSeomra Ranga'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _t(
                      'Create rewards children can work toward with their points.',
                      'Cruthaigh luaíochtaí ar féidir le páistí oibriú ina dtreo lena gcuid pointí.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, PointReward reward) {
    final icon = rewardIcons[reward.iconName] ?? Icons.card_giftcard_rounded;

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
                      color: Colors.deepPurple.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: Colors.deepPurple, size: 31),
                  ),
                  const Spacer(),
                  Chip(
                    avatar: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    label: Text(
                      _t('${reward.cost} points', '${reward.cost} pointe'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                reward.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  reward.description.isEmpty
                      ? _t(
                        'No description provided.',
                        'Níor cuireadh cur síos ar fáil.',
                      )
                      : reward.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!reward.active)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _t('Archived', 'Sa Chartlann'),
                    style: const TextStyle(
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
                      label: Text(_t('Edit', 'Cuir in Eagar')),
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
                        reward.active
                            ? _t('Archive', 'Cuir sa Chartlann')
                            : _t('Restore', 'Athchóirigh'),
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
              _t(
                'No rewards created yet',
                'Níor cruthaíodh aon luaíochtaí fós',
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 7),
            Text(
              _t(
                'Create the first classroom reward for children to work toward.',
                'Cruthaigh an chéad luaíocht seomra ranga do pháistí.',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _showRewardDialog,
              icon: const Icon(Icons.add_rounded),
              label: Text(_t('Create Reward', 'Cruthaigh Luaíocht')),
            ),
          ],
        ),
      ),
    );
  }
}
