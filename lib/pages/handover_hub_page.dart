import 'package:flutter/material.dart';
import '../models/handover_overview.dart';
import '../l10n/l10n.dart';
import '../models/handover_quick_note.dart';
import '../models/staff_handover_document.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class HandoverHubPage extends StatefulWidget {
  final StaffProfile currentStaff;

  const HandoverHubPage({super.key, required this.currentStaff});

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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _editOverview(
    BuildContext context,
    HandoverOverview overview,
  ) async {
    final snapshotController = TextEditingController(
      text:
          overview.classroomSnapshot.isEmpty
              ? overview.legacyContent
              : overview.classroomSnapshot,
    );
    final routineController = TextEditingController(
      text: overview.todayRoutine,
    );
    final mustKnowController = TextEditingController(text: overview.mustKnow);
    final supportsController = TextEditingController(
      text: overview.safetySupports,
    );
    final checkFirstController = TextEditingController(
      text: overview.checkFirst,
    );
    final urgentController = TextEditingController(
      text: overview.urgentGuidance,
    );

    final result = await showDialog<HandoverOverview>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.editStartHereTitle),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DocumentTextField(
                    label: context.l10n.classroomSnapshot,
                    hint: context.l10n.classroomSnapshotHint,
                    controller: snapshotController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.todayRoutine,
                    hint: context.l10n.todayRoutineHint,
                    controller: routineController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.mustKnow,
                    hint: context.l10n.mustKnowHint,
                    controller: mustKnowController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.safetySupports,
                    hint: context.l10n.safetySupportsHint,
                    controller: supportsController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.checkFirst,
                    hint: context.l10n.checkFirstHint,
                    controller: checkFirstController,
                  ),
                  _DocumentTextField(
                    label: context.l10n.urgentGuidance,
                    hint: context.l10n.urgentGuidanceHint,
                    controller: urgentController,
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
                  HandoverOverview(
                    classroomSnapshot: snapshotController.text.trim(),
                    todayRoutine: routineController.text.trim(),
                    mustKnow: mustKnowController.text.trim(),
                    safetySupports: supportsController.text.trim(),
                    checkFirst: checkFirstController.text.trim(),
                    urgentGuidance: urgentController.text.trim(),
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

    snapshotController.dispose();
    routineController.dispose();
    mustKnowController.dispose();
    supportsController.dispose();
    checkFirstController.dispose();
    urgentController.dispose();

    if (result == null) return;

    try {
      await firestoreService.updateCurrentHandoverOverview(
        overview: result,
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
    return StreamBuilder<HandoverOverview>(
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

        final overview = snapshot.data!;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3F7FF), Color(0xFFF8F2FF)],
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
                      description: context.l10n.startHereDescription,
                      color: const Color(0xFF7E57C2),
                    ),
                    const SizedBox(height: 14),
                    const _HandoverPurposePanel(),
                    const SizedBox(height: 18),
                    if (overview.isEmpty)
                      _HandoverEmptyCard(
                        icon: Icons.description_outlined,
                        title: context.l10n.noStartHereInformation,
                      )
                    else
                      _StartHereOverviewGrid(overview: overview),
                    const SizedBox(height: 18),
                    _RelatedToolsPanel(
                      currentStaff: currentStaff,
                      firestoreService: firestoreService,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => _editOverview(context, overview),
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

class _StartHereOverviewGrid extends StatelessWidget {
  final HandoverOverview overview;

  const _StartHereOverviewGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _StartHereSectionData(
        title: context.l10n.classroomSnapshot,
        content:
            overview.classroomSnapshot.isEmpty
                ? overview.legacyContent
                : overview.classroomSnapshot,
        icon: Icons.groups_2_rounded,
        color: const Color(0xFF42A5F5),
      ),
      _StartHereSectionData(
        title: context.l10n.todayRoutine,
        content: overview.todayRoutine,
        icon: Icons.event_note_rounded,
        color: const Color(0xFF66BB6A),
      ),
      _StartHereSectionData(
        title: context.l10n.mustKnow,
        content: overview.mustKnow,
        icon: Icons.priority_high_rounded,
        color: const Color(0xFFFFA726),
      ),
      _StartHereSectionData(
        title: context.l10n.safetySupports,
        content: overview.safetySupports,
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFEF5350),
      ),
      _StartHereSectionData(
        title: context.l10n.checkFirst,
        content: overview.checkFirst,
        icon: Icons.checklist_rounded,
        color: const Color(0xFF26A69A),
      ),
      _StartHereSectionData(
        title: context.l10n.urgentGuidance,
        content: overview.urgentGuidance,
        icon: Icons.emergency_rounded,
        color: const Color(0xFF7E57C2),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 760;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children:
              sections.map((section) {
                final width =
                    useTwoColumns
                        ? (constraints.maxWidth - 14) / 2
                        : constraints.maxWidth;

                return SizedBox(
                  width: width,
                  child: _StartHereSectionCard(section: section),
                );
              }).toList(),
        );
      },
    );
  }
}

