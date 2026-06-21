import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/handover_quick_note.dart';
import '../models/staff_handover_document.dart';
import '../models/staff_profile.dart';
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
          title: Text(context.l10n.handoverHub),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.flag_rounded),
                text: context.l10n.handoverStartHereTab,
              ),
              Tab(
                icon: const Icon(Icons.folder_shared_rounded),
                text: context.l10n.handoverStaffDocumentsTab,
              ),
              Tab(
                icon: const Icon(Icons.sticky_note_2_rounded),
                text: context.l10n.handoverQuickNotesTab,
              ),
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editOverview(
    BuildContext context,
    String currentText,
  ) async {
    final controller = TextEditingController(text: currentText);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.editStartHereTitle),
          content: SizedBox(
            width: 620,
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 8,
              maxLines: 14,
              decoration: InputDecoration(
                hintText: context.l10n.startHereHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: Text(context.l10n.save),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    try {
      await firestoreService.updateCurrentHandoverOverview(
        content: result,
        updatedByName: currentStaff.name,
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.l10n.handoverSaveError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: firestoreService.getCurrentHandoverOverview(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _HandoverMessageState(
            icon: Icons.cloud_off_rounded,
            title: context.l10n.handoverLoadError,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final content = snapshot.data!;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3F7FF),
                Color(0xFFF8F2FF),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _HandoverHeader(
                      icon: Icons.flag_rounded,
                      title: context.l10n.readThisFirst,
                      description:
                          context.l10n.startHereDescription,
                      color: const Color(0xFF7E57C2),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFF7E57C2)
                              .withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: content.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: 62,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    context.l10n
                                        .noStartHereInformation,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SelectableText(
                              content,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.55,
                              ),
                            ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => _editOverview(
                          context,
                          content,
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: Text(context.l10n.editStartHere),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        if (snapshot.hasError) {
          return _HandoverMessageState(
            icon: Icons.cloud_off_rounded,
            title: context.l10n.handoverLoadError,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final staffProfiles = snapshot.data!;

        if (staffProfiles.isEmpty) {
          return _HandoverMessageState(
            icon: Icons.people_outline_rounded,
            title: context.l10n.noStaffProfilesFound,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _HandoverHeader(
              icon: Icons.folder_shared_rounded,
              title: context.l10n.handoverStaffDocumentsTab,
              description: context.l10n.startHereDescription,
              color: const Color(0xFF42A5F5),
            ),
            const SizedBox(height: 18),
            ...staffProfiles.map(
              (staff) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _StaffDocumentCard(
                  staff: staff,
                  canEdit: staff.id == currentStaff.id,
                  firestoreService: firestoreService,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StaffDocumentCard extends StatelessWidget {
  final StaffProfile staff;
  final bool canEdit;
  final FirestoreService firestoreService;

  const _StaffDocumentCard({
    required this.staff,
    required this.canEdit,
    required this.firestoreService,
  });

  String _formatDate(BuildContext context, DateTime date) {
    final material = MaterialLocalizations.of(context);

    return '${material.formatMediumDate(date)} • '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editDocument(
    BuildContext context,
    StaffHandoverDocument document,
  ) async {
    final aboutController =
        TextEditingController(text: document.aboutThisClass);
    final worksController =
        TextEditingController(text: document.whatWorksWell);
    final triggersController =
        TextEditingController(text: document.commonTriggers);
    final strategiesController =
        TextEditingController(text: document.successfulStrategies);
    final communicationController =
        TextEditingController(text: document.communicationTips);
    final otherController =
        TextEditingController(text: document.otherNotes);

    final updatedDocument =
        await showDialog<StaffHandoverDocument>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.editStaffDocument(staff.name),
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DocumentTextField(
                    label: context.l10n.aboutThisClass,
                    controller: aboutController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.whatWorksWell,
                    controller: worksController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.commonTriggers,
                    controller: triggersController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.successfulStrategies,
                    controller: strategiesController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.communicationTips,
                    controller: communicationController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.otherNotes,
                    controller: otherController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  StaffHandoverDocument(
                    staffProfileId: staff.id,
                    staffName: staff.name,
                    aboutThisClass:
                        aboutController.text.trim(),
                    whatWorksWell:
                        worksController.text.trim(),
                    commonTriggers:
                        triggersController.text.trim(),
                    successfulStrategies:
                        strategiesController.text.trim(),
                    communicationTips:
                        communicationController.text.trim(),
                    otherNotes: otherController.text.trim(),
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: Text(context.l10n.save),
            ),
          ],
        );
      },
    );

    aboutController.dispose();
    worksController.dispose();
    triggersController.dispose();
    strategiesController.dispose();
    communicationController.dispose();
    otherController.dispose();

    if (updatedDocument == null) return;

    try {
      await firestoreService.updateCurrentStaffHandoverDocument(
        document: updatedDocument,
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.l10n.handoverSaveError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StaffHandoverDocument>(
      stream: firestoreService.getCurrentStaffHandoverDocument(
        staff: staff,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: Text(context.l10n.handoverLoadError),
            ),
          );
        }

        final document = snapshot.data ??
            StaffHandoverDocument.empty(
              staffProfileId: staff.id,
              staffName: staff.name,
            );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: const Color(0xFF42A5F5)
                  .withValues(alpha: 0.25),
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF42A5F5)
                  .withValues(alpha: 0.14),
              child: Text(
                staff.name.isEmpty
                    ? '?'
                    : staff.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            title: Text(
              context.l10n.staffDocumentTitle(staff.name),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              document.updatedAt == null
                  ? context.l10n.nothingAddedYet
                  : context.l10n.lastUpdated(
                      _formatDate(context, document.updatedAt!),
                    ),
            ),
            trailing: canEdit
                ? IconButton(
                    tooltip: context.l10n.edit,
                    onPressed: () => _editDocument(
                      context,
                      document,
                    ),
                    icon: const Icon(Icons.edit_rounded),
                  )
                : Tooltip(
                    message: context.l10n.viewOnly,
                    child: const Icon(Icons.visibility_rounded),
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  children: [
                    _DocumentSection(
                      title: context.l10n.aboutThisClass,
                      content: document.aboutThisClass,
                      icon: Icons.school_rounded,
                      color: const Color(0xFF42A5F5),
                    ),
                    _DocumentSection(
                      title: context.l10n.whatWorksWell,
                      content: document.whatWorksWell,
                      icon: Icons.thumb_up_alt_rounded,
                      color: const Color(0xFF66BB6A),
                    ),
                    _DocumentSection(
                      title: context.l10n.commonTriggers,
                      content: document.commonTriggers,
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFFFA726),
                    ),
                    _DocumentSection(
                      title: context.l10n.successfulStrategies,
                      content: document.successfulStrategies,
                      icon: Icons.psychology_alt_rounded,
                      color: const Color(0xFF7E57C2),
                    ),
                    _DocumentSection(
                      title: context.l10n.communicationTips,
                      content: document.communicationTips,
                      icon: Icons.forum_rounded,
                      color: const Color(0xFF26A69A),
                    ),
                    _DocumentSection(
                      title: context.l10n.otherNotes,
                      content: document.otherNotes,
                      icon: Icons.notes_rounded,
                      color: const Color(0xFF78909C),
                    ),
                  ],
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

  String _formatDate(BuildContext context, DateTime date) {
    final material = MaterialLocalizations.of(context);

    return '${material.formatMediumDate(date)} • '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openNoteDialog(
    BuildContext context, {
    HandoverQuickNote? note,
  }) async {
    final titleController =
        TextEditingController(text: note?.title ?? '');
    final contentController =
        TextEditingController(text: note?.content ?? '');

    final result = await showDialog<_QuickNoteDraft>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            note == null
                ? context.l10n.addQuickNote
                : context.l10n.editQuickNote,
          ),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: context.l10n.titleLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: contentController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: context.l10n.noteLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty && content.isEmpty) return;

                Navigator.pop(
                  dialogContext,
                  _QuickNoteDraft(
                    title: title,
                    content: content,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: Text(context.l10n.save),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

    if (result == null) return;

    try {
      if (note == null) {
        await firestoreService.addCurrentHandoverQuickNote(
          title: result.title,
          content: result.content,
          createdBy: currentStaff,
        );
      } else {
        await firestoreService.updateCurrentHandoverQuickNote(
          noteId: note.id,
          title: result.title,
          content: result.content,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.l10n.handoverSaveError);
      }
    }
  }

  Future<void> _deleteNote(
    BuildContext context,
    HandoverQuickNote note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.deleteNoteTitle),
          content: Text(context.l10n.deleteNoteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await firestoreService.deleteCurrentHandoverQuickNote(
        note.id,
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.l10n.handoverDeleteError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<HandoverQuickNote>>(
        stream: firestoreService.getCurrentHandoverQuickNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _HandoverMessageState(
              icon: Icons.cloud_off_rounded,
              title: context.l10n.handoverLoadError,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!;

          if (notes.isEmpty) {
            return _HandoverMessageState(
              icon: Icons.sticky_note_2_outlined,
              title: context.l10n.noQuickNotes,
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              _HandoverHeader(
                icon: Icons.sticky_note_2_rounded,
                title: context.l10n.handoverQuickNotesTab,
                description: context.l10n.startHereDescription,
                color: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 18),
              ...notes.map((note) {
                final canEdit =
                    note.createdByStaffId == currentStaff.id;

                final date = note.updatedAt ?? note.createdAt;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: const Color(0xFFFFA726)
                          .withValues(alpha: 0.24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFFFF3E0),
                              child: Icon(
                                Icons.sticky_note_2_rounded,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                note.title.isEmpty
                                    ? context.l10n.untitled
                                    : note.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            if (canEdit)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openNoteDialog(
                                      context,
                                      note: note,
                                    );
                                  } else if (value == 'delete') {
                                    _deleteNote(context, note);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.edit_rounded,
                                      ),
                                      title: Text(
                                        context.l10n.edit,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        context.l10n.delete,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (note.content.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          SelectableText(
                            note.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            _NoteMetadata(
                              icon: Icons.person_rounded,
                              text: context.l10n.quickNoteBy(
                                note.createdByName,
                              ),
                            ),
                            if (date != null)
                              _NoteMetadata(
                                icon: Icons.schedule_rounded,
                                text: context.l10n.lastUpdated(
                                  _formatDate(context, date),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.addNote),
      ),
    );
  }
}

class _HandoverHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HandoverHeader({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.74),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _DocumentTextField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _DocumentSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  content.isEmpty
                      ? context.l10n.nothingAddedYet
                      : content,
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteMetadata extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NoteMetadata({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}

class _HandoverMessageState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _HandoverMessageState({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: const Color(0xFF7E57C2),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickNoteDraft {
  final String title;
  final String content;

  const _QuickNoteDraft({
    required this.title,
    required this.content,
  });
}