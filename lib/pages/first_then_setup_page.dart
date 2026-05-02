import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/first_then_option.dart';
import '../services/firestore_service.dart';
import '../simple_localizations.dart';

enum FirstThenTargetMode { single, multiple, all }

class FirstThenSetupPage extends StatefulWidget {
  final String teacherUid;

  const FirstThenSetupPage({
    super.key,
    required this.teacherUid,
  });

  @override
  State<FirstThenSetupPage> createState() => _FirstThenSetupPageState();
}

class _FirstThenSetupPageState extends State<FirstThenSetupPage> {
  final FirestoreService _firestoreService = FirestoreService();

  FirstThenTargetMode _targetMode = FirstThenTargetMode.single;

  FirstThenOption? _selectedActivity;
  String? _singleChildId;

  final Set<String> _selectedChildIds = {};
  final Set<String> _selectedRewardIds = {};

  @override
  void initState() {
    super.initState();
    _firestoreService.seedDefaultFirstThenOptions(widget.teacherUid);
  }

  Future<void> _apply(
    List<ChildProfile> children,
    List<FirstThenOption> rewards,
    SimpleLocalizations loc,
  ) async {
    if (_selectedActivity == null) {
      _showMessage(loc.getString('select_activity_first'));
      return;
    }

    if (_selectedRewardIds.length != 3) {
      _showMessage(loc.getString('select_three_rewards'));
      return;
    }

    final selectedRewards = rewards
        .where((reward) => _selectedRewardIds.contains(reward.id))
        .toList();

    if (selectedRewards.length != 3) {
      _showMessage('Please select 3 valid rewards.');
      return;
    }

    List<String> targetChildIds = [];

    switch (_targetMode) {
      case FirstThenTargetMode.single:
        if (_singleChildId == null) {
          _showMessage(loc.getString('select_child_first'));
          return;
        }
        targetChildIds = [_singleChildId!];
        break;

      case FirstThenTargetMode.multiple:
        if (_selectedChildIds.isEmpty) {
          _showMessage(loc.getString('select_at_least_one_child'));
          return;
        }
        targetChildIds = _selectedChildIds.toList();
        break;

      case FirstThenTargetMode.all:
        targetChildIds = children.map((child) => child.id).toList();
        if (targetChildIds.isEmpty) {
          _showMessage(loc.getString('no_child_profiles_found'));
          return;
        }
        break;
    }

    try {
      await _firestoreService.setFirstThenForChildren(
        teacherUid: widget.teacherUid,
        childIds: targetChildIds,
        activity: _selectedActivity!,
        rewards: selectedRewards,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.getString('first_then_applied'))),
      );

