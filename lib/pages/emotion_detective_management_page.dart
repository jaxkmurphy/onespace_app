import 'package:flutter/material.dart';
import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/emotion_detective_models.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';

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
              'This will delete "${pack.title}" and all of its scenarios.',
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

  Future<void> _addScenario(
    EmotionDetectivePack pack,
    int nextSortOrder,
  ) async {
    final draft = await showDialog<_ScenarioDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ScenarioDialog(),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.addCurrentEmotionDetectiveScenario(
        packId: pack.id,
        scenario: EmotionDetectiveScenario(
          id: '',
          prompt: draft.prompt,
          iconName: draft.iconName,
          choices: draft.choices,
          correctIndex: draft.correctIndex,
          explanation: draft.explanation,
          sortOrder: nextSortOrder,
        ),
      );

      _showMessage('Scenario added.');
    } catch (error) {
      _showMessage('Could not add scenario: $error');
    }
  }

  Future<void> _editScenario({
    required EmotionDetectivePack pack,
    required EmotionDetectiveScenario scenario,
  }) async {
    final draft = await showDialog<_ScenarioDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScenarioDialog(scenario: scenario),
    );

    if (draft == null) return;

    try {
      await widget.firestoreService.updateCurrentEmotionDetectiveScenario(
        packId: pack.id,
        scenario: scenario.copyWith(
          prompt: draft.prompt,
          iconName: draft.iconName,
          choices: draft.choices,
          correctIndex: draft.correctIndex,
          explanation: draft.explanation,
        ),
      );

      _showMessage('Scenario updated.');
    } catch (error) {
      _showMessage('Could not update scenario: $error');
    }
  }

  Future<void> _deleteScenario({
    required EmotionDetectivePack pack,
    required EmotionDetectiveScenario scenario,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete scenario?'),
            content: const Text('This scenario will be removed from the pack.'),
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

      _showMessage('Scenario deleted.');
    } catch (error) {
      _showMessage('Could not delete scenario: $error');
    }
  }

  void _openPack(EmotionDetectivePack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: Text(pack.title)),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                children: [
                  _PackPanel(
                    pack: pack,
                    firestoreService: widget.firestoreService,
                    onEditPack: () => _editPack(pack),
                    onEditAudience: () => _editAudience(pack),
                    onToggleActive: () => _togglePackActive(pack),
                    onDeletePack: () {
                      Navigator.pop(context);
                      _deletePack(pack);
                    },
                    onAddScenario:
                        (nextSortOrder) => _addScenario(pack, nextSortOrder),
                    onEditScenario:
                        (scenario) =>
                            _editScenario(pack: pack, scenario: scenario),
                    onDeleteScenario:
                        (scenario) =>
                            _deleteScenario(pack: pack, scenario: scenario),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEC6F91);
    final text = LearningGameLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(text.emotionDetective),
        actions: [
          IconButton(
            tooltip: text.createPack,
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
        label: Text(text.createPack),
      ),
      body: SafeArea(
        child: StreamBuilder<List<EmotionDetectivePack>>(
          stream: widget.firestoreService.getCurrentEmotionDetectivePacks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(text.couldNotLoadPacks));
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
                        color: color,
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

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFF7E57C2)],
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
              Icons.manage_search_rounded,
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
                  'Emotion Detective',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create gentle social-emotional scenarios where children think about how someone might feel.',
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
            Icon(Icons.manage_search_rounded, color: color, size: 72),
            const SizedBox(height: 14),
            const Text(
              'No Emotion Detective packs yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a pack, then add scenarios with four possible feelings and one best-fit answer.',
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
                      ? 'Feelings and social reasoning pack'
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

class _PackPanel extends StatelessWidget {
  final EmotionDetectivePack pack;
  final FirestoreService firestoreService;
  final VoidCallback onEditPack;
  final VoidCallback onEditAudience;
  final VoidCallback onToggleActive;
  final VoidCallback onDeletePack;
  final void Function(int nextSortOrder) onAddScenario;
  final void Function(EmotionDetectiveScenario scenario) onEditScenario;
  final void Function(EmotionDetectiveScenario scenario) onDeleteScenario;

  const _PackPanel({
    required this.pack,
    required this.firestoreService,
    required this.onEditPack,
    required this.onEditAudience,
    required this.onToggleActive,
    required this.onDeletePack,
    required this.onAddScenario,
    required this.onEditScenario,
    required this.onDeleteScenario,
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
            StreamBuilder<List<EmotionDetectiveScenario>>(
              stream: firestoreService.getCurrentEmotionDetectiveScenarios(
                pack.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Could not load scenarios.');
                }

                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final scenarios = snapshot.data!;
                final nextSortOrder =
                    scenarios.isEmpty
                        ? 0
                        : scenarios
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
                            '${scenarios.length} scenario${scenarios.length == 1 ? '' : 's'}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => onAddScenario(nextSortOrder),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add scenario'),
                        ),
                      ],
                    ),
                    if (scenarios.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'No scenarios yet. Add a situation, four feelings, and the best-fit answer.',
                        ),
                      )
                    else
                      ...scenarios.map(
                        (scenario) => _ScenarioTile(
                          scenario: scenario,
                          onEdit: () => onEditScenario(scenario),
                          onDelete: () => onDeleteScenario(scenario),
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

class _ScenarioTile extends StatelessWidget {
  final EmotionDetectiveScenario scenario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScenarioTile({
    required this.scenario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final correctChoice =
        scenario.correctIndex >= 0 &&
                scenario.correctIndex < scenario.choices.length
            ? scenario.choices[scenario.correctIndex]
            : null;

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
              appIconForKey(scenario.iconName, fallbackKey: 'mood_smile'),
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
                if (correctChoice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Best fit: ${correctChoice.label}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit scenario',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete scenario',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
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

class _ScenarioDialog extends StatefulWidget {
  final EmotionDetectiveScenario? scenario;

  const _ScenarioDialog({this.scenario});

  @override
  State<_ScenarioDialog> createState() => _ScenarioDialogState();
}

class _ScenarioDialogState extends State<_ScenarioDialog> {
  late final TextEditingController _promptController;
  late final TextEditingController _explanationController;
  late final List<TextEditingController> _choiceControllers;
  late List<String> _choiceIconNames;
  late String _scenarioIconName;
  late int _correctIndex;

  @override
  void initState() {
    super.initState();

    final scenario = widget.scenario;

    _promptController = TextEditingController(text: scenario?.prompt ?? '');
    _explanationController = TextEditingController(
      text: scenario?.explanation ?? '',
    );
    _scenarioIconName = scenario?.iconName ?? 'mood_smile';
    _correctIndex = scenario?.correctIndex ?? 0;

    final defaultChoices = const [
      EmotionChoice(label: 'Happy', iconName: 'mood_smile'),
      EmotionChoice(label: 'Sad', iconName: 'mood_sad'),
      EmotionChoice(label: 'Angry', iconName: 'mood_angry'),
      EmotionChoice(label: 'Worried', iconName: 'mood_worried'),
    ];

    final sourceChoices =
        scenario != null && scenario.choices.length == 4
            ? scenario.choices
            : defaultChoices;

    _choiceControllers = List.generate(
      4,
      (index) => TextEditingController(text: sourceChoices[index].label),
    );
    _choiceIconNames = List.generate(
      4,
      (index) => sourceChoices[index].iconName,
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _explanationController.dispose();

    for (final controller in _choiceControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _chooseScenarioIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _scenarioIconName,
      title: 'Choose scenario icon',
    );

    if (selected == null) return;

    setState(() {
      _scenarioIconName = selected.key;
    });
  }

  Future<void> _chooseChoiceIcon(int index) async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _choiceIconNames[index],
      title: 'Choose feeling icon',
    );

    if (selected == null) return;

    setState(() {
      _choiceIconNames[index] = selected.key;
    });
  }

  void _save() {
    final prompt = _promptController.text.trim();
    final explanation = _explanationController.text.trim();

    final choices = List.generate(4, (index) {
      return EmotionChoice(
        label: _choiceControllers[index].text.trim(),
        iconName: _choiceIconNames[index],
      );
    });

    if (prompt.isEmpty) return;
    if (choices.any((choice) => choice.label.isEmpty)) return;

    Navigator.pop(
      context,
      _ScenarioDraft(
        prompt: prompt,
        iconName: _scenarioIconName,
        choices: choices,
        correctIndex: _correctIndex,
        explanation: explanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.scenario != null;

    return AlertDialog(
      title: Text(editing ? 'Edit scenario' : 'Add scenario'),
      content: SizedBox(
        width: 620,
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
                onPressed: _chooseScenarioIcon,
                icon: AppIconPreview(iconKey: _scenarioIconName),
                label: const Text('Choose situation icon'),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Feeling choices',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                final selected = _correctIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? const Color(0xFFEC6F91).withValues(alpha: 0.08)
                              : Colors.grey.shade50,
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
                            setState(() => _correctIndex = index);
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
                          onPressed: () => _chooseChoiceIcon(index),
                          icon: AppIconPreview(
                            iconKey: _choiceIconNames[index],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _choiceControllers[index],
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
              const SizedBox(height: 12),
              TextField(
                controller: _explanationController,
                decoration: const InputDecoration(
                  labelText: 'Gentle explanation',
                  hintText:
                      'Example: They might feel sad because the toy is missing.',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: choose the best-fit answer, but keep the explanation gentle. Emotions can be flexible.',
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

class _ScenarioDraft {
  final String prompt;
  final String iconName;
  final List<EmotionChoice> choices;
  final int correctIndex;
  final String explanation;

  const _ScenarioDraft({
    required this.prompt,
    required this.iconName,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
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
