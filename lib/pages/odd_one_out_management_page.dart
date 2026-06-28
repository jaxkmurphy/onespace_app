import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/odd_one_out_models.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';

class OddOneOutManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const OddOneOutManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<OddOneOutManagementPage> createState() =>
      _OddOneOutManagementPageState();
}

class _OddOneOutManagementPageState extends State<OddOneOutManagementPage> {
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _createPack() async {
    final draft = await showDialog<_PackDraft>(
      context: context,
      builder: (_) => const _PackDialog(),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentOddOneOutPack(
        OddOneOutPack(
          id: '',
          title: draft.title,
          description: draft.description,
          iconName: draft.iconName,
          active: true,
          availableToAll: true,
          assignedChildIds: const [],
          createdByStaffId: widget.staffProfile.id,
          createdByStaffName: widget.staffProfile.name,
        ),
      );

      _showMessage('Odd One Out pack created.');
    } catch (error) {
      _showMessage('Could not create pack: $error');
    }
  }

  Future<void> _editPack(OddOneOutPack pack) async {
    final draft = await showDialog<_PackDraft>(
      context: context,
      builder: (_) => _PackDialog(pack: pack),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentOddOneOutPack(
        pack.copyWith(
          title: draft.title,
          description: draft.description,
          iconName: draft.iconName,
          updatedAt: DateTime.now(),
        ),
      );

      _showMessage('Pack updated.');
    } catch (error) {
      _showMessage('Could not update pack: $error');
    }
  }

  Future<void> _editAudience(OddOneOutPack pack) async {
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
      builder: (_) => _AudienceDialog(pack: pack, children: children),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentOddOneOutPack(
        pack.copyWith(
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

  Future<void> _togglePackActive(OddOneOutPack pack) async {
    try {
      await widget.firestoreService.updateCurrentOddOneOutPack(
        pack.copyWith(active: !pack.active, updatedAt: DateTime.now()),
      );
    } catch (error) {
      _showMessage('Could not update pack: $error');
    }
  }

  Future<void> _deletePack(OddOneOutPack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete pack?'),
            content: Text(
              'This will delete "${pack.title}" and all of its rounds.',
            ),
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
      await widget.firestoreService.deleteCurrentOddOneOutPack(pack.id);
      _showMessage('Pack deleted.');
    } catch (error) {
      _showMessage('Could not delete pack: $error');
    }
  }

  Future<void> _addRound(OddOneOutPack pack, int nextSortOrder) async {
    final draft = await showDialog<_RoundDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RoundDialog(),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentOddOneOutRound(
        packId: pack.id,
        round: OddOneOutRound(
          id: '',
          prompt: draft.prompt,
          items: draft.items,
          oddIndex: draft.oddIndex,
          sortOrder: nextSortOrder,
        ),
      );

      _showMessage('Round added.');
    } catch (error) {
      _showMessage('Could not add round: $error');
    }
  }

  Future<void> _editRound({
    required OddOneOutPack pack,
    required OddOneOutRound round,
  }) async {
    final draft = await showDialog<_RoundDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RoundDialog(round: round),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentOddOneOutRound(
        packId: pack.id,
        round: round.copyWith(
          prompt: draft.prompt,
          items: draft.items,
          oddIndex: draft.oddIndex,
        ),
      );

      _showMessage('Round updated.');
    } catch (error) {
      _showMessage('Could not update round: $error');
    }
  }