      setState(() {
        _selectedActivity = null;
        _singleChildId = null;
        _selectedChildIds.clear();
        _selectedRewardIds.clear();
      });
    } catch (e) {
      _showMessage('${loc.getString('failed_to_apply_first_then')}: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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

  List<String> get _iconChoices => [
        'task',
        'quiz',
        'book',
        'clean',
        'music',
        'toys',
        'outside',
        'break',
      ];

  Future<void> _showOptionDialog({
    required String type,
    FirstThenOption? existingOption,
  }) async {
    final isEditing = existingOption != null;

    final labelController = TextEditingController(
      text: existingOption?.label ?? '',
    );

    String selectedIcon = existingOption?.iconName ?? 'task';

    final result = await showDialog<FirstThenOption>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit option' : 'Add option'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Option name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: const InputDecoration(
                      labelText: 'Icon',
                      border: OutlineInputBorder(),
                    ),
                    items: _iconChoices.map((iconName) {
                      return DropdownMenuItem(
                        value: iconName,
                        child: Row(
                          children: [
                            Icon(_iconForKey(iconName)),
                            const SizedBox(width: 8),
                            Text(iconName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedIcon = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final label = labelController.text.trim();

                    if (label.isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      context,
                      FirstThenOption(
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

    if (result == null) return;

    if (isEditing) {
      await _firestoreService.updateFirstThenOption(
        teacherUid: widget.teacherUid,
        type: type,
        option: result,
      );
    } else {
      await _firestoreService.addFirstThenOption(
        teacherUid: widget.teacherUid,
        type: type,
        option: result,
      );
    }
  }

  Future<void> _confirmDeleteOption({
    required String type,
    required FirstThenOption option,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete option?'),
          content: Text('Delete "${option.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _firestoreService.deleteFirstThenOption(
      teacherUid: widget.teacherUid,
      type: type,
      optionId: option.id,
    );
  }

  Widget _buildAssignTab(SimpleLocalizations loc) {
    return StreamBuilder<List<ChildProfile>>(
      stream: _firestoreService.getChildProfiles(widget.teacherUid),
      builder: (context, childSnapshot) {
        final children = childSnapshot.data ?? [];

        return StreamBuilder<List<FirstThenOption>>(
          stream: _firestoreService.getFirstThenOptions(
            teacherUid: widget.teacherUid,
            type: 'activities',
          ),
          builder: (context, activitySnapshot) {
            final activities = activitySnapshot.data ?? [];

            return StreamBuilder<List<FirstThenOption>>(
              stream: _firestoreService.getFirstThenOptions(
                teacherUid: widget.teacherUid,
                type: 'rewards',
              ),
              builder: (context, rewardSnapshot) {
                final rewards = rewardSnapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      loc.getString('choose_who_this_applies_to'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    SegmentedButton<FirstThenTargetMode>(
                      segments: [
                        ButtonSegment(
                          value: FirstThenTargetMode.single,
                          label: Text(loc.getString('single')),
                          icon: const Icon(Icons.person),
                        ),
                        ButtonSegment(
                          value: FirstThenTargetMode.multiple,
                          label: Text(loc.getString('multiple')),
                          icon: const Icon(Icons.people),
                        ),
                        ButtonSegment(
                          value: FirstThenTargetMode.all,
                          label: Text(loc.getString('all')),
                          icon: const Icon(Icons.groups),
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

                    const SizedBox(height: 20),

                    if (_targetMode == FirstThenTargetMode.single)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: loc.getString('select_child'),
                          border: const OutlineInputBorder(),
                        ),
                        initialValue: _singleChildId,
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

                    if (_targetMode == FirstThenTargetMode.multiple) ...[
                      Text(
                        loc.getString('select_children'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...children.map((child) {
                        final selected = _selectedChildIds.contains(child.id);

                        return CheckboxListTile(
                          title: Text(child.name),
                          value: selected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChildIds.add(child.id);
                              } else {
                                _selectedChildIds.remove(child.id);
                              }
                            });
                          },
                        );
                      }),
                    ],

                    if (_targetMode == FirstThenTargetMode.all)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(loc.getString('applies_to_all_children')),
                        ),
                      ),

                    const SizedBox(height: 24),

                    Text(
                      loc.getString('select_activity'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    if (activities.isEmpty)
                      const Text('No activities yet. Add one in Manage Options.'),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: activities.map((activity) {
                        final selected = _selectedActivity?.id == activity.id;

                        return ChoiceChip(
                          selected: selected,
                          label: Text(activity.label),
                          avatar: Icon(_iconForKey(activity.iconName), size: 18),
                          onSelected: (_) {
                            setState(() {
                              _selectedActivity = activity;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      loc.getString('select_three_reward_options'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    if (rewards.isEmpty)
                      const Text('No rewards yet. Add one in Manage Options.'),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: rewards.map((reward) {
                        final selected = _selectedRewardIds.contains(reward.id);
                        final canSelectMore = _selectedRewardIds.length < 3;

                        return FilterChip(
                          selected: selected,
                          label: Text(reward.label),
                          avatar: Icon(_iconForKey(reward.iconName), size: 18),
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                if (canSelectMore && !selected) {
                                  _selectedRewardIds.add(reward.id);
                                }
                              } else {
                                _selectedRewardIds.remove(reward.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${loc.getString('selected')}: ${_selectedRewardIds.length}/3',
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(loc.getString('apply_first_then')),
                      onPressed: () => _apply(children, rewards, loc),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOptionsList({
    required String title,
    required String type,
  }) {
    return StreamBuilder<List<FirstThenOption>>(
      stream: _firestoreService.getFirstThenOptions(
        teacherUid: widget.teacherUid,
        type: type,
      ),
      builder: (context, snapshot) {
        final options = snapshot.data ?? [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showOptionDialog(type: type),
                    ),
                  ],
                ),
                const Divider(),
                if (options.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No options added yet.'),
                  ),
                ...options.map((option) {
                  return ListTile(
                    leading: Icon(_iconForKey(option.iconName)),
                    title: Text(option.label),
                    subtitle: Text(option.iconName),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showOptionDialog(
                            type: type,
                            existingOption: option,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteOption(
                            type: type,
                            option: option,
                          ),
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
      padding: const EdgeInsets.all(16),
      children: [
        _buildOptionsList(
          title: 'Activities',
          type: 'activities',
        ),
        const SizedBox(height: 16),
        _buildOptionsList(
          title: 'Rewards',
          type: 'rewards',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.getString('first_then_setup')),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.assignment),
                text: 'Assign Task',
              ),
              Tab(
                icon: Icon(Icons.tune),
                text: 'Manage Options',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAssignTab(loc),
            _buildManageOptionsTab(),
          ],
        ),
      ),
    );
  }
}