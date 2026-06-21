import 'package:flutter/material.dart';
import '../data/when_then_icons.dart';
import '../models/child_profile.dart';
import '../models/when_then_option.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';

enum WhenThenTargetMode { single, multiple, all }

class WhenThenSetupPage extends StatefulWidget {
  final String teacherUid;

  const WhenThenSetupPage({
    super.key,
    required this.teacherUid,
  });

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<String>? _targetChildIds(List<ChildProfile> children) {
    switch (_targetMode) {
      case WhenThenTargetMode.single:
        if (_singleChildId == null) {
          _showMessage('Please choose a child.');
          return null;
        }
        return [_singleChildId!];

      case WhenThenTargetMode.multiple:
        if (_selectedChildIds.isEmpty) {
          _showMessage('Please choose at least one child.');
          return null;
        }
        return _selectedChildIds.toList();

      case WhenThenTargetMode.all:
        if (children.isEmpty) {
          _showMessage('No child profiles were found.');
          return null;
        }
        return children.map((child) => child.id).toList();
    }
  }

  Future<void> _createBoard({
    required List<ChildProfile> children,
    required List<WhenThenOption> rewards,
    required SimpleLocalizations loc,
  }) async {
    if (_selectedActivity == null) {
      _showMessage('Choose the WHEN activity first.');
      return;
    }

    if (_selectedRewardIds.isEmpty || _selectedRewardIds.length > 3) {
      _showMessage('Choose between 1 and 3 THEN rewards.');
      return;
    }

    final selectedRewards = rewards
        .where((reward) => _selectedRewardIds.contains(reward.id))
        .toList();

    if (selectedRewards.length != _selectedRewardIds.length) {
      _showMessage('One of the selected rewards is no longer available.');
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
          content: Text(loc.getString('when_then_applied')),
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
      _showMessage(
        '${loc.getString('failed_to_apply_when_then')}: $error',
      );
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
                    ? 'Edit ${type == 'activities' ? 'activity' : 'reward'}'
                    : 'Add ${type == 'activities' ? 'activity' : 'reward'}',
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
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter a clear, short name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Choose an icon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: whenThenIconStyles.map((style) {
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
                                color: selected
                                    ? style.color
                                    : style.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? style.color
                                      : style.color.withValues(alpha: 0.35),
                                  width: selected ? 3 : 1,
                                ),
                              ),
                              child: Icon(
                                style.icon,
                                color: selected ? Colors.white : style.color,
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
                  child: const Text('Cancel'),
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
                  child: Text(isEditing ? 'Save' : 'Add'),
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
      _showMessage('Could not save this option: $error');
    }
  }

  Future<void> _confirmDeleteOption({
    required String type,
    required WhenThenOption option,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete option?'),
          content: Text(
            'Are you sure you want to delete “${option.label}”?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Delete'),
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
      _showMessage('Could not delete this option: $error');
    }
  }

  Widget _buildWhoSection(List<ChildProfile> children) {
    return _StepCard(
      number: 1,
      title: 'WHO',
      subtitle: 'Who should see this board?',
      color: const Color(0xFF5C6BC0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<WhenThenTargetMode>(
            segments: const [
              ButtonSegment(
                value: WhenThenTargetMode.single,
                icon: Icon(Icons.person_rounded),
                label: Text('One'),
              ),
              ButtonSegment(
                value: WhenThenTargetMode.multiple,
                icon: Icon(Icons.people_alt_rounded),
                label: Text('Some'),
              ),
              ButtonSegment(
                value: WhenThenTargetMode.all,
                icon: Icon(Icons.groups_rounded),
                label: Text('Everyone'),
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
              decoration: const InputDecoration(
                labelText: 'Choose a child',
                prefixIcon: Icon(Icons.person_search_rounded),
                border: OutlineInputBorder(),
              ),
              items: children.map((child) {
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
              children: children.map((child) {
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
                      'This board will be sent to all '
                      '${children.length} child profiles.',
                    ),
                  ),
                ],
              ),
            ),
          if (children.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('No child profiles are available.'),
            ),
        ],
      ),
    );
  }

  Widget _buildWhenSection(List<WhenThenOption> activities) {
    return _StepCard(
      number: 2,
      title: 'WHEN',
      subtitle: 'What needs to happen first?',
      color: const Color(0xFF42A5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activities.isEmpty)
            const Text(
              'No activities yet. Add one in Manage Options.',
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activities.map((activity) {
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
      title: 'THEN',
      subtitle: 'Choose between 1 and 3 possible rewards.',
      color: const Color(0xFFFFA726),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rewards.isEmpty)
            const Text(
              'No rewards yet. Add one in Manage Options.',
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: rewards.map((reward) {
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
                color: _selectedRewardIds.isEmpty
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedRewardIds.length} of 3 rewards selected',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
    List<WhenThenOption> rewards,
  ) {
    final selectedRewards = rewards
        .where((reward) => _selectedRewardIds.contains(reward.id))
        .toList();

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.visibility_rounded),
                const SizedBox(width: 8),
                Text(
                  'Board preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _PreviewPanel(
                    heading: 'WHEN',
                    option: _selectedActivity,
                    emptyText: 'Choose an activity',
                    color: const Color(0xFF42A5F5),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 34,
                  ),
                ),
                Expanded(
                  child: _PreviewPanel(
                    heading: 'THEN',
                    option: selectedRewards.isEmpty
                        ? null
                        : selectedRewards.first,
                    emptyText: selectedRewards.isEmpty
                        ? 'Choose rewards'
                        : selectedRewards.length == 1
                            ? selectedRewards.first.label
                            : '${selectedRewards.length} reward choices',
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

  Widget _buildCreateTab(SimpleLocalizations loc) {
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Something went wrong loading the board options.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!childSnapshot.hasData ||
                    !activitySnapshot.hasData ||
                    !rewardSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final children = childSnapshot.data!;
                final activities = activitySnapshot.data!;
                final rewards = rewardSnapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      'Create a clear visual board',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose who it is for, what happens WHEN, '
                      'and what they can enjoy THEN.',
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
                        onPressed: _isApplying
                            ? null
                            : () => _createBoard(
                                  children: children,
                                  rewards: rewards,
                                  loc: loc,
                                ),
                        icon: _isApplying
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
                              ? 'Creating board...'
                              : 'Create When–Then Board',
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
          return const Center(
            child: Text('Could not load child profiles.'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final children = snapshot.data!;

        if (children.isEmpty) {
          return const Center(
            child: Text('No child profiles were found.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Active boards',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'See each child’s current board and clear it when complete.',
            ),
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
              child: Text('Could not load $title.'),
            ),
          );
        }

        final options = snapshot.data ?? [];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: color.withValues(alpha: 0.25),
            ),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(description),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showOptionDialog(type: type),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (options.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No options have been added yet.'),
                  )
                else
                  ...options.map((option) {
                    final style = whenThenStyleFor(option.iconName);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            style.color.withValues(alpha: 0.14),
                        child: Icon(style.icon, color: style.color),
                      ),
                      title: Text(
                        option.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _showOptionDialog(
                              type: type,
                              existingOption: option,
                            ),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _confirmDeleteOption(
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
          'Manage options',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep names short and clear so children can understand them quickly.',
        ),
        const SizedBox(height: 18),
        _buildOptionsList(
          title: 'WHEN activities',
          description: 'Tasks and activities to complete.',
          type: 'activities',
          color: const Color(0xFF42A5F5),
        ),
        const SizedBox(height: 16),
        _buildOptionsList(
          title: 'THEN rewards',
          description: 'Positive choices offered afterwards.',
          type: 'rewards',
          color: const Color(0xFFFFA726),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.getString('when_then_setup')),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.add_task_rounded),
                text: 'Create',
              ),
              Tab(
                icon: Icon(Icons.view_carousel_rounded),
                text: 'Active Boards',
              ),
              Tab(
                icon: Icon(Icons.tune_rounded),
                text: 'Options',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTab(loc),
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
        side: BorderSide(
          color: color.withValues(alpha: 0.28),
        ),
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
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
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
            color: selected
                ? style.color.withValues(alpha: 0.18)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? style.color
                  : Theme.of(context).dividerColor,
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
                Icon(
                  Icons.check_circle_rounded,
                  color: style.color,
                ),
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
    final style = option == null
        ? null
        : whenThenStyleFor(option!.iconName);

    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
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
      stream: firestoreService.getCurrentWhenThenStream(
        childId: child.id,
      ),
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
        final activity = rawActivity is Map
            ? Map<String, dynamic>.from(rawActivity)
            : null;

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
              subtitle: const Text('No active board'),
              trailing: const Icon(
                Icons.radio_button_unchecked_rounded,
              ),
            ),
          );
        }

        final rawRewards = board?['rewards'];
        final rewards = rawRewards is List
            ? rawRewards
                .whereType<Map>()
                .map((reward) => Map<String, dynamic>.from(reward))
                .toList()
            : <Map<String, dynamic>>[];

        final selectedRewardId = board?['selectedRewardId'] as String?;

        final selectedReward = selectedRewardId == null
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
            side: BorderSide(
              color: activityStyle.color.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      activityStyle.color.withValues(alpha: 0.14),
                  child: Icon(
                    activityStyle.icon,
                    color: activityStyle.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('WHEN: ${activity['label'] ?? ''}'),
                      Text(
                        selectedReward == null
                            ? 'THEN: Waiting for reward choice'
                            : 'THEN: ${selectedReward['label'] ?? ''}',
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await firestoreService
                          .clearCurrentWhenThenForChild(child.id);
                      onMessage('${child.name}’s board was cleared.');
                    } catch (error) {
                      onMessage('Could not clear the board: $error');
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}