import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/child_note.dart';
import '../models/child_profile.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

enum _NoteVisibilityFilter { all, shared, private }

class ChildNotesPage extends StatefulWidget {
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;

  const ChildNotesPage({
    super.key,
    required this.staffProfile,
    required this.firestoreService,
  });

  @override
  State<ChildNotesPage> createState() => _ChildNotesPageState();
}

class _ChildNotesPageState extends State<ChildNotesPage> {
  String? _selectedChildId;
  ChildNoteCategory? _categoryFilter;
  _NoteVisibilityFilter _visibilityFilter = _NoteVisibilityFilter.all;
  bool _showMineOnly = false;

  ChildProfile? _selectedChild(List<ChildProfile> children) {
    final selectedId = _selectedChildId;
    if (selectedId == null) return null;

    for (final child in children) {
      if (child.id == selectedId) return child;
    }

    return null;
  }

  List<ChildNote> _filteredNotes(List<ChildNote> notes) {
    return notes.where((note) {
      final categoryMatches =
          _categoryFilter == null || note.category == _categoryFilter;
      final mineMatches =
          !_showMineOnly || note.createdByStaffId == widget.staffProfile.id;

      final visibilityMatches = switch (_visibilityFilter) {
        _NoteVisibilityFilter.all => true,
        _NoteVisibilityFilter.shared =>
          note.visibility == ChildNoteVisibility.shared,
        _NoteVisibilityFilter.private =>
          note.visibility == ChildNoteVisibility.private,
      };

      return categoryMatches && mineMatches && visibilityMatches;
    }).toList();
  }

