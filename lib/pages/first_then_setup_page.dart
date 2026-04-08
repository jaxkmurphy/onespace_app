import 'package:flutter/material.dart';
import '../models/child_profile.dart';
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

  final List<String> _activities = [
    'quiz',
    'homework',
    'clean_up',
    'finish_work',
  ];

  final List<String> _rewards = [
    'calming_sounds',
    'playtime',
    'outside_time',
    'break',
    'music',
  ];

  FirstThenTargetMode _targetMode = FirstThenTargetMode.single;
  String? _selectedActivity;
  String? _singleChildId;
  final Set<String> _selectedChildIds = {};
  final Set<String> _selectedRewards = {};

  Future<void> _apply(List<ChildProfile> children, SimpleLocalizations loc) async {
    if (_selectedActivity == null) {
      _showMessage(loc.getString('select_activity_first'));
      return;
    }

    if (_selectedRewards.length != 3) {
      _showMessage(loc.getString('select_three_rewards'));
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
        targetChildIds = children.map((c) => c.id).toList();
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
        rewards: _selectedRewards.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.getString('first_then_applied'))),
      );

      setState(() {
        _selectedRewards.clear();
        _selectedActivity = null;
        _singleChildId = null;
        _selectedChildIds.clear();
      });
    } catch (e) {
      _showMessage('${loc.getString('failed_to_apply_first_then')}: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _labelForKey(SimpleLocalizations loc, String key) {
    switch (key) {
      case 'quiz':
        return loc.getString('quiz');
      case 'homework':
        return loc.getString('homework');
      case 'clean_up':
        return loc.getString('clean_up');
      case 'finish_work':
        return loc.getString('finish_work');
      case 'calming_sounds':
        return loc.getString('calming_sounds');
      case 'playtime':
        return loc.getString('playtime');
      case 'outside_time':
        return loc.getString('outside_time');
      case 'break':
        return loc.getString('break');
      case 'music':
        return loc.getString('music');
      default:
        return key;
    }
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'quiz':
        return Icons.quiz;
      case 'homework':
        return Icons.book;
      case 'clean_up':
        return Icons.cleaning_services;
      case 'finish_work':
        return Icons.task_alt;
      case 'calming_sounds':
        return Icons.music_note;
      case 'playtime':
        return Icons.toys;
      case 'outside_time':
        return Icons.park;
      case 'break':
        return Icons.free_breakfast;
      case 'music':
        return Icons.library_music;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.getString('first_then_setup')),
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _firestoreService.getChildProfiles(widget.teacherUid),
        builder: (context, snapshot) {
          final children = snapshot.data ?? [];

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

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _activities.map((activity) {
                  final selected = _selectedActivity == activity;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(_labelForKey(loc, activity)),
                    avatar: Icon(_iconForKey(activity), size: 18),
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

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _rewards.map((reward) {
                  final selected = _selectedRewards.contains(reward);
                  final canSelectMore = _selectedRewards.length < 3;

                  return FilterChip(
                    selected: selected,
                    label: Text(_labelForKey(loc, reward)),
                    avatar: Icon(_iconForKey(reward), size: 18),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          if (canSelectMore || selected) {
                            _selectedRewards.add(reward);
                          }
                        } else {
                          _selectedRewards.remove(reward);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              Text(
                '${loc.getString('selected')}: ${_selectedRewards.length}/3',
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text(loc.getString('apply_first_then')),
                onPressed: () => _apply(children, loc),
              ),
            ],
          );
        },
      ),
    );
  }
}