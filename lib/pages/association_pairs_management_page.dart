import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/association_pair_pack_models.dart';
import '../models/child_profile.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';
import '../widgets/media_asset_picker_dialog.dart';

class AssociationPairsManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const AssociationPairsManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<AssociationPairsManagementPage> createState() =>
      _AssociationPairsManagementPageState();
}

class _AssociationPairsManagementPageState
    extends State<AssociationPairsManagementPage> {
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _createPack() async {
    final text = LearningGameLocalizations.of(context);
    final draft = await showDialog<_PackDraft>(
      context: context,
      builder: (_) => const _PackDialog(),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentAssociationPairPack(
        ManagedAssociationPairPack(
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
      _showMessage(
        text.isIrish
            ? 'Cruthaíodh pacáiste Péirí Ceangailte.'
            : 'Association Pairs pack created.',
      );
    } catch (error) {
      _showMessage(
        text.isIrish
            ? 'Níorbh fhéidir an pacáiste a chruthú: $error'
            : 'Could not create pack: $error',
      );
    }
  }

  Future<void> _deletePack(ManagedAssociationPairPack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              LearningGameLocalizations.of(context).deletePackQuestion,
            ),
            content: Text('This will delete "${pack.title}" and its pairs.'),
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
      await widget.firestoreService.deleteCurrentAssociationPairPack(pack.id);
      _showMessage('Pack deleted.');
    } catch (error) {
      _showMessage('Could not delete pack: $error');
    }
  }

  void _openPack(ManagedAssociationPairPack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AssociationPairPackEditorPage(
              pack: pack,
              staffProfile: widget.staffProfile,
              firestoreService: widget.firestoreService,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7E57C2);
    final text = LearningGameLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(text.associationPairs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPack,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(text.createPack),
      ),
      body: StreamBuilder<List<ManagedAssociationPairPack>>(
        stream: widget.firestoreService.getCurrentAssociationPairPacks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(text.couldNotLoadPacks));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packs = snapshot.data!;

          if (packs.isEmpty) {
            return _EmptyState(
              icon: Icons.extension_rounded,
              title:
                  text.isIrish
                      ? 'Níl aon phacáiste Péirí Ceangailte fós'
                      : 'No Association Pairs packs yet',
              subtitle:
                  text.isIrish
                      ? 'Cruthaigh pacáiste, ansin cuir péirí rudaí a théann le chéile leis.'
                      : 'Create a pack, then add pairs of things that belong together.',
              buttonLabel: text.createPack,
              color: color,
              onPressed: _createPack,
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F4FF), Color(0xFFFFF7F4)],
              ),
            ),
            child: GridView.builder(
              key: const PageStorageKey('association-pairs-management-packs'),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 430,
                mainAxisExtent: 315,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: packs.length,
              itemBuilder: (context, index) {
                final pack = packs[index];

                return _PackCard(
                  pack: pack,
                  color: color,
                  onOpen: () => _openPack(pack),
                  onDelete: () => _deletePack(pack),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AssociationPairPackEditorPage extends StatefulWidget {
  final ManagedAssociationPairPack pack;
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const AssociationPairPackEditorPage({
    super.key,
    required this.pack,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<AssociationPairPackEditorPage> createState() =>
      _AssociationPairPackEditorPageState();
}

class _AssociationPairPackEditorPageState
    extends State<AssociationPairPackEditorPage> {
  late ManagedAssociationPairPack _pack;

  @override
  void initState() {
    super.initState();
    _pack = widget.pack;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _editPack() async {
    final draft = await showDialog<_PackDraft>(
      context: context,
      builder: (_) => _PackDialog(pack: _pack),
    );

    if (draft == null) return;

    final updated = _pack.copyWith(
      title: draft.title,
      description: draft.description,
      iconName: draft.iconName,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentAssociationPairPack(updated);
      setState(() => _pack = updated);
      _showMessage('Pack updated.');
    } catch (error) {
      _showMessage('Could not update pack: $error');
    }
  }

  Future<void> _editAudience() async {
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
      builder: (_) => _AudienceDialog(pack: _pack, children: children),
    );

    if (draft == null) return;

    final updated = _pack.copyWith(
      availableToAll: draft.availableToAll,
      assignedChildIds:
          draft.availableToAll ? const [] : draft.selectedChildIds,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentAssociationPairPack(updated);
      setState(() => _pack = updated);
      _showMessage('Audience updated.');
    } catch (error) {
      _showMessage('Could not update audience: $error');
    }
  }

  Future<void> _toggleActive() async {
    final updated = _pack.copyWith(
      active: !_pack.active,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentAssociationPairPack(updated);
      setState(() => _pack = updated);
    } catch (error) {
      _showMessage('Could not update pack: $error');
    }
  }

  Future<void> _addPair(int nextSortOrder) async {
    final draft = await showDialog<_PairDraft>(
      context: context,
      builder: (_) => _PairDialog(firestoreService: widget.firestoreService),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentAssociationPair(
        packId: _pack.id,
        pair: ManagedAssociationPair(
          id: '',
          first: draft.first,
          second: draft.second,
          sortOrder: nextSortOrder,
        ),
      );
      _showMessage('Pair added.');
    } catch (error) {
      _showMessage('Could not add pair: $error');
    }
  }

  Future<void> _editPair(ManagedAssociationPair pair) async {
    final draft = await showDialog<_PairDraft>(
      context: context,
      builder:
          (_) => _PairDialog(
            firestoreService: widget.firestoreService,
            pair: pair,
          ),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentAssociationPair(
        packId: _pack.id,
        pair: pair.copyWith(first: draft.first, second: draft.second),
      );
      _showMessage('Pair updated.');
    } catch (error) {
      _showMessage('Could not update pair: $error');
    }
  }

  Future<void> _deletePair(ManagedAssociationPair pair) async {
    try {
      await widget.firestoreService.deleteCurrentAssociationPair(
        packId: _pack.id,
        pairId: pair.id,
      );
      _showMessage('Pair deleted.');
    } catch (error) {
      _showMessage('Could not delete pair: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7E57C2);

    return Scaffold(
      appBar: AppBar(title: Text(_pack.title)),
      body: StreamBuilder<List<ManagedAssociationPair>>(
        stream: widget.firestoreService.getCurrentAssociationPairs(_pack.id),
        builder: (context, snapshot) {
          final pairs = snapshot.data ?? const <ManagedAssociationPair>[];
          final nextSortOrder =
              pairs.isEmpty
                  ? 0
                  : pairs
                          .map((pair) => pair.sortOrder)
                          .reduce((a, b) => a > b ? a : b) +
                      1;

          return ListView(
            key: PageStorageKey('association-pair-pack-editor-${_pack.id}'),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              _EditorHeader(
                title: _pack.title,
                description: _pack.description,
                iconName: _pack.iconName,
                color: color,
                active: _pack.active,
                audienceLabel:
                    _pack.availableToAll
                        ? 'Everyone'
                        : '${_pack.assignedChildIds.length} selected',
                onEdit: _editPack,
                onAudience: _editAudience,
                onToggleActive: _toggleActive,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${pairs.length} pair${pairs.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _addPair(nextSortOrder),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add pair'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.hasError)
                const Text('Could not load pairs.')
              else if (!snapshot.hasData)
                const Center(child: CircularProgressIndicator())
              else if (pairs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Text(
                      'No pairs yet. Add two items that belong together.',
                    ),
                  ),
                )
              else
                ...pairs.map(
                  (pair) => _PairTile(
                    pair: pair,
                    onEdit: () => _editPair(pair),
                    onDelete: () => _deletePair(pair),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final ManagedAssociationPairPack pack;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _PackCard({
    required this.pack,
    required this.color,
    required this.onOpen,
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
      child: InkWell(
        onTap: onOpen,
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
                  appIconForKey(pack.iconName, fallbackKey: 'puzzle'),
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
                            pack.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder:
                              (context) => [
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
                      pack.description.isEmpty
                          ? 'Association pair pack'
                          : pack.description,
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
                          icon:
                              pack.active
                                  ? Icons.check_circle_rounded
                                  : Icons.pause_circle_rounded,
                          label: pack.active ? 'Active' : 'Inactive',
                          color: color,
                        ),
                        _GamePackChip(
                          icon:
                              pack.availableToAll
                                  ? Icons.groups_rounded
                                  : Icons.people_alt_rounded,
                          label:
                              pack.availableToAll
                                  ? context.l10n.availableToEveryone
                                  : context.l10n.assignedChildCount(
                                    pack.assignedChildIds.length,
                                  ),
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.createdBy(pack.createdByStaffName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(backgroundColor: color),
                        icon: const Icon(Icons.edit_rounded),
                        label: Text(context.l10n.edit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _EditorHeader extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final Color color;
  final bool active;
  final String audienceLabel;
  final VoidCallback onEdit;
  final VoidCallback onAudience;
  final VoidCallback onToggleActive;

  const _EditorHeader({
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
    required this.active,
    required this.audienceLabel,
    required this.onEdit,
    required this.onAudience,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFFFFB199)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  appIconForKey(iconName, fallbackKey: 'puzzle'),
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Colors.white)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit pack'),
              ),
              FilledButton.tonalIcon(
                onPressed: onAudience,
                icon: const Icon(Icons.groups_rounded),
                label: Text(audienceLabel),
              ),
              FilledButton.tonalIcon(
                onPressed: onToggleActive,
                icon: Icon(
                  active
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                ),
                label: Text(active ? 'Set inactive' : 'Set active'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PairTile extends StatelessWidget {
  final ManagedAssociationPair pair;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PairTile({
    required this.pair,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading:
            isMediaVisualValue(pair.first.iconName)
                ? MediaImagePreview(value: pair.first.iconName, size: 32)
                : Icon(appIconForKey(pair.first.iconName)),
        title: Text('${pair.first.label}  +  ${pair.second.label}'),
        subtitle: Text(
          isMediaVisualValue(pair.first.iconName) ||
                  isMediaVisualValue(pair.second.iconName)
              ? 'Custom media/image pair'
              : '${pair.first.iconName} / ${pair.second.iconName}',
        ),
        trailing: Wrap(
          children: [
            IconButton(
              tooltip: 'Edit pair',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: 'Delete pair',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackDialog extends StatefulWidget {
  final ManagedAssociationPairPack? pack;

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
    _iconName = widget.pack?.iconName ?? 'puzzle';
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
    );

    if (selected == null) return;
    setState(() => _iconName = selected.key);
  }

  void _save() {
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pack == null ? 'Create pack' : 'Edit pack'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Pack name'),
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

class _PairDialog extends StatefulWidget {
  final FirestoreService firestoreService;
  final ManagedAssociationPair? pair;

  const _PairDialog({required this.firestoreService, this.pair});

  @override
  State<_PairDialog> createState() => _PairDialogState();
}

class _PairDialogState extends State<_PairDialog> {
  late final TextEditingController _firstController;
  late final TextEditingController _secondController;
  late String _firstIcon;
  late String _secondIcon;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController(
      text: widget.pair?.first.label ?? '',
    );
    _secondController = TextEditingController(
      text: widget.pair?.second.label ?? '',
    );
    _firstIcon = widget.pair?.first.iconName ?? 'star';
    _secondIcon = widget.pair?.second.iconName ?? 'heart';
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  Future<void> _chooseIcon({required bool first}) async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: first ? _firstIcon : _secondIcon,
      title: first ? 'Choose first icon' : 'Choose second icon',
    );

    if (selected == null) return;

    setState(() {
      if (first) {
        _firstIcon = selected.key;
      } else {
        _secondIcon = selected.key;
      }
    });
  }

  Future<void> _chooseMedia({required bool first}) async {
    final selected = await showMediaAssetPickerDialog(
      context: context,
      firestoreService: widget.firestoreService,
      type: MediaAssetType.image,
      title: first ? 'Choose first image' : 'Choose matching image',
    );

    if (selected == null) return;

    setState(() {
      final value = mediaVisualValue(selected);
      if (first) {
        _firstIcon = value;
      } else {
        _secondIcon = value;
      }
    });
  }

  void _save() {
    final firstLabel = _firstController.text.trim();
    final secondLabel = _secondController.text.trim();
    if (firstLabel.isEmpty || secondLabel.isEmpty) return;

    Navigator.pop(
      context,
      _PairDraft(
        first: ManagedAssociationPairItem(
          label: firstLabel,
          iconName: _firstIcon,
        ),
        second: ManagedAssociationPairItem(
          label: secondLabel,
          iconName: _secondIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pair == null ? 'Add pair' : 'Edit pair'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PairItemField(
              controller: _firstController,
              iconName: _firstIcon,
              label: 'First item',
              onChooseIcon: () => _chooseIcon(first: true),
              onChooseMedia: () => _chooseMedia(first: true),
            ),
            const SizedBox(height: 14),
            _PairItemField(
              controller: _secondController,
              iconName: _secondIcon,
              label: 'Matching item',
              onChooseIcon: () => _chooseIcon(first: false),
              onChooseMedia: () => _chooseMedia(first: false),
            ),
          ],
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

class _PairItemField extends StatelessWidget {
  final TextEditingController controller;
  final String iconName;
  final String label;
  final VoidCallback onChooseIcon;
  final VoidCallback onChooseMedia;

  const _PairItemField({
    required this.controller,
    required this.iconName,
    required this.label,
    required this.onChooseIcon,
    required this.onChooseMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onChooseIcon,
          icon:
              isMediaVisualValue(iconName)
                  ? MediaImagePreview(value: iconName, size: 24)
                  : AppIconPreview(iconKey: iconName),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: 'Choose media image',
          onPressed: onChooseMedia,
          icon: const Icon(Icons.photo_library_outlined),
        ),
      ],
    );
  }
}

class _AudienceDialog extends StatefulWidget {
  final ManagedAssociationPairPack pack;
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
                      setState(() => _availableToAll = false);
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
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color color;
  final VoidCallback onPressed;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 78, color: color),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonLabel),
            ),
          ],
        ),
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

class _PairDraft {
  final ManagedAssociationPairItem first;
  final ManagedAssociationPairItem second;

  const _PairDraft({required this.first, required this.second});
}

class _AudienceDraft {
  final bool availableToAll;
  final List<String> selectedChildIds;

  const _AudienceDraft({
    required this.availableToAll,
    required this.selectedChildIds,
  });
}