class _HandoverPurposePanel extends StatelessWidget {
  const _HandoverPurposePanel();

  String _t(BuildContext context, String en, String ga) {
    return Localizations.localeOf(context).languageCode == 'ga' ? ga : en;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEDE7F6),
            child: Icon(Icons.lightbulb_rounded, color: Color(0xFF7E57C2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(
                    context,
                    'Classroom operating guide',
                    'Treoir oibre an tseomra ranga',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t(
                    context,
                    'Use this space for the lived classroom context: routines, transitions, supports, reminders, and what a substitute should know before working in this room. Official school or board documents belong in Guidelines.',
                    'Úsáid an spás seo don chomhthéacs beo ranga: gnáthaimh, aistrithe, tacaíochtaí, meabhrúcháin, agus an rud ba chóir do mhúinteoir ionaid a bheith ar eolas aige/aici sula n-oibríonn sé/sí sa seomra seo. Baineann cáipéisí oifigiúla scoile nó boird le Treoirlínte.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}

class _StartHereSectionData {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _StartHereSectionData({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });
}

class _StartHereSectionCard extends StatelessWidget {
  final _StartHereSectionData section;

  const _StartHereSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final hasContent = section.content.trim().isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: section.color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: section.color.withValues(alpha: 0.14),
                child: Icon(section.icon, color: section.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: section.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            hasContent ? section.content : context.l10n.nothingAddedYet,
            style: TextStyle(
              height: 1.45,
              color: hasContent ? null : Colors.grey.shade600,
              fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedToolsPanel extends StatelessWidget {
  final StaffProfile currentStaff;
  final FirestoreService firestoreService;

  const _RelatedToolsPanel({
    required this.currentStaff,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      _RelatedToolData(
        title: context.l10n.todayOverview,
        subtitle: context.l10n.todayOverviewShortcutSubtitle,
        icon: Icons.today_rounded,
        color: const Color(0xFF26A69A),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/today-overview',
              arguments: currentStaff,
            ),
      ),
      _RelatedToolData(
        title: context.l10n.childNotes,
        subtitle: context.l10n.childNotesShortcutSubtitle,
        icon: Icons.sticky_note_2_rounded,
        color: const Color(0xFF5E7CE2),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/child-notes',
              arguments: {
                'staffProfile': currentStaff,
                'firestoreService': firestoreService,
              },
            ),
      ),
      _RelatedToolData(
        title: context.l10n.calmPlan,
        subtitle: context.l10n.calmPlanShortcutSubtitle,
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF7E57C2),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/calm-plan-management',
              arguments: {
                'staffProfile': currentStaff,
                'firestoreService': firestoreService,
              },
            ),
      ),
      _RelatedToolData(
        title: context.l10n.bodyCheck,
        subtitle: context.l10n.bodyCheckShortcutSubtitle,
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFEF5350),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/body-check-overview',
              arguments: {
                'teacherUid': currentStaff.teacherUid,
                'firestoreService': firestoreService,
              },
            ),
      ),
      _RelatedToolData(
        title: context.l10n.classroomHelper,
        subtitle: context.l10n.classroomHelperShortcutSubtitle,
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFFFFA726),
        onTap:
            () => Navigator.pushNamed(
              context,
              '/classroom-helper-management',
              arguments: {
                'staffProfile': currentStaff,
                'firestoreService': firestoreService,
              },
            ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.relatedStaffTools,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(context.l10n.relatedStaffToolsDescription),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                tools.map((tool) => _RelatedToolChip(data: tool)).toList(),
          ),
        ],
      ),
    );
  }
}

