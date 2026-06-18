import 'package:flutter/material.dart';
import '../models/staff_profile.dart';
import '../models/staff_handover_document.dart';
import '../models/handover_quick_note.dart';
import '../services/firestore_service.dart';

class HandoverHubPage extends StatefulWidget {
  final StaffProfile currentStaff;

  const HandoverHubPage({
    super.key,
    required this.currentStaff,
  });

  @override
  State<HandoverHubPage> createState() => _HandoverHubPageState();
}

class _HandoverHubPageState extends State<HandoverHubPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Handover Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Start Here'),
              Tab(text: 'Staff Documents'),
              Tab(text: 'Quick Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StartHereTab(
              currentStaff: widget.currentStaff,
              firestoreService: _firestoreService,
            ),
            _StaffDocumentsTab(
              currentStaff: widget.currentStaff,
              firestoreService: _firestoreService,
            ),
            _QuickNotesTab(
              currentStaff: widget.currentStaff,
              firestoreService: _firestoreService,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartHereTab extends StatelessWidget {
  final StaffProfile currentStaff;
  final FirestoreService firestoreService;

  const _StartHereTab({
    required this.currentStaff,
    required this.firestoreService,
  });

  void _openEditDialog(BuildContext context, String currentText) {
    final controller = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Start Here'),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Write the most important classroom information here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await firestoreService.updateCurrentHandoverOverview(
                  content: controller.text.trim(),
                  updatedByName: currentStaff.name,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: firestoreService.getCurrentHandoverOverview(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? '';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Read this first',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This section should contain the most important things a substitute teacher or SNA needs to know immediately.',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content.isEmpty
                        ? 'No Start Here information has been added yet.'
                        : content,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Start Here'),
                onPressed: () => _openEditDialog(context, content),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaffDocumentsTab extends StatelessWidget {
  final StaffProfile currentStaff;
  final FirestoreService firestoreService;

  const _StaffDocumentsTab({
    required this.currentStaff,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StaffProfile>>(
      stream: firestoreService.getCurrentStaffProfiles(),
      builder: (context, snapshot) {
        final staffProfiles = snapshot.data ?? [];

        if (staffProfiles.isEmpty) {
          return const Center(child: Text('No staff profiles found.'));
        }

        return DefaultTabController(
          length: staffProfiles.length,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  isScrollable: true,
                  tabs: staffProfiles
                      .map((staff) => Tab(text: staff.name))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: staffProfiles.map((staff) {
                    final canEdit = staff.id == currentStaff.id;

                    return _StaffDocumentView(
                      staff: staff,
                      canEdit: canEdit,
                      firestoreService: firestoreService,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaffDocumentView extends StatelessWidget {
  final StaffProfile staff;
  final bool canEdit;
  final FirestoreService firestoreService;

  const _StaffDocumentView({
    required this.staff,
    required this.canEdit,
    required this.firestoreService,
  });

  void _openEditDialog(BuildContext context, StaffHandoverDocument doc) {
    final aboutController = TextEditingController(text: doc.aboutThisClass);
    final worksController = TextEditingController(text: doc.whatWorksWell);
    final triggersController = TextEditingController(text: doc.commonTriggers);
    final strategiesController =
        TextEditingController(text: doc.successfulStrategies);
    final communicationController =
        TextEditingController(text: doc.communicationTips);
    final otherController = TextEditingController(text: doc.otherNotes);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit ${staff.name} Document'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _sectionField('About This Class', aboutController),
                  _sectionField('What Works Well', worksController),
                  _sectionField('Common Triggers', triggersController),
                  _sectionField('Successful Strategies', strategiesController),
                  _sectionField('Communication Tips', communicationController),
                  _sectionField('Other Notes', otherController),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedDoc = StaffHandoverDocument(
                  staffProfileId: staff.id,
                  staffName: staff.name,
                  aboutThisClass: aboutController.text.trim(),
                  whatWorksWell: worksController.text.trim(),
                  commonTriggers: triggersController.text.trim(),
                  successfulStrategies: strategiesController.text.trim(),
                  communicationTips: communicationController.text.trim(),
                  otherNotes: otherController.text.trim(),
                );

                await firestoreService.updateCurrentStaffHandoverDocument(
                  document: updatedDoc,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  static Widget _sectionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _readSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? 'Nothing added yet.' : content,
              style: const TextStyle(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StaffHandoverDocument>(
      stream: firestoreService.getCurrentStaffHandoverDocument(
        staff: staff,
      ),
      builder: (context, snapshot) {
        final doc = snapshot.data ??
            StaffHandoverDocument.empty(
              staffProfileId: staff.id,
              staffName: staff.name,
            );

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${staff.name} Document',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (canEdit)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _openEditDialog(context, doc),
                    ),
                ],
              ),
              if (!canEdit)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 6, bottom: 10),
                    child: Text('View only'),
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _readSection('About This Class', doc.aboutThisClass),
                      _readSection('What Works Well', doc.whatWorksWell),
                      _readSection('Common Triggers', doc.commonTriggers),
                      _readSection(
                        'Successful Strategies',
                        doc.successfulStrategies,
                      ),
                      _readSection(
                        'Communication Tips',
                        doc.communicationTips,
                      ),
                      _readSection('Other Notes', doc.otherNotes),
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

class _QuickNotesTab extends StatelessWidget {
  final StaffProfile currentStaff;
  final FirestoreService firestoreService;

  const _QuickNotesTab({
    required this.currentStaff,
    required this.firestoreService,
  });

  void _openNoteDialog(BuildContext context, {HandoverQuickNote? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final isEditing = note != null;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Quick Note' : 'Add Quick Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty && content.isEmpty) return;

                if (isEditing) {
                  await firestoreService.updateCurrentHandoverQuickNote(
                    noteId: note.id,
                    title: title,
                    content: content,
                  );
                } else {
                  await firestoreService.addCurrentHandoverQuickNote(
                    title: title,
                    content: content,
                    createdBy: currentStaff,
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HandoverQuickNote note,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: const Text('Are you sure you want to delete this note?'),
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

    if (shouldDelete == true) {
      await firestoreService.deleteCurrentHandoverQuickNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<HandoverQuickNote>>(
        stream: firestoreService.getCurrentHandoverQuickNotes(),
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text('No quick notes yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final canEdit = note.createdByStaffId == currentStaff.id;

              return Card(
                child: ListTile(
                  title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                  subtitle: Text(
                    '${note.content}\nBy: ${note.createdByName}',
                  ),
                  isThreeLine: true,
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openNoteDialog(context, note: note);
                            } else if (value == 'delete') {
                              _confirmDelete(context, note);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
        onPressed: () => _openNoteDialog(context),
      ),
    );
  }
}