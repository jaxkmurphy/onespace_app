import 'package:flutter/material.dart';

import '../data/word_learning_visuals.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import 'word_pack_editor_page.dart';
import 'word_progress_page.dart';

class WordLearningPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;
  final String staffId;
  final String staffName;

  const WordLearningPage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<WordLearningPage> createState() => _WordLearningPageState();
}

class _WordLearningPageState extends State<WordLearningPage> {
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _styleLabel(String key) {
    switch (key) {
      case 'school':
        return context.l10n.school;
      case 'home':
        return context.l10n.home;
      case 'animals':
        return context.l10n.animals;
      case 'feelings':
        return context.l10n.feelings;
      case 'world':
        return context.l10n.ourWorld;
      case 'fun':
        return context.l10n.fun;
      default:
        return context.l10n.words;
    }
  }

  Future<void> _createWordPack() async {
    final l10n = context.l10n;
    List<ChildProfile> children;

    try {
      children = await widget.firestoreService.getCurrentChildProfilesOnce();
    } catch (_) {
      _showMessage(l10n.noChildrenAvailable);
      return;
    }

    if (!mounted) return;

    final draft = await showDialog<_WordPackDraft>(
      context: context,
      builder:
          (_) => _WordPackDialog(children: children, styleLabel: _styleLabel),
    );

    if (draft == null) return;

    final style = wordPackStyleFor(draft.styleKey);
    final now = DateTime.now();

    final pack = WordPack(
      id: '',
      name: draft.name,
      description: draft.description,
      createdByStaffId: widget.staffId,
      createdByStaffName: widget.staffName,
      availableToAll: draft.availableToAll,
      assignedChildIds:
          draft.availableToAll ? const [] : draft.selectedChildIds,
      iconName: style.key,
      colorHex: style.colorHex,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await widget.firestoreService.addCurrentWordPack(pack);
      _showMessage(l10n.wordPackCreated);
    } catch (_) {
      _showMessage(l10n.wordPackSaveFailed);
    }
  }

  Future<void> _deletePack(WordPack pack) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteWordPack),
          content: Text(l10n.deleteWordPackMessage(pack.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentWordPack(pack.id);

      _showMessage(l10n.wordPackDeleted);
    } catch (_) {
      _showMessage(l10n.wordPackDeleteFailed);
    }
  }

  void _openPack(WordPack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => WordPackEditorPage(
              firestoreService: widget.firestoreService,
              teacherUid: widget.teacherUid,
              pack: pack,
            ),
      ),
    );
  }

  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => WordProgressPage(
              firestoreService: widget.firestoreService,
              teacherUid: widget.teacherUid,
            ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 78,
              color: Color(0xFF66BB6A),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.noWordPacks,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.createFirstWordPack, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _createWordPack,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.createWordPack),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.wordLearning),
        actions: [
          IconButton(
            tooltip: context.l10n.wordProgress,
            onPressed: _openProgress,
            icon: const Icon(Icons.insights_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createWordPack,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.createWordPack),
      ),
      body: StreamBuilder<List<WordPack>>(
        stream: widget.firestoreService.getCurrentWordPacks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _WordMessageState(
              icon: Icons.cloud_off_rounded,
              message: context.l10n.couldNotLoadWordPacks,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final packs = snapshot.data!;

          if (packs.isEmpty) {
            return _buildEmptyState();
          }

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3FFF5), Color(0xFFF7F4FF)],
              ),
            ),
            child: GridView.builder(
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

                return _WordPackCard(
                  pack: pack,
                  firestoreService: widget.firestoreService,
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

class _WordPackCard extends StatelessWidget {
  final WordPack pack;
  final FirestoreService firestoreService;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _WordPackCard({
    required this.pack,
    required this.firestoreService,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final style = wordPackStyleFor(pack.iconName);
    final color = wordPackColorFromHex(pack.colorHex);

    return StreamBuilder<List<WordItem>>(
      stream: firestoreService.getCurrentWordItems(pack.id),
      builder: (context, snapshot) {
        final wordCount = snapshot.data?.length ?? 0;

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
                  child: Icon(style.icon, color: Colors.white, size: 52),
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
                              pack.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                onDelete();
                              }
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
                            ? context.l10n.nothingAddedYet
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
                          _PackChip(
                            icon: Icons.abc_rounded,
                            label: context.l10n.wordCount(wordCount),
                            color: color,
                          ),
                          _PackChip(
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
        );
      },
    );
  }
}

class _PackChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PackChip({
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

class _WordPackDialog extends StatefulWidget {
  final List<ChildProfile> children;
  final String Function(String key) styleLabel;

  const _WordPackDialog({required this.children, required this.styleLabel});

  @override
  State<_WordPackDialog> createState() => _WordPackDialogState();
}

class _WordPackDialogState extends State<_WordPackDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final Set<String> _selectedChildIds = {};

  String _styleKey = 'words';
  bool _availableToAll = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.createWordPack),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.packName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.packDescription,
                  hintText: context.l10n.packDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.packStyle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    wordPackVisualStyles.map((style) {
                      final selected = style.key == _styleKey;

                      return ChoiceChip(
                        selected: selected,
                        avatar: Icon(style.icon, color: style.color),
                        label: Text(widget.styleLabel(style.key)),
                        onSelected: (_) {
                          setState(() {
                            _styleKey = style.key;
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
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
                const SizedBox(height: 14),
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
            final name = _nameController.text.trim();

            if (name.isEmpty) return;

            Navigator.pop(
              context,
              _WordPackDraft(
                name: name,
                description: _descriptionController.text.trim(),
                styleKey: _styleKey,
                availableToAll: _availableToAll,
                selectedChildIds: _selectedChildIds.toList(),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.create),
        ),
      ],
    );
  }
}

class _WordPackDraft {
  final String name;
  final String description;
  final String styleKey;
  final bool availableToAll;
  final List<String> selectedChildIds;

  const _WordPackDraft({
    required this.name,
    required this.description,
    required this.styleKey,
    required this.availableToAll,
    required this.selectedChildIds,
  });
}

class _WordMessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _WordMessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF66BB6A)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
