import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/classroom_helper_models.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/app_icon_picker_dialog.dart';

class ClassroomHelperPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final ChildProfile? child;
  final StaffProfile? staffProfile;

  const ClassroomHelperPage({
    super.key,
    required this.firestoreService,
    this.child,
    this.staffProfile,
  }) : assert(child != null || staffProfile != null);

  bool get isStaffMode => staffProfile != null;

  @override
  State<ClassroomHelperPage> createState() => _ClassroomHelperPageState();
}

class _ClassroomHelperPageState extends State<ClassroomHelperPage> {
  bool _isSavingDefaults = false;
  String _completionChildFilter = '';

  Future<void> _saveStarterJobs() async {
    setState(() => _isSavingDefaults = true);

    try {
      await widget.firestoreService
          .seedCurrentDefaultClassroomHelperJobsIfEmpty();
      if (!mounted) return;
      _message(context.l10n.classroomHelperStarterJobsSaved);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    } finally {
      if (mounted) setState(() => _isSavingDefaults = false);
    }
  }

  Future<void> _showJobDialog([ClassroomHelperJob? job]) async {
    final titleController = TextEditingController(text: job?.title ?? '');
    final descriptionController = TextEditingController(
      text: job?.description ?? '',
    );
    var iconName = job?.iconName ?? 'star';
    var active = job?.active ?? true;

    final result = await showDialog<ClassroomHelperJob>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Text(
                    job == null
                        ? context.l10n.classroomHelperAddJob
                        : context.l10n.classroomHelperEditJob,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: context.l10n.titleLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText:
                                context.l10n.classroomHelperDescriptionLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await showAppIconPickerDialog(
                              context: context,
                              selectedKey: iconName,
                              title: context.l10n.classroomHelperChooseIcon,
                            );
                            if (selected != null) {
                              setDialogState(() => iconName = selected.key);
                            }
                          },
                          icon: Icon(appIconForKey(iconName)),
                          label: Text(context.l10n.classroomHelperChooseIcon),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: active,
                          title: Text(context.l10n.classroomHelperActiveJob),
                          onChanged:
                              (value) => setDialogState(() => active = value),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        Navigator.pop(
                          context,
                          ClassroomHelperJob(
                            id: job?.id ?? '',
                            title: title,
                            description: descriptionController.text.trim(),
                            iconName: iconName,
                            active: active,
                            sortOrder: job?.sortOrder ?? 100,
                            createdAt: job?.createdAt,
                            updatedAt: job?.updatedAt,
                          ),
                        );
                      },
                      child: Text(context.l10n.save),
                    ),
                  ],
                ),
          ),
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result == null) return;

    try {
      if (job == null) {
        await widget.firestoreService.addCurrentClassroomHelperJob(result);
      } else {
        await widget.firestoreService.updateCurrentClassroomHelperJob(result);
      }
      if (!mounted) return;
      _message(context.l10n.classroomHelperJobSaved);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _deleteJob(ClassroomHelperJob job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.classroomHelperDeleteJob),
            content: Text(
              context.l10n.classroomHelperDeleteJobMessage(job.title),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentClassroomHelperJob(job.id);
      if (!mounted) return;
      _message(context.l10n.classroomHelperJobDeleted);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _assignJob({
    required ClassroomHelperJob job,
    required List<ChildProfile> children,
  }) async {
    final selectedIds = <String>{};

    final targetChildren = await showDialog<List<ChildProfile>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Text(context.l10n.classroomHelperAssignJob(job.title)),
                  content: SizedBox(
                    width: 420,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CheckboxListTile(
                            value:
                                children.isNotEmpty &&
                                selectedIds.length == children.length,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedIds.clear();
                                if (value == true) {
                                  selectedIds.addAll(
                                    children.map((child) => child.id),
                                  );
                                }
                              });
                            },
                            title: Text(
                              context.l10n.classroomHelperAllChildren,
                            ),
                          ),
                          const Divider(),
                          ...children.map(
                            (child) => CheckboxListTile(
                              value: selectedIds.contains(child.id),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedIds.add(child.id);
                                  } else {
                                    selectedIds.remove(child.id);
                                  }
                                });
                              },
                              title: Text(child.name),
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
                    FilledButton(
                      onPressed:
                          selectedIds.isEmpty
                              ? null
                              : () => Navigator.pop(
                                context,
                                children
                                    .where(
                                      (child) => selectedIds.contains(child.id),
                                    )
                                    .toList(),
                              ),
                      child: Text(context.l10n.classroomHelperAssign),
                    ),
                  ],
                ),
          ),
    );

    if (targetChildren == null || targetChildren.isEmpty) return;

    final staff = widget.staffProfile!;
    try {
      await widget.firestoreService.assignCurrentClassroomHelperJob(
        job: job,
        children: targetChildren,
        staffId: staff.id,
        staffName: staff.name,
      );
      if (!mounted) return;
      _message(context.l10n.classroomHelperAssigned);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _requestFinish(ClassroomHelperAssignment assignment) async {
    try {
      await widget.firestoreService.requestCurrentClassroomHelperCompletion(
        assignment: assignment,
      );
      if (!mounted) return;
      _message(context.l10n.classroomHelperRequestSent);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _confirmRequest(ClassroomHelperCompletionRequest request) async {
    final staff = widget.staffProfile!;
    try {
      await widget.firestoreService.confirmCurrentClassroomHelperRequest(
        request: request,
        staffId: staff.id,
        staffName: staff.name,
      );
      if (!mounted) return;
      _message(context.l10n.classroomHelperConfirmed);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _clearRequest(ClassroomHelperCompletionRequest request) async {
    final staff = widget.staffProfile!;
    try {
      await widget.firestoreService.clearCurrentClassroomHelperRequest(
        request: request,
        staffId: staff.id,
        staffName: staff.name,
      );
      if (!mounted) return;
      _message(context.l10n.classroomHelperRequestCleared);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _clearAssignment(String childId) async {
    try {
      await widget.firestoreService.clearCurrentClassroomHelperAssignment(
        childId,
      );
      if (!mounted) return;
      _message(context.l10n.classroomHelperAssignmentCleared);
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  Future<void> _toggleJob(ClassroomHelperJob job, bool active) async {
    try {
      await widget.firestoreService.updateCurrentClassroomHelperJob(
        job.copyWith(active: active),
      );
    } catch (error) {
      if (!mounted) return;
      _message(context.l10n.classroomHelperSaveFailed(error));
    }
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return context.l10n.classroomHelperJustNow;
    final minutes = DateTime.now().difference(date).inMinutes;
    if (minutes < 1) return context.l10n.classroomHelperJustNow;
    if (minutes == 1) return context.l10n.classroomHelperMinuteAgo;
    if (minutes < 60) return context.l10n.classroomHelperMinutesAgo(minutes);
    final hours = minutes ~/ 60;
    if (hours == 1) return context.l10n.classroomHelperHourAgo;
    if (hours < 24) return context.l10n.classroomHelperHoursAgo(hours);
    final days = hours ~/ 24;
    if (days == 1) return context.l10n.classroomHelperDayAgo;
    return context.l10n.classroomHelperDaysAgo(days);
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.classroomHelper)),
      floatingActionButton:
          widget.isStaffMode
              ? FloatingActionButton.extended(
                onPressed: () => _showJobDialog(),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.classroomHelperAddJob),
              )
              : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7E6), Color(0xFFEAF7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            widget.isStaffMode
                ? _buildStaffBody()
                : _buildChildBody(widget.child!),
      ),
    );
  }

  Widget _buildChildBody(ChildProfile child) {
    return StreamBuilder<ClassroomHelperAssignment?>(
      stream: widget.firestoreService
          .getCurrentClassroomHelperAssignmentForChild(child.id),
      builder: (context, assignmentSnapshot) {
        if (!assignmentSnapshot.hasData &&
            assignmentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignment = assignmentSnapshot.data;
        if (assignment == null) {
          return _ChildEmptyState(childName: child.name);
        }

        return StreamBuilder<ClassroomHelperCompletionRequest?>(
          stream: widget.firestoreService
              .getCurrentPendingClassroomHelperRequestForChild(child.id),
          builder: (context, requestSnapshot) {
            final hasPendingRequest = requestSnapshot.data != null;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _AssignedJobCard(
                    assignment: assignment,
                    hasPendingRequest: hasPendingRequest,
                    onRequestFinish: () => _requestFinish(assignment),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffBody() {
    return StreamBuilder<List<ClassroomHelperJob>>(
      stream: widget.firestoreService.getCurrentClassroomHelperJobs(),
      builder: (context, jobsSnapshot) {
        if (jobsSnapshot.hasError) {
          return _CenteredMessage(
            icon: Icons.error_outline_rounded,
            title: context.l10n.classroomHelperLoadFailed,
            subtitle: jobsSnapshot.error.toString(),
          );
        }
        if (!jobsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = jobsSnapshot.data!;
        final usingPreviewJobs = _usingPreviewJobs(jobs);

        return StreamBuilder<List<ChildProfile>>(
          stream: widget.firestoreService.getCurrentChildProfiles(),
          builder: (context, childrenSnapshot) {
            final children = childrenSnapshot.data ?? const <ChildProfile>[];

            return StreamBuilder<List<ClassroomHelperAssignment>>(
              stream:
                  widget.firestoreService
                      .getCurrentClassroomHelperAssignments(),
              builder: (context, assignmentsSnapshot) {
                final assignments =
                    assignmentsSnapshot.data ??
                    const <ClassroomHelperAssignment>[];

                return StreamBuilder<List<ClassroomHelperCompletionRequest>>(
                  stream:
                      widget.firestoreService
                          .getCurrentPendingClassroomHelperRequests(),
                  builder: (context, requestsSnapshot) {
                    final requests =
                        requestsSnapshot.data ??
                        const <ClassroomHelperCompletionRequest>[];

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _HeroHeader(
                          title: context.l10n.classroomHelperStaffTitle,
                          subtitle: context.l10n.classroomHelperStaffIntro,
                          icon: Icons.volunteer_activism_rounded,
                        ),
                        const SizedBox(height: 18),
                        if (usingPreviewJobs)
                          _StarterJobsBanner(
                            isSaving: _isSavingDefaults,
                            onSave: _saveStarterJobs,
                          ),
                        _PendingRequestsPanel(
                          requests: requests,
                          timeLabel: _timeLabel,
                          onConfirm: _confirmRequest,
                          onClear: _clearRequest,
                        ),
                        const SizedBox(height: 18),
                        _AssignmentsPanel(
                          children: children,
                          assignments: assignments,
                          onClearAssignment: _clearAssignment,
                        ),
                        const SizedBox(height: 18),
                        _JobLibraryPanel(
                          jobs: jobs,
                          isPreview: usingPreviewJobs,
                          children: children,
                          onAddJob: () => _showJobDialog(),
                          onEditJob: _showJobDialog,
                          onDeleteJob: _deleteJob,
                          onToggleJob: _toggleJob,
                          onAssignJob:
                              (job) => _assignJob(job: job, children: children),
                        ),
                        const SizedBox(height: 18),
                        _CompletedLogPanel(
                          stream:
                              widget.firestoreService
                                  .getCurrentClassroomHelperCompletions(),
                          children: children,
                          selectedChildId: _completionChildFilter,
                          onFilterChanged:
                              (value) => setState(
                                () => _completionChildFilter = value,
                              ),
                          timeLabel: _timeLabel,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  bool _usingPreviewJobs(List<ClassroomHelperJob> jobs) {
    if (jobs.length != defaultClassroomHelperJobs.length) return false;
    final defaultIds = defaultClassroomHelperJobs.map((job) => job.id).toSet();
    return jobs.every((job) => defaultIds.contains(job.id));
  }
}

class _ChildEmptyState extends StatelessWidget {
  final String childName;

  const _ChildEmptyState({required this.childName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(36),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volunteer_activism_rounded,
                size: 86,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.classroomHelperNoAssignedJobTitle(childName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.classroomHelperNoAssignedJobMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedJobCard extends StatelessWidget {
  final ClassroomHelperAssignment assignment;
  final bool hasPendingRequest;
  final VoidCallback onRequestFinish;

  const _AssignedJobCard({
    required this.assignment,
    required this.hasPendingRequest,
    required this.onRequestFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.classroomHelperMyJobToday,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              appIconForKey(assignment.jobIconName, fallbackKey: 'star'),
              color: const Color(0xFFE65100),
              size: 74,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            assignment.jobTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            assignment.jobDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          if (hasPendingRequest)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: Colors.blue),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      context.l10n.classroomHelperWaitingForTeacher,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton.icon(
              onPressed: onRequestFinish,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 18,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              icon: const Icon(Icons.help_rounded),
              label: Text(context.l10n.classroomHelperDidIFinish),
            ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: const Color(0xFFE65100), size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
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

class _StarterJobsBanner extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _StarterJobsBanner({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFE65100)),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.classroomHelperStarterJobsPreview)),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            child:
                isSaving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(context.l10n.classroomHelperSaveStarterJobs),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsPanel extends StatelessWidget {
  final List<ClassroomHelperCompletionRequest> requests;
  final String Function(DateTime?) timeLabel;
  final ValueChanged<ClassroomHelperCompletionRequest> onConfirm;
  final ValueChanged<ClassroomHelperCompletionRequest> onClear;

  const _PendingRequestsPanel({
    required this.requests,
    required this.timeLabel,
    required this.onConfirm,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.notification_important_rounded,
            title: context.l10n.classroomHelperPendingRequests,
            subtitle: context.l10n.classroomHelperPendingRequestsSubtitle,
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            Text(context.l10n.classroomHelperNoPendingRequests)
          else
            ...requests.map(
              (request) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      appIconForKey(request.jobIconName, fallbackKey: 'star'),
                    ),
                  ),
                  title: Text(
                    context.l10n.classroomHelperFinishRequestLine(
                      request.childName,
                      request.jobTitle,
                    ),
                  ),
                  subtitle: Text(timeLabel(request.requestedAt)),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => onClear(request),
                        child: Text(context.l10n.classroomHelperNotYet),
                      ),
                      FilledButton(
                        onPressed: () => onConfirm(request),
                        child: Text(context.l10n.classroomHelperConfirm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignmentsPanel extends StatelessWidget {
  final List<ChildProfile> children;
  final List<ClassroomHelperAssignment> assignments;
  final ValueChanged<String> onClearAssignment;

  const _AssignmentsPanel({
    required this.children,
    required this.assignments,
    required this.onClearAssignment,
  });

  @override
  Widget build(BuildContext context) {
    final assignmentsByChild = <String, List<ClassroomHelperAssignment>>{};
    for (final assignment in assignments) {
      assignmentsByChild
          .putIfAbsent(assignment.childId, () => [])
          .add(assignment);
    }

    for (final childAssignments in assignmentsByChild.values) {
      childAssignments.sort((first, second) {
        final firstDate =
            first.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.assignedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return firstDate.compareTo(secondDate);
      });
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.assignment_ind_rounded,
            title: context.l10n.classroomHelperCurrentAssignments,
            subtitle: context.l10n.classroomHelperOneJobPerChild,
          ),
          const SizedBox(height: 12),
          if (children.isEmpty)
            Text(context.l10n.noChildProfilesFound)
          else
            ...children.map((child) {
              final childAssignments =
                  assignmentsByChild[child.id] ??
                  const <ClassroomHelperAssignment>[];
              final assignment =
                  childAssignments.isEmpty ? null : childAssignments.first;
              final queuedCount =
                  childAssignments.isEmpty ? 0 : childAssignments.length - 1;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFFFFB300,
                  ).withValues(alpha: 0.15),
                  child:
                      assignment == null
                          ? const Icon(Icons.person_rounded)
                          : Icon(
                            appIconForKey(
                              assignment.jobIconName,
                              fallbackKey: 'star',
                            ),
                          ),
                ),
                title: Text(child.name),
                subtitle: Text(
                  assignment == null
                      ? context.l10n.classroomHelperNoJobAssigned
                      : queuedCount == 0
                      ? assignment.jobTitle
                      : '${assignment.jobTitle} • ${context.l10n.classroomHelperQueuedJobs(queuedCount)}',
                ),
                trailing:
                    assignment == null
                        ? null
                        : TextButton.icon(
                          onPressed: () => onClearAssignment(assignment.id),
                          icon: const Icon(Icons.clear_rounded),
                          label: Text(context.l10n.classroomHelperClearJob),
                        ),
              );
            }),
        ],
      ),
    );
  }
}

class _JobLibraryPanel extends StatelessWidget {
  final List<ClassroomHelperJob> jobs;
  final bool isPreview;
  final List<ChildProfile> children;
  final VoidCallback onAddJob;
  final ValueChanged<ClassroomHelperJob> onEditJob;
  final ValueChanged<ClassroomHelperJob> onDeleteJob;
  final void Function(ClassroomHelperJob job, bool active) onToggleJob;
  final ValueChanged<ClassroomHelperJob> onAssignJob;

  const _JobLibraryPanel({
    required this.jobs,
    required this.isPreview,
    required this.children,
    required this.onAddJob,
    required this.onEditJob,
    required this.onDeleteJob,
    required this.onToggleJob,
    required this.onAssignJob,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PanelTitle(
                  icon: Icons.workspaces_rounded,
                  title: context.l10n.classroomHelperJobLibrary,
                  subtitle: context.l10n.classroomHelperJobLibrarySubtitle,
                ),
              ),
              FilledButton.icon(
                onPressed: onAddJob,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.classroomHelperAddJob),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (jobs.isEmpty)
            Text(context.l10n.classroomHelperNoJobs)
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  jobs.map((job) {
                    return SizedBox(
                      width: 340,
                      child: _StaffJobCard(
                        job: job,
                        canAssign: !isPreview && children.isNotEmpty,
                        onAssign: () => onAssignJob(job),
                        onEdit: isPreview ? null : () => onEditJob(job),
                        onDelete: isPreview ? null : () => onDeleteJob(job),
                        onToggle:
                            isPreview
                                ? null
                                : (active) => onToggleJob(job, active),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}

class _StaffJobCard extends StatelessWidget {
  final ClassroomHelperJob job;
  final bool canAssign;
  final VoidCallback onAssign;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggle;

  const _StaffJobCard({
    required this.job,
    required this.canAssign,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                appIconForKey(job.iconName, fallbackKey: 'star'),
                color: job.active ? const Color(0xFFE65100) : Colors.grey,
                size: 34,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch(value: job.active, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 8),
          Text(job.description),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: job.active && canAssign ? onAssign : null,
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: Text(context.l10n.classroomHelperAssign),
                ),
              ),
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: context.l10n.delete,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedLogPanel extends StatelessWidget {
  final Stream<List<ClassroomHelperCompletion>> stream;
  final List<ChildProfile> children;
  final String selectedChildId;
  final ValueChanged<String> onFilterChanged;
  final String Function(DateTime?) timeLabel;

  const _CompletedLogPanel({
    required this.stream,
    required this.children,
    required this.selectedChildId,
    required this.onFilterChanged,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: StreamBuilder<List<ClassroomHelperCompletion>>(
        stream: stream,
        builder: (context, snapshot) {
          final allCompletions =
              snapshot.data ?? const <ClassroomHelperCompletion>[];
          final completions =
              selectedChildId.isEmpty
                  ? allCompletions
                  : allCompletions
                      .where(
                        (completion) => completion.childId == selectedChildId,
                      )
                      .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelTitle(
                icon: Icons.history_rounded,
                title: context.l10n.classroomHelperCompletedLog,
                subtitle: context.l10n.classroomHelperCompletedLogSubtitle,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedChildId,
                decoration: InputDecoration(
                  labelText: context.l10n.classroomHelperFilterByChild,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(context.l10n.classroomHelperAllChildren),
                  ),
                  ...children.map(
                    (child) => DropdownMenuItem(
                      value: child.id,
                      child: Text(child.name),
                    ),
                  ),
                ],
                onChanged: (value) => onFilterChanged(value ?? ''),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (completions.isEmpty)
                Text(context.l10n.classroomHelperNoRecentHelp)
              else
                ...completions.map(
                  (completion) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(
                        appIconForKey(
                          completion.jobIconName,
                          fallbackKey: 'star',
                        ),
                      ),
                    ),
                    title: Text(
                      context.l10n.classroomHelperCompletionLine(
                        completion.childName,
                        completion.jobTitle,
                      ),
                    ),
                    subtitle: Text(
                      '${timeLabel(completion.confirmedAt ?? completion.createdAt)} • ${context.l10n.classroomHelperConfirmedBy(completion.confirmedByStaffName)}',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE65100)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.grey.shade600),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