  Future<void> _openNoteDialog({
    required ChildProfile child,
    ChildNote? note,
  }) async {
    final result = await showDialog<_ChildNoteDialogResult>(
      context: context,
      builder:
          (_) => _ChildNoteDialog(
            child: child,
            initialNote: note,
            staffName: widget.staffProfile.name,
          ),
    );

    if (result == null || !mounted) return;

    try {
      if (note == null) {
        await widget.firestoreService.addCurrentChildNote(
          child: child,
          staff: widget.staffProfile,
          content: result.content,
          category: result.category,
          visibility: result.visibility,
        );
      } else {
        await widget.firestoreService.updateCurrentChildNote(
          note: note,
          content: result.content,
          category: result.category,
          visibility: result.visibility,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(note == null ? 'Note added.' : 'Note updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save note: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _categoryLabel(ChildNoteCategory category) {
    return switch (category) {
      ChildNoteCategory.general => 'General',
      ChildNoteCategory.behaviour => 'Behaviour',
      ChildNoteCategory.communication => 'Communication',
      ChildNoteCategory.learning => 'Learning',
      ChildNoteCategory.sensory => 'Sensory',
      ChildNoteCategory.health => 'Health',
      ChildNoteCategory.parent => 'Parent',
    };
  }

  IconData _categoryIcon(ChildNoteCategory category) {
    return switch (category) {
      ChildNoteCategory.general => Icons.notes_rounded,
      ChildNoteCategory.behaviour => Icons.psychology_rounded,
      ChildNoteCategory.communication => Icons.chat_bubble_outline_rounded,
      ChildNoteCategory.learning => Icons.school_rounded,
      ChildNoteCategory.sensory => Icons.spa_rounded,
      ChildNoteCategory.health => Icons.health_and_safety_rounded,
      ChildNoteCategory.parent => Icons.family_restroom_rounded,
    };
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes == 1) return '1 min ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours == 1) return '1 hour ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChildProfile>>(
      stream: widget.firestoreService.getCurrentChildProfiles(),
      builder: (context, childSnapshot) {
        final children = childSnapshot.data ?? const <ChildProfile>[];
        final selectedChild = _selectedChild(children);

        return Scaffold(
          appBar: AppBar(title: const Text('Child Notes')),
          floatingActionButton:
              selectedChild == null
                  ? null
                  : FloatingActionButton.extended(
                    onPressed: () => _openNoteDialog(child: selectedChild),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add note'),
                  ),
          body: SafeArea(
            child:
                childSnapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : childSnapshot.hasError
                    ? Center(
                      child: Text(
                        'Could not load children: ${childSnapshot.error}',
                      ),
                    )
                    : _ChildNotesBody(
                      children: children,
                      selectedChildId: _selectedChildId,
                      selectedCategory: _categoryFilter,
                      selectedVisibility: _visibilityFilter,
                      showMineOnly: _showMineOnly,
                      staffProfile: widget.staffProfile,
                      firestoreService: widget.firestoreService,
                      categoryLabel: _categoryLabel,
                      categoryIcon: _categoryIcon,
                      formatDate: _formatDate,
                      filteredNotes: _filteredNotes,
                      onSelectedChildChanged: (childId) {
                        setState(() {
                          _selectedChildId = childId;
                        });
                      },
                      onSelectedCategoryChanged: (category) {
                        setState(() {
                          _categoryFilter = category;
                        });
                      },
                      onSelectedVisibilityChanged: (visibility) {
                        setState(() {
                          _visibilityFilter = visibility;
                        });
                      },
                      onShowMineOnlyChanged: (value) {
                        setState(() {
                          _showMineOnly = value;
                        });
                      },
                      onEditNote: (note) {
                        final child = children.firstWhere(
                          (child) => child.id == note.childId,
                          orElse:
                              () => ChildProfile(
                                id: note.childId,
                                name: note.childName,
                                age: 0,
                                teacherUid: widget.staffProfile.teacherUid,
                              ),
                        );

                        _openNoteDialog(child: child, note: note);
                      },
                    ),
          ),
        );
      },
    );
  }
}

class _ChildNotesBody extends StatelessWidget {
  final List<ChildProfile> children;
  final String? selectedChildId;
  final ChildNoteCategory? selectedCategory;
  final _NoteVisibilityFilter selectedVisibility;
  final bool showMineOnly;
  final StaffProfile staffProfile;
  final FirestoreService firestoreService;
  final String Function(ChildNoteCategory category) categoryLabel;
  final IconData Function(ChildNoteCategory category) categoryIcon;
  final String Function(DateTime? date) formatDate;
  final List<ChildNote> Function(List<ChildNote> notes) filteredNotes;
  final ValueChanged<String?> onSelectedChildChanged;
  final ValueChanged<ChildNoteCategory?> onSelectedCategoryChanged;
  final ValueChanged<_NoteVisibilityFilter> onSelectedVisibilityChanged;
  final ValueChanged<bool> onShowMineOnlyChanged;
  final ValueChanged<ChildNote> onEditNote;

  const _ChildNotesBody({
    required this.children,
    required this.selectedChildId,
    required this.selectedCategory,
    required this.selectedVisibility,
    required this.showMineOnly,
    required this.staffProfile,
    required this.firestoreService,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.formatDate,
    required this.filteredNotes,
    required this.onSelectedChildChanged,
    required this.onSelectedCategoryChanged,
    required this.onSelectedVisibilityChanged,
    required this.onShowMineOnlyChanged,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    if (children.isEmpty) {
      return const Center(
        child: Text('Add child profiles before creating child notes.'),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colourScheme.primaryContainer.withValues(alpha: 0.22),
            colourScheme.surface,
            const Color(0xFFEAF7F4),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: StreamBuilder<List<ChildNote>>(
                  stream: firestoreService.getCurrentVisibleChildNotesForStaff(
                    staff: staffProfile,
                    childId: selectedChildId,
                  ),
                  builder: (context, snapshot) {
                    final visibleNotes = filteredNotes(snapshot.data ?? []);

                    return _ChildNotesHeader(
                      children: children,
                      selectedChildId: selectedChildId,
                      selectedCategory: selectedCategory,
                      selectedVisibility: selectedVisibility,
                      showMineOnly: showMineOnly,
                      visibleNoteCount: visibleNotes.length,
                      sharedNoteCount:
                          visibleNotes
                              .where(
                                (note) =>
                                    note.visibility ==
                                    ChildNoteVisibility.shared,
                              )
                              .length,
                      privateNoteCount:
                          visibleNotes
                              .where(
                                (note) =>
                                    note.visibility ==
                                    ChildNoteVisibility.private,
                              )
                              .length,
                      categoryLabel: categoryLabel,
                      onSelectedChildChanged: onSelectedChildChanged,
                      onSelectedCategoryChanged: onSelectedCategoryChanged,
                      onSelectedVisibilityChanged:
                          onSelectedVisibilityChanged,
                      onShowMineOnlyChanged: onShowMineOnlyChanged,
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<ChildNote>>(
                  stream: firestoreService.getCurrentVisibleChildNotesForStaff(
                    staff: staffProfile,
                    childId: selectedChildId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Could not load notes: ${snapshot.error}'),
                      );
                    }

                    final notes = filteredNotes(snapshot.data ?? []);

                    if (notes.isEmpty) {
                      return _EmptyNotesState(
                        hasSelectedChild: selectedChildId != null,
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = notes[index];

                        return _ChildNoteCard(
                          note: note,
                          canEdit: note.createdByStaffId == staffProfile.id,
                          categoryLabel: categoryLabel,
                          categoryIcon: categoryIcon,
                          formatDate: formatDate,
                          onEdit: () => onEditNote(note),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildNotesHeader extends StatelessWidget {
  final List<ChildProfile> children;
  final String? selectedChildId;
  final ChildNoteCategory? selectedCategory;
  final _NoteVisibilityFilter selectedVisibility;
  final bool showMineOnly;
  final int visibleNoteCount;
  final int sharedNoteCount;
  final int privateNoteCount;
  final String Function(ChildNoteCategory category) categoryLabel;
  final ValueChanged<String?> onSelectedChildChanged;
  final ValueChanged<ChildNoteCategory?> onSelectedCategoryChanged;
  final ValueChanged<_NoteVisibilityFilter> onSelectedVisibilityChanged;
  final ValueChanged<bool> onShowMineOnlyChanged;

  const _ChildNotesHeader({
    required this.children,
    required this.selectedChildId,
    required this.selectedCategory,
    required this.selectedVisibility,
    required this.showMineOnly,
    required this.visibleNoteCount,
    required this.sharedNoteCount,
    required this.privateNoteCount,
    required this.categoryLabel,
    required this.onSelectedChildChanged,
    required this.onSelectedCategoryChanged,
    required this.onSelectedVisibilityChanged,
    required this.onShowMineOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colourScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E7CE2).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_rounded,
                    color: Color(0xFF5E7CE2),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child Notes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Shared and private staff notes for each child.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryChip(
                  icon: Icons.sticky_note_2_rounded,
                  label: '$visibleNoteCount visible',
                ),
                _SummaryChip(
                  icon: Icons.groups_rounded,
                  label: '$sharedNoteCount shared',
                ),
                _SummaryChip(
                  icon: Icons.lock_rounded,
                  label: '$privateNoteCount private',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: selectedChildId,
              decoration: const InputDecoration(
                labelText: 'Child',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.child_care_rounded),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All children'),
                ),
                ...children.map(
                  (child) => DropdownMenuItem<String?>(
                    value: child.id,
                    child: Text(child.name),
                  ),
                ),
              ],
              onChanged: onSelectedChildChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  selected: selectedCategory == null,
                  label: const Text('All categories'),
                  onSelected: (_) => onSelectedCategoryChanged(null),
                ),
                ...ChildNoteCategory.values.map(
                  (category) => FilterChip(
                    selected: selectedCategory == category,
                    label: Text(categoryLabel(category)),
                    onSelected: (_) => onSelectedCategoryChanged(category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ChoiceChip(
                  selected: selectedVisibility == _NoteVisibilityFilter.all,
                  label: const Text('All visible'),
                  avatar: const Icon(Icons.visibility_rounded, size: 18),
                  onSelected:
                      (_) => onSelectedVisibilityChanged(
                        _NoteVisibilityFilter.all,
                      ),
                ),
                ChoiceChip(
                  selected: selectedVisibility == _NoteVisibilityFilter.shared,
                  label: const Text('Shared'),
                  avatar: const Icon(Icons.groups_rounded, size: 18),
                  onSelected:
                      (_) => onSelectedVisibilityChanged(
                        _NoteVisibilityFilter.shared,
                      ),
                ),
                ChoiceChip(
                  selected: selectedVisibility == _NoteVisibilityFilter.private,
                  label: const Text('Private'),
                  avatar: const Icon(Icons.lock_rounded, size: 18),
                  onSelected:
                      (_) => onSelectedVisibilityChanged(
                        _NoteVisibilityFilter.private,
                      ),
                ),
                FilterChip(
                  selected: showMineOnly,
                  avatar: const Icon(Icons.person_rounded, size: 18),
                  label: const Text('My notes'),
                  onSelected: onShowMineOnlyChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colourScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colourScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colourScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildNoteCard extends StatelessWidget {
  final ChildNote note;
  final bool canEdit;
  final String Function(ChildNoteCategory category) categoryLabel;
  final IconData Function(ChildNoteCategory category) categoryIcon;
  final String Function(DateTime? date) formatDate;
  final VoidCallback onEdit;

  const _ChildNoteCard({
    required this.note,
    required this.canEdit,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.formatDate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final isPrivate = note.visibility == ChildNoteVisibility.private;

    return Card(
      elevation: 0,
      color: colourScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    isPrivate
                        ? colourScheme.tertiaryContainer
                        : colourScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isPrivate ? Icons.lock_rounded : categoryIcon(note.category),
                color:
                    isPrivate
                        ? colourScheme.onTertiaryContainer
                        : colourScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        note.childName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _NoteChip(
                        label: categoryLabel(note.category),
                        icon: categoryIcon(note.category),
                      ),
                      _NoteChip(
                        label: isPrivate ? 'Private' : 'Shared',
                        icon:
                            isPrivate
                                ? Icons.lock_rounded
                                : Icons.groups_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(note.content, style: const TextStyle(height: 1.35)),
                  const SizedBox(height: 12),
                  Text(
                    '${note.createdByStaffName} • ${formatDate(note.updatedAt ?? note.createdAt)}',
                    style: TextStyle(
                      color: colourScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isPrivate) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Private note — visible only to you in this staff view.',
                      style: TextStyle(
                        color: colourScheme.tertiary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (canEdit)
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _NoteChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colourScheme.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colourScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colourScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotesState extends StatelessWidget {
  final bool hasSelectedChild;

  const _EmptyNotesState({required this.hasSelectedChild});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                hasSelectedChild
                    ? 'No notes for this child yet.'
                    : 'Choose a child or add your first note.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'To add a note, choose a child from the dropdown first.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildNoteDialogResult {
  final String content;
  final ChildNoteCategory category;
  final ChildNoteVisibility visibility;

  const _ChildNoteDialogResult({
    required this.content,
    required this.category,
    required this.visibility,
  });
}

class _ChildNoteDialog extends StatefulWidget {
  final ChildProfile child;
  final ChildNote? initialNote;
  final String staffName;

  const _ChildNoteDialog({
    required this.child,
    required this.initialNote,
    required this.staffName,
  });

  @override
  State<_ChildNoteDialog> createState() => _ChildNoteDialogState();
}

class _ChildNoteDialogState extends State<_ChildNoteDialog> {
  late final TextEditingController _contentController;
  late ChildNoteCategory _category;
  late ChildNoteVisibility _visibility;

  @override
  void initState() {
    super.initState();

    final note = widget.initialNote;
    _contentController = TextEditingController(text: note?.content ?? '');
    _category = note?.category ?? ChildNoteCategory.general;
    _visibility = note?.visibility ?? ChildNoteVisibility.shared;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _categoryLabel(ChildNoteCategory category) {
    return switch (category) {
      ChildNoteCategory.general => 'General',
      ChildNoteCategory.behaviour => 'Behaviour',
      ChildNoteCategory.communication => 'Communication',
      ChildNoteCategory.learning => 'Learning',
      ChildNoteCategory.sensory => 'Sensory',
      ChildNoteCategory.health => 'Health',
      ChildNoteCategory.parent => 'Parent',
    };
  }

  void _submit() {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a note first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _ChildNoteDialogResult(
        content: content,
        category: _category,
        visibility: _visibility,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialNote != null;

    return AlertDialog(
      title: Text(editing ? 'Edit note' : 'Add note for ${widget.child.name}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<ChildNoteCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    ChildNoteCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_categoryLabel(category)),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              SegmentedButton<ChildNoteVisibility>(
                selected: {_visibility},
                onSelectionChanged: (selection) {
                  setState(() {
                    _visibility = selection.first;
                  });
                },
                segments: const [
                  ButtonSegment(
                    value: ChildNoteVisibility.shared,
                    icon: Icon(Icons.groups_rounded),
                    label: Text('Shared'),
                  ),
                  ButtonSegment(
                    value: ChildNoteVisibility.private,
                    icon: Icon(Icons.lock_rounded),
                    label: Text('Private'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _visibility == ChildNoteVisibility.private
                    ? 'Private notes are hidden from other staff in the app. They are future-ready for stronger staff-level rules.'
                    : 'Shared notes can be seen by staff in this classroom.',
                style: TextStyle(color: Colors.grey.shade700),
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
        FilledButton(
          onPressed: _submit,
          child: Text(editing ? 'Save note' : 'Add note'),
        ),
      ],
    );
  }
}