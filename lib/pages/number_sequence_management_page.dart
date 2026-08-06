import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/number_sequence_models.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';

class NumberSequenceManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const NumberSequenceManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<NumberSequenceManagementPage> createState() =>
      _NumberSequenceManagementPageState();
}

class _NumberSequenceManagementPageState
    extends State<NumberSequenceManagementPage> {
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _createChallenge() async {
    final text = LearningGameLocalizations.of(context);
    final draft = await showDialog<_ChallengeDraft>(
      context: context,
      builder: (_) => const _ChallengeDialog(),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentNumberSequenceChallenge(
        NumberSequenceChallenge(
          id: '',
          title: draft.title,
          description: draft.description,
          iconName: draft.iconName,
          maxNumber: draft.maxNumber,
          timerEnabled: draft.timerEnabled,
          active: true,
          availableToAll: true,
          assignedChildIds: const [],
          createdByStaffId: widget.staffProfile.id,
          createdByStaffName: widget.staffProfile.name,
        ),
      );
      _showMessage(
        text.isIrish
            ? 'Cruthaíodh dúshlán Ord Uimhreacha.'
            : 'Number Sequence challenge created.',
      );
    } catch (error) {
      _showMessage(
        text.isIrish
            ? 'Níorbh fhéidir an dúshlán a chruthú: $error'
            : 'Could not create challenge: $error',
      );
    }
  }

  Future<void> _editChallenge(NumberSequenceChallenge challenge) async {
    final draft = await showDialog<_ChallengeDraft>(
      context: context,
      builder: (_) => _ChallengeDialog(challenge: challenge),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentNumberSequenceChallenge(
        challenge.copyWith(
          title: draft.title,
          description: draft.description,
          iconName: draft.iconName,
          maxNumber: draft.maxNumber,
          timerEnabled: draft.timerEnabled,
          updatedAt: DateTime.now(),
        ),
      );
      _showMessage('Challenge updated.');
    } catch (error) {
      _showMessage('Could not update challenge: $error');
    }
  }

  Future<void> _editAudience(NumberSequenceChallenge challenge) async {
    List<ChildProfile> children;

    try {
      children = await widget.firestoreService.getCurrentChildProfilesOnce();
    } catch (error) {
      _showMessage('Could not load children: $error');
      return;
    }

    if (!mounted) return;

    final draft = await showDialog<_AudienceDraft>(
      context: context,
      builder: (_) => _AudienceDialog(challenge: challenge, children: children),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentNumberSequenceChallenge(
        challenge.copyWith(
          availableToAll: draft.availableToAll,
          assignedChildIds:
              draft.availableToAll ? const [] : draft.selectedChildIds,
          updatedAt: DateTime.now(),
        ),
      );
      _showMessage('Audience updated.');
    } catch (error) {
      _showMessage('Could not update audience: $error');
    }
  }

  Future<void> _toggleActive(NumberSequenceChallenge challenge) async {
    try {
      await widget.firestoreService.updateCurrentNumberSequenceChallenge(
        challenge.copyWith(
          active: !challenge.active,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      _showMessage('Could not update challenge: $error');
    }
  }

  Future<void> _deleteChallenge(NumberSequenceChallenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete challenge?'),
            content: Text('This will delete "${challenge.title}".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentNumberSequenceChallenge(
        challenge.id,
      );
      _showMessage('Challenge deleted.');
    } catch (error) {
      _showMessage('Could not delete challenge: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF29B6F6);
    final text = LearningGameLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(text.numberSequence)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createChallenge,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(text.createChallenge),
      ),
      body: StreamBuilder<List<NumberSequenceChallenge>>(
        stream: widget.firestoreService.getCurrentNumberSequenceChallenges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(text.couldNotLoadChallenges));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final challenges = snapshot.data!;

          if (challenges.isEmpty) {
            return _EmptyState(color: color, onPressed: _createChallenge);
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4FBFF), Color(0xFFF7F4FF)],
              ),
            ),
            child: GridView.builder(
              key: const PageStorageKey('number-sequence-management'),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 315,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];

                return _ChallengeCard(
                  challenge: challenge,
                  color: color,
                  onEdit: () => _editChallenge(challenge),
                  onAudience: () => _editAudience(challenge),
                  onToggleActive: () => _toggleActive(challenge),
                  onDelete: () => _deleteChallenge(challenge),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final NumberSequenceChallenge challenge;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onAudience;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _ChallengeCard({
    required this.challenge,
    required this.color,
    required this.onEdit,
    required this.onAudience,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: color.withValues(alpha: 0.28), width: 2),
      ),
      child: Column(
        children: [
          Container(
            height: 92,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.72)],
              ),
            ),
            child: Center(
              child: Icon(
                appIconForKey(challenge.iconName, fallbackKey: 'pin'),
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'audience':
                              onAudience();
                              break;
                            case 'toggle':
                              onToggleActive();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'audience',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.groups_rounded),
                                  title: const Text('Audience'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    challenge.active
                                        ? Icons.pause_circle_rounded
                                        : Icons.play_circle_rounded,
                                  ),
                                  title: Text(
                                    challenge.active
                                        ? 'Set inactive'
                                        : 'Set active',
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                  ),
                                  title: Text(context.l10n.delete),
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.description.isEmpty
                        ? 'Numbers 1-${challenge.maxNumber}'
                        : challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _GamePackChip(
                        icon: Icons.pin_rounded,
                        label:
                            '1-${challenge.maxNumber} · ${challenge.timerEnabled ? 'Timer' : 'No timer'}',
                        color: color,
                      ),
                      _GamePackChip(
                        icon:
                            challenge.availableToAll
                                ? Icons.groups_rounded
                                : Icons.people_alt_rounded,
                        label:
                            challenge.availableToAll
                                ? context.l10n.availableToEveryone
                                : context.l10n.assignedChildCount(
                                  challenge.assignedChildIds.length,
                                ),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onEdit,
                          style: FilledButton.styleFrom(backgroundColor: color),
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(context.l10n.edit),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamePackChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GamePackChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeDialog extends StatefulWidget {
  final NumberSequenceChallenge? challenge;

  const _ChallengeDialog({this.challenge});

  @override
  State<_ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<_ChallengeDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _iconName;
  late int _maxNumber;
  late bool _timerEnabled;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.challenge?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.challenge?.description ?? '',
    );
    _iconName = widget.challenge?.iconName ?? 'pin';
    _maxNumber = widget.challenge?.maxNumber ?? 9;
    _timerEnabled = widget.challenge?.timerEnabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _iconName,
      title: 'Choose challenge icon',
    );

    if (selected == null) return;
    setState(() => _iconName = selected.key);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      _ChallengeDraft(
        title: title,
        description: _descriptionController.text.trim(),
        iconName: _iconName,
        maxNumber: _maxNumber,
        timerEnabled: _timerEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.challenge == null ? 'Create challenge' : 'Edit challenge',
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Challenge name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _chooseIcon,
                icon: AppIconPreview(iconKey: _iconName),
                label: const Text('Choose icon'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Highest number',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  DropdownButton<int>(
                    value: _maxNumber,
                    items:
                        const [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('1-$value'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _maxNumber = value);
                    },
                  ),
                ],
              ),
              SwitchListTile(
                value: _timerEnabled,
                onChanged: (value) => setState(() => _timerEnabled = value),
                title: const Text('Use timer'),
                subtitle: const Text('Timer starts when the child taps 1.'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _AudienceDialog extends StatefulWidget {
  final NumberSequenceChallenge challenge;
  final List<ChildProfile> children;

  const _AudienceDialog({required this.challenge, required this.children});

  @override
  State<_AudienceDialog> createState() => _AudienceDialogState();
}

class _AudienceDialogState extends State<_AudienceDialog> {
  late bool _availableToAll;
  late Set<String> _selectedChildIds;

  @override
  void initState() {
    super.initState();
    _availableToAll = widget.challenge.availableToAll;
    _selectedChildIds = widget.challenge.assignedChildIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose audience'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    selected: _availableToAll,
                    avatar: const Icon(Icons.groups_rounded),
                    label: Text(context.l10n.availableToEveryone),
                    onSelected: (_) {
                      setState(() {
                        _availableToAll = true;
                        _selectedChildIds.clear();
                      });
                    },
                  ),
                  ChoiceChip(
                    selected: !_availableToAll,
                    avatar: const Icon(Icons.people_alt_rounded),
                    label: Text(context.l10n.selectedChildren),
                    onSelected: (_) => setState(() => _availableToAll = false),
                  ),
                ],
              ),
              if (!_availableToAll) ...[
                const SizedBox(height: 16),
                if (widget.children.isEmpty)
                  Text(context.l10n.noChildrenAvailable)
                else
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children:
                        widget.children.map((child) {
                          final selected = _selectedChildIds.contains(child.id);

                          return FilterChip(
                            selected: selected,
                            avatar: const Icon(Icons.child_care_rounded),
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
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(
              context,
              _AudienceDraft(
                availableToAll: _availableToAll,
                selectedChildIds: _selectedChildIds.toList(),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const _EmptyState({required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pin_rounded, size: 78, color: color),
            const SizedBox(height: 18),
            Text(
              'No Number Sequence challenges yet',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a challenge preset with a number range and timer setting.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create challenge'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeDraft {
  final String title;
  final String description;
  final String iconName;
  final int maxNumber;
  final bool timerEnabled;

  const _ChallengeDraft({
    required this.title,
    required this.description,
    required this.iconName,
    required this.maxNumber,
    required this.timerEnabled,
  });
}

class _AudienceDraft {
  final bool availableToAll;
  final List<String> selectedChildIds;

  const _AudienceDraft({
    required this.availableToAll,
    required this.selectedChildIds,
  });
}
