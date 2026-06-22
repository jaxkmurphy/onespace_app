import 'package:flutter/material.dart';
import '../data/when_then_icons.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/when_then_option.dart';
import '../services/firestore_service.dart';

enum WhenThenTargetMode { single, multiple, all }

class WhenThenSetupPage extends StatefulWidget {
  final String teacherUid;

  const WhenThenSetupPage({super.key, required this.teacherUid});

  @override
  State<WhenThenSetupPage> createState() => _WhenThenSetupPageState();
}

class _WhenThenSetupPageState extends State<WhenThenSetupPage> {
  final FirestoreService _firestoreService = FirestoreService();

  WhenThenTargetMode _targetMode = WhenThenTargetMode.single;
  WhenThenOption? _selectedActivity;
  String? _singleChildId;

  final Set<String> _selectedChildIds = {};
  final Set<String> _selectedRewardIds = {};

  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _seedOptions();
  }

  Future<void> _seedOptions() async {
    try {
      await _firestoreService.seedDefaultCurrentWhenThenOptions();
    } catch (_) {
      // Existing options can still load if seeding is unavailable.
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<String>? _targetChildIds(List<ChildProfile> children) {
    final l10n = context.l10n;

    switch (_targetMode) {
      case WhenThenTargetMode.single:
        if (_singleChildId == null) {
          _showMessage(l10n.pleaseChooseChild);
          return null;
        }
        return [_singleChildId!];

      case WhenThenTargetMode.multiple:
        if (_selectedChildIds.isEmpty) {
          _showMessage(l10n.chooseAtLeastOneChild);
          return null;
        }
        return _selectedChildIds.toList();

      case WhenThenTargetMode.all:
        if (children.isEmpty) {
          _showMessage(l10n.noChildProfilesFound);
          return null;
        }
        return children.map((child) => child.id).toList();
    }
  }

  Future<void> _createBoard({
    required List<ChildProfile> children,
    required List<WhenThenOption> rewards,
    required AppLocalizations l10n,
  }) async {
    if (_selectedActivity == null) {
      _showMessage(l10n.chooseWhenActivityFirst);
      return;
    }

    if (_selectedRewardIds.isEmpty || _selectedRewardIds.length > 3) {
      _showMessage(l10n.chooseOneToThreeRewards);
      return;
    }

    final selectedRewards =
        rewards
            .where((reward) => _selectedRewardIds.contains(reward.id))
            .toList();

    if (selectedRewards.length != _selectedRewardIds.length) {
      _showMessage(l10n.selectedRewardUnavailable);
      return;
    }

    final childIds = _targetChildIds(children);
    if (childIds == null) return;

    setState(() {
      _isApplying = true;
    });

    try {
      await _firestoreService.setCurrentWhenThenForChildren(
        childIds: childIds,
        activity: _selectedActivity!,
        rewards: selectedRewards,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.whenThenBoardCreated),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _selectedActivity = null;
        _selectedRewardIds.clear();
        _singleChildId = null;
        _selectedChildIds.clear();
      });
    } catch (error) {
      _showMessage(l10n.whenThenCreateFailed(error.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  Future<void> _showOptionDialog({
    required String type,
    WhenThenOption? existingOption,
  }) async {
    final isEditing = existingOption != null;
    final l10n = context.l10n;

    final labelController = TextEditingController(
      text: existingOption?.label ?? '',
    );

    String selectedIcon = existingOption?.iconName ?? 'task';

    final result = await showDialog<WhenThenOption>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? type == 'activities'
                        ? l10n.editActivity
                        : l10n.editReward
                    : type == 'activities'
                    ? l10n.addActivity
                    : l10n.addReward,
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: labelController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.nameLabel,
                          hintText: l10n.shortClearNameHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.chooseIcon,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            whenThenIconStyles.map((style) {
                              final selected = style.key == selectedIcon;

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setDialogState(() {
                                    selectedIcon = style.key;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color:
                                        selected
                                            ? style.color
                                            : style.color.withValues(
                                              alpha: 0.12,
                                            ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          selected
                                              ? style.color
                                              : style.color.withValues(
                                                alpha: 0.35,
                                              ),
                                      width: selected ? 3 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    style.icon,
                                    color:
                                        selected ? Colors.white : style.color,
                                    size: 30,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final label = labelController.text.trim();

                    if (label.isEmpty) return;

                    Navigator.pop(
                      dialogContext,
                      WhenThenOption(
                        id: existingOption?.id ?? '',
                        label: label,
                        iconName: selectedIcon,
                      ),
                    );
                  },
                  child: Text(isEditing ? l10n.save : l10n.add),
                ),
              ],
            );
          },
        );
      },
    );

    labelController.dispose();

    if (result == null) return;

    try {
      if (isEditing) {
        await _firestoreService.updateCurrentWhenThenOption(
          type: type,
          option: result,
        );
      } else {
        await _firestoreService.addCurrentWhenThenOption(
          type: type,
          option: result,
        );
      }
    } catch (error) {
      _showMessage(l10n.optionSaveFailed(error.toString()));
    }
  }

  Future<void> _confirmDeleteOption({
    required String type,
    required WhenThenOption option,
  }) async {
    final l10n = context.l10n;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteOptionQuestion),
          content: Text(l10n.deleteOptionMessage(option.label)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _firestoreService.deleteCurrentWhenThenOption(
        type: type,
        optionId: option.id,
      );
    } catch (error) {
      _showMessage(l10n.optionDeleteFailed(error.toString()));
    }
  }

  Widget _buildWhoSection(List<ChildProfile> children) {
    return _StepCard(
      number: 1,
      title: context.l10n.whoLabel,
      subtitle: context.l10n.whoShouldSeeBoard,
      color: const Color(0xFF5C6BC0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<WhenThenTargetMode>(
            segments: [
              ButtonSegment(
                value: WhenThenTargetMode.single,
                icon: const Icon(Icons.person_rounded),
                label: Text(context.l10n.one),
              ),
              ButtonSegment(
                value: WhenThenTargetMode.multiple,
                icon: const Icon(Icons.people_alt_rounded),
                label: Text(context.l10n.some),
              ),
              ButtonSegment(
                value: WhenThenTargetMode.all,
                icon: const Icon(Icons.groups_rounded),
                label: Text(context.l10n.everyone),
              ),
            ],
            selected: {_targetMode},
            onSelectionChanged: (selection) {
              setState(() {
                _targetMode = selection.first;
                _singleChildId = null;
                _selectedChildIds.clear();
              });
            },
          ),
          const SizedBox(height: 18),
          if (_targetMode == WhenThenTargetMode.single)
            DropdownButtonFormField<String>(
              initialValue: _singleChildId,
              decoration: InputDecoration(
                labelText: context.l10n.selectChild,
                prefixIcon: const Icon(Icons.person_search_rounded),
                border: const OutlineInputBorder(),
              ),
              items:
                  children.map((child) {
                    return DropdownMenuItem(
                      value: child.id,
                      child: Text(child.name),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _singleChildId = value;
                });
              },
            ),
          if (_targetMode == WhenThenTargetMode.multiple)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  children.map((child) {
                    final selected = _selectedChildIds.contains(child.id);

                    return FilterChip(
                      selected: selected,
                      avatar: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.face_rounded,
                      ),
                      label: Text(child.name),
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedChildIds.add(child.id);
                          } else {
                            _selectedChildIds.remove(child.id);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          if (_targetMode == WhenThenTargetMode.all)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFF5C6BC0),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.boardSentToAllChildren(children.length),
                    ),
                  ),
                ],
              ),
            ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(context.l10n.noChildProfilesAvailable),
            ),
        ],
      ),
    );
  }

  Widget _buildWhenSection(List<WhenThenOption> activities) {
    return _StepCard(
      number: 2,
      title: context.l10n.whenLabel,
      subtitle: context.l10n.whatHappensFirst,
      color: const Color(0xFF42A5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activities.isEmpty) Text(context.l10n.noActivitiesManageOptions),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                activities.map((activity) {
                  final selected = _selectedActivity?.id == activity.id;

                  return _OptionChoiceCard(
                    label: activity.label,
                    iconName: activity.iconName,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedActivity = activity;
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThenSection(List<WhenThenOption> rewards) {
    return _StepCard(
      number: 3,
      title: context.l10n.thenLabel,
      subtitle: context.l10n.possibleRewardsInstruction,
      color: const Color(0xFFFFA726),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rewards.isEmpty) Text(context.l10n.noRewardsManageOptions),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                rewards.map((reward) {
                  final selected = _selectedRewardIds.contains(reward.id);
                  final canSelect = selected || _selectedRewardIds.length < 3;

                  return _OptionChoiceCard(
                    label: reward.label,
                    iconName: reward.iconName,
                    selected: selected,
                    enabled: canSelect,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedRewardIds.remove(reward.id);
                        } else if (_selectedRewardIds.length < 3) {
                          _selectedRewardIds.add(reward.id);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                _selectedRewardIds.isEmpty
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_rounded,
                color:
                    _selectedRewardIds.isEmpty
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.rewardsSelectedCount(_selectedRewardIds.length),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(List<WhenThenOption> rewards) {
    final selectedRewards =
        rewards
            .where((reward) => _selectedRewardIds.contains(reward.id))
            .toList();

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.visibility_rounded),
                const SizedBox(width: 8),
                Text(
                  context.l10n.boardPreview,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _PreviewPanel(
                    heading: context.l10n.whenLabel,
                    option: _selectedActivity,
                    emptyText: context.l10n.chooseActivity,
                    color: const Color(0xFF42A5F5),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded, size: 34),
                ),
                Expanded(
                  child: _PreviewPanel(
                    heading: context.l10n.thenLabel,
                    option:
                        selectedRewards.isEmpty ? null : selectedRewards.first,
                    emptyText:
                        selectedRewards.isEmpty
                            ? context.l10n.chooseRewards
                            : selectedRewards.length == 1
                            ? selectedRewards.first.label
                            : context.l10n.rewardChoicesCount(
                              selectedRewards.length,
                            ),
                    color: const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab(AppLocalizations l10n) {
    return StreamBuilder<List<ChildProfile>>(
      stream: _firestoreService.getCurrentChildProfiles(),
      builder: (context, childSnapshot) {
        return StreamBuilder<List<WhenThenOption>>(
          stream: _firestoreService.getCurrentWhenThenOptions(
            type: 'activities',
          ),
          builder: (context, activitySnapshot) {
            return StreamBuilder<List<WhenThenOption>>(
              stream: _firestoreService.getCurrentWhenThenOptions(
                type: 'rewards',
              ),
              builder: (context, rewardSnapshot) {
                if (childSnapshot.hasError ||
                    activitySnapshot.hasError ||
                    rewardSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.boardOptionsLoadFailed,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!childSnapshot.hasData ||
                    !activitySnapshot.hasData ||
                    !rewardSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final children = childSnapshot.data!;
                final activities = activitySnapshot.data!;
                final rewards = rewardSnapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      l10n.createClearVisualBoard,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.createBoardIntro,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    _buildWhoSection(children),
                    const SizedBox(height: 16),
                    _buildWhenSection(activities),
                    const SizedBox(height: 16),
                    _buildThenSection(rewards),
                    const SizedBox(height: 20),
                    _buildPreview(rewards),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed:
                            _isApplying
                                ? null
                                : () => _createBoard(
                                  children: children,
                                  rewards: rewards,
                                  l10n: l10n,
                                ),
                        icon:
                            _isApplying
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.send_rounded),
                        label: Text(
                          _isApplying
                              ? l10n.creatingBoard
                              : l10n.createWhenThenBoard,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveBoardsTab() {
    return StreamBuilder<List<ChildProfile>>(
      stream: _firestoreService.getCurrentChildProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(context.l10n.childProfilesLoadFailed));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final children = snapshot.data!;

        if (children.isEmpty) {
          return Center(child: Text(context.l10n.noChildProfilesFound));
        }

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              context.l10n.activeBoards,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(context.l10n.activeBoardsIntro),
            const SizedBox(height: 18),
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActiveBoardCard(
                  child: child,
                  firestoreService: _firestoreService,
                  onMessage: _showMessage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionsList({
    required String title,
    required String description,
    required String type,
    required Color color,
  }) {
    return StreamBuilder<List<WhenThenOption>>(
      stream: _firestoreService.getCurrentWhenThenOptions(type: type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(context.l10n.optionsLoadFailed(title)),
            ),
          );
        }

        final options = snapshot.data ?? [];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: color.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        type == 'activities'
                            ? Icons.task_alt_rounded
                            : Icons.celebration_rounded,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(description),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showOptionDialog(type: type),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(context.l10n.add),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(context.l10n.noOptionsAdded),
                  )
                else
                  ...options.map((option) {
                    final style = whenThenStyleFor(option.iconName);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: style.color.withValues(alpha: 0.14),
                        child: Icon(style.icon, color: style.color),
                      ),
                      title: Text(
                        option.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: context.l10n.edit,
                            onPressed:
                                () => _showOptionDialog(
                                  type: type,
                                  existingOption: option,
                                ),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            tooltip: context.l10n.delete,
                            onPressed:
                                () => _confirmDeleteOption(
                                  type: type,
                                  option: option,
                                ),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageOptionsTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          context.l10n.manageOptions,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(context.l10n.manageOptionsIntro),
        const SizedBox(height: 18),
        _buildOptionsList(
          title: context.l10n.whenActivities,
          description: context.l10n.whenActivitiesDescription,
          type: 'activities',
          color: const Color(0xFF42A5F5),
        ),
        const SizedBox(height: 16),
        _buildOptionsList(
          title: context.l10n.thenRewards,
          description: context.l10n.thenRewardsDescription,
          type: 'rewards',
          color: const Color(0xFFFFA726),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.whenThenSetup),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.add_task_rounded), text: l10n.create),
              Tab(
                icon: const Icon(Icons.view_carousel_rounded),
                text: l10n.activeBoards,
              ),
              Tab(icon: const Icon(Icons.tune_rounded), text: l10n.options),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTab(l10n),
            _buildActiveBoardsTab(),
            _buildManageOptionsTab(),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Text(
                    '$number',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _OptionChoiceCard extends StatelessWidget {
  final String label;
  final String iconName;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _OptionChoiceCard({
    required this.label,
    required this.iconName,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = whenThenStyleFor(iconName);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 170,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                selected
                    ? style.color.withValues(alpha: 0.18)
                    : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? style.color : Theme.of(context).dividerColor,
              width: selected ? 3 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: style.color.withValues(alpha: 0.16),
                child: Icon(style.icon, color: style.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: style.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final String heading;
  final WhenThenOption? option;
  final String emptyText;
  final Color color;

  const _PreviewPanel({
    required this.heading,
    required this.option,
    required this.emptyText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = option == null ? null : whenThenStyleFor(option!.iconName);

    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            heading,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Icon(
            style?.icon ?? Icons.help_outline_rounded,
            color: style?.color ?? color,
            size: 38,
          ),
          const SizedBox(height: 8),
          Text(
            option?.label ?? emptyText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActiveBoardCard extends StatelessWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;
  final ValueChanged<String> onMessage;

  const _ActiveBoardCard({
    required this.child,
    required this.firestoreService,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: firestoreService.getCurrentWhenThenStream(childId: child.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: ListTile(
              leading: const CircularProgressIndicator(),
              title: Text(child.name),
            ),
          );
        }

        final board = snapshot.data;
        final isActive = board?['isActive'] == true;
        final rawActivity = board?['activity'];
        final activity =
            rawActivity is Map ? Map<String, dynamic>.from(rawActivity) : null;

        if (!isActive || activity == null) {
          return Card(
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  child.name.isEmpty
                      ? '?'
                      : child.name.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(child.name),
              subtitle: Text(context.l10n.noActiveBoard),
              trailing: const Icon(Icons.radio_button_unchecked_rounded),
            ),
          );
        }

        final rawRewards = board?['rewards'];
        final rewards =
            rawRewards is List
                ? rawRewards
                    .whereType<Map>()
                    .map((reward) => Map<String, dynamic>.from(reward))
                    .toList()
                : <Map<String, dynamic>>[];

        final selectedRewardId = board?['selectedRewardId'] as String?;

        final selectedReward =
            selectedRewardId == null
                ? null
                : rewards.cast<Map<String, dynamic>?>().firstWhere(
                  (reward) => reward?['id'] == selectedRewardId,
                  orElse: () => null,
                );

        final activityStyle = whenThenStyleFor(
          activity['iconName'] as String? ?? 'task',
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: activityStyle.color.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: activityStyle.color.withValues(alpha: 0.14),
                  child: Icon(activityStyle.icon, color: activityStyle.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.whenActivitySummary(
                          activity['label'] as String? ?? '',
                        ),
                      ),
                      Text(
                        selectedReward == null
                            ? context.l10n.thenWaitingForReward
                            : context.l10n.thenRewardSummary(
                              selectedReward['label'] as String? ?? '',
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final l10n = context.l10n;

                    try {
                      await firestoreService.clearCurrentWhenThenForChild(
                        child.id,
                      );
                      onMessage(l10n.childBoardCleared(child.name));
                    } catch (error) {
                      onMessage(l10n.boardClearFailed(error.toString()));
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(context.l10n.complete),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