  Future<void> _deleteRound({
    required OddOneOutPack pack,
    required OddOneOutRound round,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete round?'),
            content: const Text('This round will be removed from the pack.'),
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
      await widget.firestoreService.deleteCurrentOddOneOutRound(
        packId: pack.id,
        roundId: round.id,
      );

      _showMessage('Round deleted.');
    } catch (error) {
      _showMessage('Could not delete round: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7E57C2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odd One Out Manager'),
        actions: [
          IconButton(
            tooltip: 'Create pack',
            onPressed: _createPack,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPack,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create pack'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OddOneOutPack>>(
          stream: widget.firestoreService.getCurrentOddOneOutPacks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load Odd One Out packs.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final packs = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              children: [
                _buildHeader(color),
                const SizedBox(height: 18),
                if (packs.isEmpty)
                  _buildEmptyState(color)
                else
                  ...packs.map(
                    (pack) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PackPanel(
                        pack: pack,
                        firestoreService: widget.firestoreService,
                        onEditPack: () => _editPack(pack),
                        onEditAudience: () => _editAudience(pack),
                        onToggleActive: () => _togglePackActive(pack),
                        onDeletePack: () => _deletePack(pack),
                        onAddRound:
                            (nextSortOrder) => _addRound(pack, nextSortOrder),
                        onEditRound:
                            (round) => _editRound(pack: pack, round: round),
                        onDeleteRound:
                            (round) => _deleteRound(pack: pack, round: round),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Odd One Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create icon-based packs where children find the item that does not belong.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.psychology_alt_rounded, color: color, size: 72),
            const SizedBox(height: 14),
            const Text(
              'No Odd One Out packs yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a pack, then add rounds with four icon cards and one correct odd item.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _createPack,
              style: FilledButton.styleFrom(backgroundColor: color),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create pack'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackPanel extends StatelessWidget {
  final OddOneOutPack pack;
  final FirestoreService firestoreService;
  final VoidCallback onEditPack;
  final VoidCallback onEditAudience;
  final VoidCallback onToggleActive;
  final VoidCallback onDeletePack;
  final void Function(int nextSortOrder) onAddRound;
  final void Function(OddOneOutRound round) onEditRound;
  final void Function(OddOneOutRound round) onDeleteRound;

  const _PackPanel({
    required this.pack,
    required this.firestoreService,
    required this.onEditPack,
    required this.onEditAudience,
    required this.onToggleActive,
    required this.onDeletePack,
    required this.onAddRound,
    required this.onEditRound,
    required this.onDeleteRound,
  });

  @override
  Widget build(BuildContext context) {
    final icon = appIconForKey(pack.iconName, fallbackKey: 'target');
    const color = Color(0xFF7E57C2);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: pack.active ? 1 : 0.45,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: color, size: 34),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Opacity(
                    opacity: pack.active ? 1 : 0.58,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pack.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (pack.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(pack.description),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: Icon(
                                pack.active
                                    ? Icons.check_circle_rounded
                                    : Icons.pause_circle_rounded,
                                size: 18,
                              ),
                              label: Text(pack.active ? 'Active' : 'Inactive'),
                            ),
                            Chip(
                              avatar: Icon(
                                pack.availableToAll
                                    ? Icons.groups_rounded
                                    : Icons.people_alt_rounded,
                                size: 18,
                              ),
                              label: Text(
                                pack.availableToAll
                                    ? 'Everyone'
                                    : '${pack.assignedChildIds.length} assigned',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEditPack();
                        break;
                      case 'audience':
                        onEditAudience();
                        break;
                      case 'active':
                        onToggleActive();
                        break;
                      case 'delete':
                        onDeletePack();
                        break;
                    }
                  },
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_rounded),
                            title: Text('Edit pack'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'audience',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.groups_rounded),
                            title: Text('Audience'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'active',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              pack.active
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_rounded,
                            ),
                            title: Text(
                              pack.active ? 'Set inactive' : 'Set active',
                            ),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                            title: Text('Delete pack'),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEditPack,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit pack'),
                ),
                OutlinedButton.icon(
                  onPressed: onEditAudience,
                  icon: const Icon(Icons.groups_rounded),
                  label: Text(
                    pack.availableToAll
                        ? 'Available to everyone'
                        : '${pack.assignedChildIds.length} selected',
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onToggleActive,
                  icon: Icon(
                    pack.active
                        ? Icons.pause_circle_rounded
                        : Icons.play_circle_rounded,
                  ),
                  label: Text(pack.active ? 'Set inactive' : 'Set active'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<OddOneOutRound>>(
              stream: firestoreService.getCurrentOddOneOutRounds(pack.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load rounds.');
                }

                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final rounds = snapshot.data!;
                final nextSortOrder =
                    rounds.isEmpty
                        ? 0
                        : rounds
                                .map((round) => round.sortOrder)
                                .reduce((a, b) => a > b ? a : b) +
                            1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Rounds',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => onAddRound(nextSortOrder),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add round'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (rounds.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'No rounds yet. Add the first round for this pack.',
                        ),
                      )
                    else
                      ...rounds.map(
                        (round) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RoundTile(
                            round: round,
                            onEdit: () => onEditRound(round),
                            onDelete: () => onDeleteRound(round),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  final OddOneOutRound round;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoundTile({
    required this.round,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final oddItem =
        round.items.length > round.oddIndex && round.oddIndex >= 0
            ? round.items[round.oddIndex]
            : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7E57C2).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          if (oddItem != null)
            CircleAvatar(
              backgroundColor: const Color(0xFF7E57C2).withValues(alpha: 0.14),
              child: Icon(
                appIconForKey(oddItem.iconName, fallbackKey: 'target'),
                color: const Color(0xFF7E57C2),
              ),
            )
          else
            const CircleAvatar(child: Icon(Icons.help_outline_rounded)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  round.prompt.trim().isEmpty
                      ? 'Find the odd one out'
                      : round.prompt,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  oddItem == null
                      ? 'Odd item not set'
                      : 'Odd item: ${oddItem.label}',
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _PackDialog extends StatefulWidget {
  final OddOneOutPack? pack;

  const _PackDialog({this.pack});

  @override
  State<_PackDialog> createState() => _PackDialogState();
}

class _PackDialogState extends State<_PackDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _iconName;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.pack?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.pack?.description ?? '',
    );
    _iconName = appIconKeyFor(widget.pack?.iconName ?? 'target');
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
      title: 'Choose pack icon',
      categories: const [
        AppIconCategory.learning,
        AppIconCategory.play,
        AppIconCategory.animals,
        AppIconCategory.food,
        AppIconCategory.feelings,
        AppIconCategory.dailyLife,
        AppIconCategory.nature,
        AppIconCategory.objects,
      ],
    );

    if (selected == null) return;

    setState(() {
      _iconName = selected.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.pack != null;
    final option = appIconOptionForKey(_iconName);

    return AlertDialog(
      title: Text(editing ? 'Edit pack' : 'Create Odd One Out pack'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Pack title',
                  hintText: 'Example: Food and animals',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Short description for staff.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _chooseIcon,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF7E57C2,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          option.icon,
                          color: const Color(0xFF7E57C2),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text('Choose an icon'),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_rounded, color: Color(0xFF7E57C2)),
                    ],
                  ),
                ),
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
          onPressed: () {
            final title = _titleController.text.trim();

            if (title.isEmpty) return;

            Navigator.pop(
              context,
              _PackDraft(
                title: title,
                description: _descriptionController.text.trim(),
                iconName: _iconName,
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: Text(editing ? context.l10n.save : 'Create'),
        ),
      ],
    );
  }
}

class _AudienceDialog extends StatefulWidget {
  final OddOneOutPack pack;
  final List<ChildProfile> children;

  const _AudienceDialog({required this.pack, required this.children});

  @override
  State<_AudienceDialog> createState() => _AudienceDialogState();
}

class _AudienceDialogState extends State<_AudienceDialog> {
  late bool _availableToAll;
  late Set<String> _selectedChildIds;

  @override
  void initState() {
    super.initState();

    _availableToAll = widget.pack.availableToAll;
    _selectedChildIds = widget.pack.assignedChildIds.toSet();
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
                    onSelected: (_) {
                      setState(() {
                        _availableToAll = false;
                      });
                    },
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

class _RoundDialog extends StatefulWidget {
  final OddOneOutRound? round;

  const _RoundDialog({this.round});

  @override
  State<_RoundDialog> createState() => _RoundDialogState();
}

class _RoundDialogState extends State<_RoundDialog> {
  late final TextEditingController _promptController;
  late final List<TextEditingController> _labelControllers;
  late List<String> _iconNames;
  late int _oddIndex;

  @override
  void initState() {
    super.initState();

    final round = widget.round;

    _promptController = TextEditingController(text: round?.prompt ?? '');

    final initialItems =
        round?.items.length == 4
            ? round!.items
            : const [
              OddOneOutItem(label: '', iconName: 'apple'),
              OddOneOutItem(label: '', iconName: 'carrot'),
              OddOneOutItem(label: '', iconName: 'pizza'),
              OddOneOutItem(label: '', iconName: 'bus'),
            ];

    _labelControllers =
        initialItems
            .map((item) => TextEditingController(text: item.label))
            .toList();

    _iconNames =
        initialItems.map((item) => appIconKeyFor(item.iconName)).toList();

    _oddIndex = round?.oddIndex.clamp(0, 3) ?? 3;
  }

  @override
  void dispose() {
    _promptController.dispose();
    for (final controller in _labelControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _chooseIcon(int index) async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _iconNames[index],
      title: 'Choose item icon',
    );

    if (selected == null) return;

    setState(() {
      _iconNames[index] = selected.key;
    });
  }

  void _save() {
    final items = <OddOneOutItem>[];

    for (var index = 0; index < 4; index++) {
      final label = _labelControllers[index].text.trim();

      if (label.isEmpty) return;

      items.add(
        OddOneOutItem(label: label, iconName: appIconKeyFor(_iconNames[index])),
      );
    }

    Navigator.pop(
      context,
      _RoundDraft(
        prompt: _promptController.text.trim(),
        items: items,
        oddIndex: _oddIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.round != null;

    return AlertDialog(
      title: Text(editing ? 'Edit round' : 'Add round'),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Prompt',
                  hintText: 'Example: Which one is not food?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoundItemEditor(
                    index: index,
                    labelController: _labelControllers[index],
                    iconName: _iconNames[index],
                    isOdd: _oddIndex == index,
                    onChooseIcon: () => _chooseIcon(index),
                    onSetOdd: () {
                      setState(() {
                        _oddIndex = index;
                      });
                    },
                  ),
                );
              }),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Mark the one correct odd item. The other three should belong together.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
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
          label: Text(editing ? context.l10n.save : 'Add round'),
        ),
      ],
    );
  }
}

class _RoundItemEditor extends StatelessWidget {
  final int index;
  final TextEditingController labelController;
  final String iconName;
  final bool isOdd;
  final VoidCallback onChooseIcon;
  final VoidCallback onSetOdd;

  const _RoundItemEditor({
    required this.index,
    required this.labelController,
    required this.iconName,
    required this.isOdd,
    required this.onChooseIcon,
    required this.onSetOdd,
  });

  @override
  Widget build(BuildContext context) {
    final option = appIconOptionForKey(iconName);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isOdd
                ? Colors.orange.shade50
                : const Color(0xFF7E57C2).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isOdd
                  ? Colors.orange.shade300
                  : const Color(0xFF7E57C2).withValues(alpha: 0.14),
          width: isOdd ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onChooseIcon,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF7E57C2).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                option.icon,
                color: const Color(0xFF7E57C2),
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: labelController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Item ${index + 1}',
                hintText: option.label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ChoiceChip(
            selected: isOdd,
            avatar: Icon(
              isOdd ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            ),
            label: const Text('Odd'),
            onSelected: (_) => onSetOdd(),
          ),
        ],
      ),
    );
  }
}

class _PackDraft {
  final String title;
  final String description;
  final String iconName;

  const _PackDraft({
    required this.title,
    required this.description,
    required this.iconName,
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

class _RoundDraft {
  final String prompt;
  final List<OddOneOutItem> items;
  final int oddIndex;

  const _RoundDraft({
    required this.prompt,
    required this.items,
    required this.oddIndex,
  });
}