class _RelatedToolData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RelatedToolData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _RelatedToolChip extends StatelessWidget {
  final _RelatedToolData data;

  const _RelatedToolChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 255,
      child: Material(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: data.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: data.color.withValues(alpha: 0.16),
                  child: Icon(data.icon, color: data.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HandoverEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _HandoverEmptyCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 17),
            ),
          ],
        ),
      ),
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
              description: context.l10n.handoverStaffGuidanceDescription,
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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _editDocument(
    BuildContext context,
    StaffHandoverDocument document,
  ) async {
    final aboutController = TextEditingController(
      text: document.aboutThisClass,
    );
    final worksController = TextEditingController(text: document.whatWorksWell);
    final triggersController = TextEditingController(
      text: document.commonTriggers,
    );
    final strategiesController = TextEditingController(
      text: document.successfulStrategies,
    );
    final communicationController = TextEditingController(
      text: document.communicationTips,
    );
    final otherController = TextEditingController(text: document.otherNotes);

    final updatedDocument = await showDialog<StaffHandoverDocument>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.editStaffDocument(staff.name)),
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
                    aboutThisClass: aboutController.text.trim(),
                    whatWorksWell: worksController.text.trim(),
                    commonTriggers: triggersController.text.trim(),
                    successfulStrategies: strategiesController.text.trim(),
                    communicationTips: communicationController.text.trim(),
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
      stream: firestoreService.getCurrentStaffHandoverDocument(staff: staff),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: Text(context.l10n.handoverLoadError),
            ),
          );
        }

        final document =
            snapshot.data ??
            StaffHandoverDocument.empty(
              staffProfileId: staff.id,
              staffName: staff.name,
            );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF42A5F5).withValues(alpha: 0.14),
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _NoteMetadata(
                    icon:
                        document.hasContent
                            ? Icons.check_circle_rounded
                            : Icons.pending_actions_rounded,
                    text:
                        document.hasContent
                            ? context.l10n.guidanceAdded
                            : context.l10n.guidanceNeeded,
                  ),
                  _NoteMetadata(
                    icon: Icons.schedule_rounded,
                    text:
                        document.updatedAt == null
                            ? context.l10n.nothingAddedYet
                            : context.l10n.lastUpdated(
                              _formatDate(context, document.updatedAt!),
                            ),
                  ),
                ],
              ),
            ),
            trailing:
                canEdit
                    ? IconButton(
                      tooltip: context.l10n.edit,
                      onPressed: () => _editDocument(context, document),
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

enum _QuickNoteFilter { all, pinned, urgent, important, normal }

class _QuickNotesTab extends StatefulWidget {
  final StaffProfile currentStaff;
  final FirestoreService firestoreService;

  const _QuickNotesTab({
    required this.currentStaff,
    required this.firestoreService,
  });

  @override
  State<_QuickNotesTab> createState() => _QuickNotesTabState();
}

class _QuickNotesTabState extends State<_QuickNotesTab> {
  final TextEditingController _searchController = TextEditingController();
  _QuickNoteFilter _filter = _QuickNoteFilter.all;

  StaffProfile get currentStaff => widget.currentStaff;
  FirestoreService get firestoreService => widget.firestoreService;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _t(String en, String ga) {
    return Localizations.localeOf(context).languageCode == 'ga' ? ga : en;
  }

  String _formatDate(BuildContext context, DateTime date) {
    final material = MaterialLocalizations.of(context);

    return '${material.formatMediumDate(date)} • '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openNoteDialog(
    BuildContext context, {
    HandoverQuickNote? note,
  }) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    var selectedPriority = note?.priority ?? HandoverQuickNotePriority.normal;
    var pinned = note?.pinned ?? false;

    final result = await showDialog<_QuickNoteDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: context.l10n.titleLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: contentController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 4,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: context.l10n.noteLabel,
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<HandoverQuickNotePriority>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(
                        labelText: context.l10n.priority,
                        border: const OutlineInputBorder(),
                      ),
                      items:
                          HandoverQuickNotePriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(_priorityLabel(context, priority)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: pinned,
                      title: Text(context.l10n.pinReminder),
                      subtitle: Text(context.l10n.pinReminderDescription),
                      onChanged: (value) {
                        setDialogState(() {
                          pinned = value;
                        });
                      },
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
                        priority: selectedPriority,
                        pinned: pinned,
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
          priority: result.priority,
          pinned: result.pinned,
          createdBy: currentStaff,
        );
      } else {
        await firestoreService.updateCurrentHandoverQuickNote(
          noteId: note.id,
          title: result.title,
          content: result.content,
          priority: result.priority,
          pinned: result.pinned,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, context.l10n.handoverSaveError);
      }
    }
  }

  String _priorityLabel(
    BuildContext context,
    HandoverQuickNotePriority priority,
  ) {
    return switch (priority) {
      HandoverQuickNotePriority.normal => context.l10n.normalPriority,
      HandoverQuickNotePriority.important => context.l10n.important,
      HandoverQuickNotePriority.urgent => context.l10n.urgent,
    };
  }

  Color _priorityColor(HandoverQuickNotePriority priority) {
    return switch (priority) {
      HandoverQuickNotePriority.normal => const Color(0xFF78909C),
      HandoverQuickNotePriority.important => const Color(0xFFFFA726),
      HandoverQuickNotePriority.urgent => const Color(0xFFEF5350),
    };
  }

  int _priorityRank(HandoverQuickNotePriority priority) {
    return switch (priority) {
      HandoverQuickNotePriority.normal => 0,
      HandoverQuickNotePriority.important => 1,
      HandoverQuickNotePriority.urgent => 2,
    };
  }

  List<HandoverQuickNote> _sortedNotes(List<HandoverQuickNote> notes) {
    final sorted = [...notes];

    sorted.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;

      final priorityCompare = _priorityRank(
        b.priority,
      ).compareTo(_priorityRank(a.priority));
      if (priorityCompare != 0) return priorityCompare;

      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
      return bDate.compareTo(aDate);
    });

    return sorted;
  }

  String _filterLabel(_QuickNoteFilter filter) {
    return switch (filter) {
      _QuickNoteFilter.all => _t('All', 'Gach ceann'),
      _QuickNoteFilter.pinned => context.l10n.pinned,
      _QuickNoteFilter.urgent => context.l10n.urgent,
      _QuickNoteFilter.important => context.l10n.important,
      _QuickNoteFilter.normal => context.l10n.normalPriority,
    };
  }

  int _countForFilter(List<HandoverQuickNote> notes, _QuickNoteFilter filter) {
    return notes.where((note) {
      return switch (filter) {
        _QuickNoteFilter.all => true,
        _QuickNoteFilter.pinned => note.pinned,
        _QuickNoteFilter.urgent =>
          note.priority == HandoverQuickNotePriority.urgent,
        _QuickNoteFilter.important =>
          note.priority == HandoverQuickNotePriority.important,
        _QuickNoteFilter.normal =>
          note.priority == HandoverQuickNotePriority.normal,
      };
    }).length;
  }

  List<HandoverQuickNote> _filteredNotes(List<HandoverQuickNote> notes) {
    final query = _searchController.text.trim().toLowerCase();

    return notes.where((note) {
      final filterMatches = switch (_filter) {
        _QuickNoteFilter.all => true,
        _QuickNoteFilter.pinned => note.pinned,
        _QuickNoteFilter.urgent =>
          note.priority == HandoverQuickNotePriority.urgent,
        _QuickNoteFilter.important =>
          note.priority == HandoverQuickNotePriority.important,
        _QuickNoteFilter.normal =>
          note.priority == HandoverQuickNotePriority.normal,
      };

      final searchMatches =
          query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.createdByName.toLowerCase().contains(query) ||
          _priorityLabel(context, note.priority).toLowerCase().contains(query);

      return filterMatches && searchMatches;
    }).toList();
  }

  Future<void> _deleteNote(BuildContext context, HandoverQuickNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.deleteNoteTitle),
          content: Text(context.l10n.deleteNoteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await firestoreService.deleteCurrentHandoverQuickNote(note.id);
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

          final notes = _sortedNotes(snapshot.data!);
          final filteredNotes = _filteredNotes(notes);

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
                description: context.l10n.handoverClassroomRemindersDescription,
                color: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 14),
              _QuickNotesAtAGlance(
                total: notes.length,
                pinned: _countForFilter(notes, _QuickNoteFilter.pinned),
                urgent: _countForFilter(notes, _QuickNoteFilter.urgent),
                important: _countForFilter(notes, _QuickNoteFilter.important),
                t: _t,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _t(
                    'Search classroom reminders',
                    'Cuardaigh meabhrúcháin ranga',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                            tooltip: _t('Clear search', 'Glan cuardach'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _QuickNoteFilter.values.map((filter) {
                        final count = _countForFilter(notes, filter);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: _filter == filter,
                            label: Text('${_filterLabel(filter)} ($count)'),
                            onSelected: (_) {
                              setState(() => _filter = filter);
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              if (filteredNotes.isEmpty)
                _HandoverEmptyCard(
                  icon: Icons.search_off_rounded,
                  title: _t(
                    'No reminders match this view.',
                    'Níl aon mheabhrúchán ag teacht leis an radharc seo.',
                  ),
                )
              else
                ...filteredNotes.map((note) {
                  final canEdit = note.createdByStaffId == currentStaff.id;

                  final date = note.updatedAt ?? note.createdAt;
                  final priorityColor = _priorityColor(note.priority);

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              if (canEdit)
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openNoteDialog(context, note: note);
                                    } else if (value == 'delete') {
                                      _deleteNote(context, note);
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                              Icons.edit_rounded,
                                            ),
                                            title: Text(context.l10n.edit),
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
                              if (note.pinned)
                                _NoteMetadata(
                                  icon: Icons.push_pin_rounded,
                                  text: context.l10n.pinned,
                                ),
                              _NoteMetadata(
                                icon: Icons.flag_rounded,
                                text: _priorityLabel(context, note.priority),
                                color: priorityColor,
                              ),
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
          colors: [color, color.withValues(alpha: 0.74)],
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
            child: Icon(icon, color: Colors.white, size: 35),
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
                  style: const TextStyle(color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickNotesAtAGlance extends StatelessWidget {
  final int total;
  final int pinned;
  final int urgent;
  final int important;
  final String Function(String en, String ga) t;

  const _QuickNotesAtAGlance({
    required this.total,
    required this.pinned,
    required this.urgent,
    required this.important,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickNoteStatData(
        icon: Icons.sticky_note_2_rounded,
        label: t('Total', 'Iomlán'),
        value: total.toString(),
        color: const Color(0xFFFFA726),
      ),
      _QuickNoteStatData(
        icon: Icons.push_pin_rounded,
        label: context.l10n.pinned,
        value: pinned.toString(),
        color: const Color(0xFF7E57C2),
      ),
      _QuickNoteStatData(
        icon: Icons.emergency_rounded,
        label: context.l10n.urgent,
        value: urgent.toString(),
        color: const Color(0xFFEF5350),
      ),
      _QuickNoteStatData(
        icon: Icons.priority_high_rounded,
        label: context.l10n.important,
        value: important.toString(),
        color: const Color(0xFFFFA726),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth >= 760
                ? (constraints.maxWidth - 30) / 4
                : constraints.maxWidth >= 520
                ? (constraints.maxWidth - 10) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              items.map((item) {
                return SizedBox(width: width, child: _QuickNoteStatCard(item));
              }).toList(),
        );
      },
    );
  }
}

class _QuickNoteStatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickNoteStatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _QuickNoteStatCard extends StatelessWidget {
  final _QuickNoteStatData data;

  const _QuickNoteStatCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: data.color.withValues(alpha: 0.15),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    color: data.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
  final String? hint;
  final TextEditingController controller;

  const _DocumentTextField({
    required this.label,
    this.hint,
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
          hintText: hint,
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
        border: Border.all(color: color.withValues(alpha: 0.22)),
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
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  content.isEmpty ? context.l10n.nothingAddedYet : content,
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
  final Color? color;

  const _NoteMetadata({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color:
            color?.withValues(alpha: 0.12) ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HandoverMessageState extends StatelessWidget {
  final IconData icon;
  final String title;

  const _HandoverMessageState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF7E57C2)),
            const SizedBox(height: 16),
            Text(
              title,
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

class _QuickNoteDraft {
  final String title;
  final String content;
  final HandoverQuickNotePriority priority;
  final bool pinned;

  const _QuickNoteDraft({
    required this.title,
    required this.content,
    required this.priority,
    required this.pinned,
  });
}
