import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/emotion_detective_models.dart';
import '../models/media_asset.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';
import '../widgets/media_asset_picker_dialog.dart';

class EmotionDetectiveManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const EmotionDetectiveManagementPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<EmotionDetectiveManagementPage> createState() =>
      _EmotionDetectiveManagementPageState();
}

class _EmotionDetectiveManagementPageState
    extends State<EmotionDetectiveManagementPage> {
  static const _color = Color(0xFFEC6F91);

  LearningGameLocalizations get _text => LearningGameLocalizations.of(context);

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
      await widget.firestoreService.addCurrentEmotionDetectivePack(
        EmotionDetectivePack(
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

      _showMessage('Emotion Detective pack created.');
    } catch (error) {
      _showMessage('Could not create pack: $error');
    }
  }

  Future<void> _editPack(EmotionDetectivePack pack) async {
    final draft = await showDialog<_PackDraft>(
      context: context,
      builder: (_) => _PackDialog(pack: pack),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentEmotionDetectivePack(
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

  Future<void> _editAudience(EmotionDetectivePack pack) async {
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
      await widget.firestoreService.updateCurrentEmotionDetectivePack(
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

  Future<void> _togglePackActive(EmotionDetectivePack pack) async {
    try {
      await widget.firestoreService.updateCurrentEmotionDetectivePack(
        pack.copyWith(active: !pack.active, updatedAt: DateTime.now()),
      );
    } catch (error) {
      _showMessage('Could not update pack: $error');
    }
  }

  Future<void> _deletePack(EmotionDetectivePack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete pack?'),
            content: Text(
              'This will delete "${pack.title}" and all of its cases.',
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
      await widget.firestoreService.deleteCurrentEmotionDetectivePack(pack.id);
      _showMessage('Pack deleted.');
    } catch (error) {
      _showMessage('Could not delete pack: $error');
    }
  }

  Future<void> _addCase(EmotionDetectivePack pack, int nextSortOrder) async {
    final draft = await showDialog<_CaseDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CaseDialog(firestoreService: widget.firestoreService),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentEmotionDetectiveScenario(
        packId: pack.id,
        scenario: draft.toScenario(id: '', sortOrder: nextSortOrder),
      );

      _showMessage('Case added.');
    } catch (error) {
      _showMessage('Could not add case: $error');
    }
  }

  Future<void> _editCase({
    required EmotionDetectivePack pack,
    required EmotionDetectiveScenario scenario,
  }) async {
    final draft = await showDialog<_CaseDraft>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _CaseDialog(
            firestoreService: widget.firestoreService,
            scenario: scenario,
          ),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentEmotionDetectiveScenario(
        packId: pack.id,
        scenario: draft.toScenario(
          id: scenario.id,
          sortOrder: scenario.sortOrder,
        ),
      );

      _showMessage('Case updated.');
    } catch (error) {
      _showMessage('Could not update case: $error');
    }
  }

  Future<void> _deleteCase({
    required EmotionDetectivePack pack,
    required EmotionDetectiveScenario scenario,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete case?'),
            content: const Text('This case will be removed from the pack.'),
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
      await widget.firestoreService.deleteCurrentEmotionDetectiveScenario(
        packId: pack.id,
        scenarioId: scenario.id,
      );

      _showMessage('Case deleted.');
    } catch (error) {
      _showMessage('Could not delete case: $error');
    }
  }

  void _openPack(EmotionDetectivePack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _EmotionDetectivePackEditorPage(
              pack: pack,
              firestoreService: widget.firestoreService,
              onEditPack: () => _editPack(pack),
              onEditAudience: () => _editAudience(pack),
              onToggleActive: () => _togglePackActive(pack),
              onDeletePack: () {
                Navigator.pop(context);
                _deletePack(pack);
              },
              onAddCase: (nextSortOrder) => _addCase(pack, nextSortOrder),
              onEditCase:
                  (scenario) => _editCase(pack: pack, scenario: scenario),
              onDeleteCase:
                  (scenario) => _deleteCase(pack: pack, scenario: scenario),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_text.emotionDetective),
        actions: [
          IconButton(
            tooltip: _text.createPack,
            onPressed: _createPack,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPack,
        backgroundColor: _color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(_text.createPack),
      ),
      body: SafeArea(
        child: StreamBuilder<List<EmotionDetectivePack>>(
          stream: widget.firestoreService.getCurrentEmotionDetectivePacks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(_text.couldNotLoadPacks));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final packs = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                if (packs.isEmpty)
                  _buildEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 430,
                          mainAxisExtent: 250,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: packs.length,
                    itemBuilder: (context, index) {
                      final pack = packs[index];

                      return _PackSummaryCard(
                        pack: pack,
                        color: _color,
                        onOpen: () => _openPack(pack),
                        onDelete: () => _deletePack(pack),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_color, Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          _HeaderIcon(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emotion Detective',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create social-emotional cases where children identify a feeling, spot a body clue, and choose a helpful action.',
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

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.manage_search_rounded, color: _color, size: 72),
            const SizedBox(height: 14),
            const Text(
              'No Emotion Detective packs yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a pack, then add cases with feelings, body clues, and helpful actions.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _createPack,
              style: FilledButton.styleFrom(backgroundColor: _color),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create pack'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.manage_search_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }
}

class _PackSummaryCard extends StatelessWidget {
  final EmotionDetectivePack pack;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _PackSummaryCard({
    required this.pack,
    required this.color,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      appIconForKey(pack.iconName, fallbackKey: 'mood_smile'),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Delete pack',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                pack.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  pack.description.isEmpty
                      ? 'Social-emotional case pack'
                      : pack.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(pack.active ? 'Active' : 'Inactive')),
                  Chip(
                    label: Text(
                      pack.availableToAll
                          ? 'Everyone'
                          : '${pack.assignedChildIds.length} selected',
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
}

class _EmotionDetectivePackEditorPage extends StatelessWidget {
  final EmotionDetectivePack pack;
  final FirestoreService firestoreService;
  final VoidCallback onEditPack;
  final VoidCallback onEditAudience;
  final VoidCallback onToggleActive;
  final VoidCallback onDeletePack;
  final void Function(int nextSortOrder) onAddCase;
  final void Function(EmotionDetectiveScenario scenario) onEditCase;
  final void Function(EmotionDetectiveScenario scenario) onDeleteCase;

  const _EmotionDetectivePackEditorPage({
    required this.pack,
    required this.firestoreService,
    required this.onEditPack,
    required this.onEditAudience,
    required this.onToggleActive,
    required this.onDeletePack,
    required this.onAddCase,
    required this.onEditCase,
    required this.onDeleteCase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pack.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
          children: [
            _PackPanel(
              pack: pack,
              firestoreService: firestoreService,
              onEditPack: onEditPack,
              onEditAudience: onEditAudience,
              onToggleActive: onToggleActive,
              onDeletePack: onDeletePack,
              onAddCase: onAddCase,
              onEditCase: onEditCase,
              onDeleteCase: onDeleteCase,
            ),
          ],
        ),
      ),
    );
  }
}

class _PackPanel extends StatelessWidget {
  final EmotionDetectivePack pack;
  final FirestoreService firestoreService;
  final VoidCallback onEditPack;
  final VoidCallback onEditAudience;
  final VoidCallback onToggleActive;
  final VoidCallback onDeletePack;
  final void Function(int nextSortOrder) onAddCase;
  final void Function(EmotionDetectiveScenario scenario) onEditCase;
  final void Function(EmotionDetectiveScenario scenario) onDeleteCase;

  const _PackPanel({
    required this.pack,
    required this.firestoreService,
    required this.onEditPack,
    required this.onEditAudience,
    required this.onToggleActive,
    required this.onDeletePack,
    required this.onAddCase,
    required this.onEditCase,
    required this.onDeleteCase,
  });

  @override
  Widget build(BuildContext context) {
    final icon = appIconForKey(pack.iconName, fallbackKey: 'mood_smile');
    const color = Color(0xFFEC6F91);

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
                              ),
                              label: Text(pack.active ? 'Active' : 'Inactive'),
                            ),
                            Chip(
                              avatar: const Icon(Icons.groups_rounded),
                              label: Text(
                                pack.availableToAll
                                    ? 'Everyone'
                                    : '${pack.assignedChildIds.length} selected',
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
            const SizedBox(height: 16),
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
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Text('Audience'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(
                    pack.active
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  label: Text(pack.active ? 'Set inactive' : 'Set active'),
                ),
                OutlinedButton.icon(
                  onPressed: onDeletePack,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            StreamBuilder<List<EmotionDetectiveScenario>>(
              stream: firestoreService.getCurrentEmotionDetectiveScenarios(
                pack.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load cases.');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cases = snapshot.data!;
                final nextSortOrder =
                    cases.isEmpty
                        ? 0
                        : cases
                                .map((scenario) => scenario.sortOrder)
                                .reduce((a, b) => a > b ? a : b) +
                            1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${cases.length} case${cases.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => onAddCase(nextSortOrder),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add case'),
                        ),
                      ],
                    ),
                    if (cases.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'No cases yet. Add a situation, feelings, body clues, and helpful actions.',
                        ),
                      )
                    else
                      ...cases.map(
                        (scenario) => _CaseTile(
                          scenario: scenario,
                          onEdit: () => onEditCase(scenario),
                          onDelete: () => onDeleteCase(scenario),
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

class _CaseTile extends StatelessWidget {
  final EmotionDetectiveScenario scenario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CaseTile({
    required this.scenario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final feeling = _safeCorrectChoice(
      scenario.feelingChoices,
      scenario.correctFeelingIndex,
    );
    final clue = _safeCorrectChoice(
      scenario.bodyClueChoices,
      scenario.correctBodyClueIndex,
    );
    final action = _safeCorrectChoice(
      scenario.helpfulActionChoices,
      scenario.correctHelpfulActionIndex,
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEC6F91).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              scenario.iconName.trim().isEmpty
                  ? Icons.block_rounded
                  : appIconForKey(scenario.iconName, fallbackKey: 'mood_smile'),
              color: const Color(0xFFEC6F91),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (feeling != null) 'Feeling: ${feeling.label}',
                    if (clue != null) 'Clue: ${clue.label}',
                    if (action != null) 'Help: ${action.label}',
                  ].join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit case',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete case',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  EmotionChoice? _safeCorrectChoice(List<EmotionChoice> choices, int index) {
    if (index < 0 || index >= choices.length) return null;
    return choices[index];
  }
}

class _PackDialog extends StatefulWidget {
  final EmotionDetectivePack? pack;

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
    _iconName = widget.pack?.iconName ?? 'mood_smile';
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

    setState(() {
      _iconName = selected.key;
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) return;

    Navigator.pop(
      context,
      _PackDraft(title: title, description: description, iconName: _iconName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.pack != null;

    return AlertDialog(
      title: Text(editing ? 'Edit pack' : 'Create pack'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Pack name',
                  hintText: 'Example: Playground feelings',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Short note for staff and children',
                ),
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

class _CaseDialog extends StatefulWidget {
  final FirestoreService firestoreService;
  final EmotionDetectiveScenario? scenario;

  const _CaseDialog({required this.firestoreService, this.scenario});

  @override
  State<_CaseDialog> createState() => _CaseDialogState();
}

class _CaseDialogState extends State<_CaseDialog> {
  late final TextEditingController _promptController;
  late final TextEditingController _explanationController;
  late final _ChoiceGroupControllers _feelings;
  late final _ChoiceGroupControllers _bodyClues;
  late final _ChoiceGroupControllers _helpfulActions;
  late String _caseIconName;

  @override
  void initState() {
    super.initState();

    final scenario = widget.scenario;

    _promptController = TextEditingController(text: scenario?.prompt ?? '');
    _explanationController = TextEditingController(
      text: scenario?.explanation ?? '',
    );
    _caseIconName = scenario?.iconName ?? 'mood_smile';

    _feelings = _ChoiceGroupControllers(
      choices:
          scenario != null && scenario.feelingChoices.length == 4
              ? scenario.feelingChoices
              : _defaultFeelings,
      correctIndex: scenario?.correctFeelingIndex ?? 0,
    );
    _bodyClues = _ChoiceGroupControllers(
      choices:
          scenario != null && scenario.bodyClueChoices.length == 4
              ? scenario.bodyClueChoices
              : _defaultBodyClues,
      correctIndex: scenario?.correctBodyClueIndex ?? 0,
    );
    _helpfulActions = _ChoiceGroupControllers(
      choices:
          scenario != null && scenario.helpfulActionChoices.length == 4
              ? scenario.helpfulActionChoices
              : _defaultHelpfulActions,
      correctIndex: scenario?.correctHelpfulActionIndex ?? 0,
    );
  }

  static const _defaultFeelings = [
    EmotionChoice(label: 'Happy', iconName: 'mood_smile'),
    EmotionChoice(label: 'Sad', iconName: 'mood_sad'),
    EmotionChoice(label: 'Angry', iconName: 'mood_angry'),
    EmotionChoice(label: 'Worried', iconName: 'mood_confuzed'),
  ];

  static const _defaultBodyClues = [
    EmotionChoice(label: 'Smiling', iconName: 'mood_smile'),
    EmotionChoice(label: 'Crying', iconName: 'droplet'),
    EmotionChoice(label: 'Covering ears', iconName: 'ear'),
    EmotionChoice(label: 'Looking away', iconName: 'eye'),
  ];

  static const _defaultHelpfulActions = [
    EmotionChoice(label: 'Ask a teacher', iconName: 'user'),
    EmotionChoice(label: 'Take deep breaths', iconName: 'leaf'),
    EmotionChoice(label: 'Use headphones', iconName: 'headphones'),
    EmotionChoice(label: 'Offer help', iconName: 'heart'),
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _explanationController.dispose();
    _feelings.dispose();
    _bodyClues.dispose();
    _helpfulActions.dispose();
    super.dispose();
  }

  Future<void> _chooseCaseIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _caseIconName,
      title: 'Choose situation icon',
      allowNoIcon: true,
    );

    if (selected == null) return;

    setState(() {
      _caseIconName = selected.key;
    });
  }

  Future<void> _chooseCaseMedia() async {
    final selected = await showMediaAssetPickerDialog(
      context: context,
      firestoreService: widget.firestoreService,
      type: MediaAssetType.image,
      title: 'Choose situation image',
    );

    if (selected == null) return;

    setState(() {
      _caseIconName = mediaVisualValue(selected);
    });
  }

  void _save() {
    final prompt = _promptController.text.trim();
    final explanation = _explanationController.text.trim();

    if (prompt.isEmpty) return;
    if (!_feelings.isValid || !_bodyClues.isValid || !_helpfulActions.isValid) {
      return;
    }

    Navigator.pop(
      context,
      _CaseDraft(
        prompt: prompt,
        iconName: _caseIconName,
        feelingChoices: _feelings.toChoices(),
        correctFeelingIndex: _feelings.correctIndex,
        bodyClueChoices: _bodyClues.toChoices(),
        correctBodyClueIndex: _bodyClues.correctIndex,
        helpfulActionChoices: _helpfulActions.toChoices(),
        correctHelpfulActionIndex: _helpfulActions.correctIndex,
        explanation: explanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.scenario != null;

    return AlertDialog(
      title: Text(editing ? 'Edit case' : 'Add case'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Situation',
                  hintText: 'Example: A child loses their favourite toy.',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _chooseCaseIcon,
                icon:
                    isMediaVisualValue(_caseIconName)
                        ? MediaImagePreview(value: _caseIconName, size: 24)
                        : AppIconPreview(iconKey: _caseIconName),
                label: const Text('Choose situation icon'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _chooseCaseMedia,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose situation image'),
              ),
              const SizedBox(height: 18),
              _ChoiceGroupEditor(
                title: '1. Feeling choices',
                helperText: 'Which feeling best fits this situation?',
                controllers: _feelings,
                iconPickerTitle: 'Choose feeling icon',
                firestoreService: widget.firestoreService,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              _ChoiceGroupEditor(
                title: '2. Body clue choices',
                helperText: 'What might the child notice in the body or face?',
                controllers: _bodyClues,
                iconPickerTitle: 'Choose clue icon',
                firestoreService: widget.firestoreService,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              _ChoiceGroupEditor(
                title: '3. Helpful action choices',
                helperText: 'What could help in a kind, safe way?',
                controllers: _helpfulActions,
                iconPickerTitle: 'Choose action icon',
                firestoreService: widget.firestoreService,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: 'Gentle explanation',
                  hintText:
                      'Example: They might feel sad, look down, and need help finding it.',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: these are best-fit answers, not the only possible answers. Keep the explanation gentle.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
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
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _ChoiceGroupEditor extends StatelessWidget {
  final String title;
  final String helperText;
  final _ChoiceGroupControllers controllers;
  final String iconPickerTitle;
  final FirestoreService firestoreService;
  final VoidCallback onChanged;

  const _ChoiceGroupEditor({
    required this.title,
    required this.helperText,
    required this.controllers,
    required this.iconPickerTitle,
    required this.firestoreService,
    required this.onChanged,
  });

  Future<void> _chooseIcon(BuildContext context, int index) async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: controllers.iconNames[index],
      title: iconPickerTitle,
      allowNoIcon: true,
    );

    if (selected == null) return;

    controllers.iconNames[index] = selected.key;
    onChanged();
  }

  Future<void> _chooseMedia(BuildContext context, int index) async {
    final selected = await showMediaAssetPickerDialog(
      context: context,
      firestoreService: firestoreService,
      type: MediaAssetType.image,
      title: 'Choose choice image',
    );

    if (selected == null) return;

    controllers.iconNames[index] = mediaVisualValue(selected);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(4, (index) {
            final selected = controllers.correctIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? const Color(0xFFEC6F91).withValues(alpha: 0.08)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        selected
                            ? const Color(0xFFEC6F91)
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Set as best-fit answer',
                      onPressed: () {
                        controllers.correctIndex = index;
                        onChanged();
                      },
                      icon: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color:
                            selected
                                ? const Color(0xFFEC6F91)
                                : Colors.grey.shade600,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Choose icon',
                      onPressed: () => _chooseIcon(context, index),
                      icon:
                          isMediaVisualValue(controllers.iconNames[index])
                              ? MediaImagePreview(
                                value: controllers.iconNames[index],
                                size: 24,
                              )
                              : AppIconPreview(
                                iconKey: controllers.iconNames[index],
                              ),
                    ),
                    IconButton(
                      tooltip: 'Choose media image',
                      onPressed: () => _chooseMedia(context, index),
                      icon: const Icon(Icons.photo_library_outlined),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controllers.textControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Choice ${index + 1}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AudienceDialog extends StatefulWidget {
  final EmotionDetectivePack pack;
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

class _ChoiceGroupControllers {
  final List<TextEditingController> textControllers;
  final List<String> iconNames;
  int correctIndex;

  _ChoiceGroupControllers({
    required List<EmotionChoice> choices,
    required this.correctIndex,
  }) : textControllers = List.generate(
         4,
         (index) => TextEditingController(text: choices[index].label),
       ),
       iconNames = List.generate(4, (index) => choices[index].iconName);

  bool get isValid {
    return correctIndex >= 0 &&
        correctIndex < textControllers.length &&
        textControllers.every(
          (controller) => controller.text.trim().isNotEmpty,
        );
  }

  List<EmotionChoice> toChoices() {
    return List.generate(
      4,
      (index) => EmotionChoice(
        label: textControllers[index].text.trim(),
        iconName: iconNames[index],
      ),
    );
  }

  void dispose() {
    for (final controller in textControllers) {
      controller.dispose();
    }
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

class _CaseDraft {
  final String prompt;
  final String iconName;
  final List<EmotionChoice> feelingChoices;
  final int correctFeelingIndex;
  final List<EmotionChoice> bodyClueChoices;
  final int correctBodyClueIndex;
  final List<EmotionChoice> helpfulActionChoices;
  final int correctHelpfulActionIndex;
  final String explanation;

  const _CaseDraft({
    required this.prompt,
    required this.iconName,
    required this.feelingChoices,
    required this.correctFeelingIndex,
    required this.bodyClueChoices,
    required this.correctBodyClueIndex,
    required this.helpfulActionChoices,
    required this.correctHelpfulActionIndex,
    required this.explanation,
  });

  EmotionDetectiveScenario toScenario({
    required String id,
    required int sortOrder,
  }) {
    return EmotionDetectiveScenario(
      id: id,
      prompt: prompt,
      iconName: iconName,
      feelingChoices: feelingChoices,
      correctFeelingIndex: correctFeelingIndex,
      bodyClueChoices: bodyClueChoices,
      correctBodyClueIndex: correctBodyClueIndex,
      helpfulActionChoices: helpfulActionChoices,
      correctHelpfulActionIndex: correctHelpfulActionIndex,
      explanation: explanation,
      sortOrder: sortOrder,
    );
  }
}

class _AudienceDraft {
  final bool availableToAll;
  final List<String> selectedChildIds;

  const _AudienceDraft({
    required this.availableToAll,
    required this.selectedChildIds,
  });
}
