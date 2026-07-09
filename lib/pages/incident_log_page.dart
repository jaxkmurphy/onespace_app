import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/incident_log_entry.dart';
import '../models/parent_report_draft.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../widgets/parent_report_dialog.dart';

enum IncidentLogMode { create, view }

class IncidentLogPage extends StatefulWidget {
  final StaffProfile staffProfile;

  const IncidentLogPage({super.key, required this.staffProfile});

  @override
  State<IncidentLogPage> createState() => _IncidentLogPageState();
}

class _IncidentLogPageState extends State<IncidentLogPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  IncidentLogMode _mode = IncidentLogMode.create;

  String? _selectedChildId;
  String _selectedSeverity = 'Low';
  String _selectedCategory = 'other';
  String _selectedFollowUp = 'none';

  String _severityFilter = 'All';
  String _selectedChildFilter = 'all';
  bool _showArchived = false;

  DateTime? _selectedDateTime;
  bool _isSaving = false;
  final Set<String> _preparingReportIds = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    _actionController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final material = MaterialLocalizations.of(context);

    return '${material.formatMediumDate(date)} • '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'High':
        return context.l10n.high;
      case 'Medium':
        return context.l10n.medium;
      default:
        return context.l10n.low;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'behaviour':
        return context.l10n.behaviour;
      case 'injury':
        return context.l10n.injury;
      case 'safety':
        return context.l10n.safety;
      case 'emotional':
        return context.l10n.emotional;
      default:
        return context.l10n.other;
    }
  }

  String _followUpLabel(String status) {
    switch (status) {
      case 'required':
        return context.l10n.followUpRequired;
      case 'completed':
        return context.l10n.followUpCompleted;
      default:
        return context.l10n.noFollowUp;
    }
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red.shade700;
      case 'Medium':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'High':
        return Icons.priority_high_rounded;
      case 'Medium':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          _selectedDateTime == null
              ? TimeOfDay.now()
              : TimeOfDay.fromDateTime(_selectedDateTime!),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveIncident(List<ChildProfile> children) async {
    if (_selectedChildId == null) {
      _showMessage(context.l10n.pleaseSelectChild);
      return;
    }

    final description = _descriptionController.text.trim();
    final action = _actionController.text.trim();

    if (description.isEmpty || action.isEmpty) {
      _showMessage(context.l10n.enterIncidentDetails);
      return;
    }

    final selectedChild = children.firstWhere(
      (child) => child.id == _selectedChildId,
    );

    setState(() {
      _isSaving = true;
    });

    final incident = IncidentLogEntry(
      id: '',
      childId: selectedChild.id,
      childName: selectedChild.name,
      timestamp: _selectedDateTime ?? DateTime.now(),
      description: description,
      actionTaken: action,
      severity: _selectedSeverity,
      category: _selectedCategory,
      staffId: widget.staffProfile.id,
      staffName: widget.staffProfile.name,
      followUpStatus: _selectedFollowUp,
      followUpNotes: _followUpController.text.trim(),
    );

    try {
      await _firestoreService.addCurrentIncidentLogEntry(incident);

      if (!mounted) return;

      _descriptionController.clear();
      _actionController.clear();
      _followUpController.clear();

      setState(() {
        _selectedChildId = null;
        _selectedSeverity = 'Low';
        _selectedCategory = 'other';
        _selectedFollowUp = 'none';
        _selectedDateTime = null;
        _isSaving = false;
        _mode = IncidentLogMode.view;
      });

      _showMessage(context.l10n.incidentSaved);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(context.l10n.incidentSaveFailed);
    }
  }

  Future<void> _editIncident(IncidentLogEntry incident) async {
    final updated = await showDialog<IncidentLogEntry>(
      context: context,
      builder: (_) => _IncidentEditDialog(incident: incident),
    );

    if (updated == null) return;

    try {
      await _firestoreService.updateCurrentIncidentLogEntry(
        entry: updated,
        updatedByStaffId: widget.staffProfile.id,
        updatedByStaffName: widget.staffProfile.name,
      );

      if (!mounted) return;
      _showMessage(context.l10n.incidentUpdated);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.incidentSaveFailed);
    }
  }

  Future<void> _archiveIncident(IncidentLogEntry incident) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.archiveIncidentQuestion),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.archiveIncidentMessage(incident.childName)),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.archiveReason,
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
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () {
                final value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(dialogContext, value);
              },
              child: Text(context.l10n.archiveIncident),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null) return;

    try {
      await _firestoreService.archiveCurrentIncidentLogEntry(
        incidentId: incident.id,
        reason: reason,
        staffId: widget.staffProfile.id,
        staffName: widget.staffProfile.name,
      );

      if (!mounted) return;
      _showMessage(context.l10n.incidentArchived);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.incidentArchiveFailed);
    }
  }

  ParentReportDraft _buildParentReportDraft(IncidentLogEntry incident) {
    final staffName =
        incident.staffName.trim().isEmpty
            ? context.l10n.staffLabel
            : incident.staffName.trim();

    final buffer =
        StringBuffer()
          ..writeln(context.l10n.parentReportGreeting)
          ..writeln()
          ..writeln(context.l10n.parentReportIncidentIntro(incident.childName))
          ..writeln()
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.child,
              incident.childName,
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.reportDate,
              _formatDate(incident.timestamp),
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.incidentCategory,
              _categoryLabel(incident.category),
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.severity,
              _severityLabel(incident.severity),
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.description,
              incident.description.trim(),
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.actionTaken,
              incident.actionTaken.trim(),
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.loggedByLabel,
              staffName,
            ),
          )
          ..writeln(
            context.l10n.parentReportLine(
              context.l10n.followUpStatusLabel,
              _followUpLabel(incident.followUpStatus),
            ),
          );

    if (incident.followUpNotes.trim().isNotEmpty) {
      buffer.writeln(
        context.l10n.parentReportLine(
          context.l10n.followUpNotes,
          incident.followUpNotes.trim(),
        ),
      );
    }

    buffer
      ..writeln()
      ..writeln(context.l10n.parentReportFooter);

    return ParentReportDraft(
      type: 'incident',
      sourceId: incident.id,
      childId: incident.childId,
      childName: incident.childName,
      subject: context.l10n.incidentParentReportSubject(incident.childName),
      body: buffer.toString(),
    );
  }

  Future<void> _prepareParentReport(IncidentLogEntry incident) async {
    if (_preparingReportIds.contains(incident.id)) return;

    setState(() => _preparingReportIds.add(incident.id));

    try {
      await _firestoreService.restoreClassroomSessionFromAuthIfNeeded();

      if (!_firestoreService.session.hasClassroomSession) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.parentReportsNeedClassroom)),
        );
        return;
      }

      final schoolId = _firestoreService.session.requireSchoolId;
      final classroomId = _firestoreService.session.requireClassroomId;
      final recipients =
          await _firestoreService
              .getGuardianContactsForChild(
                schoolId: schoolId,
                classroomId: classroomId,
                childId: incident.childId,
              )
              .first;

      final availableRecipients =
          recipients
              .where((contact) => contact.active && contact.canReceiveReports)
              .toList();

      if (!mounted) return;

      if (availableRecipients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.noGuardianReportContacts)),
        );
        return;
      }

      final draft = _buildParentReportDraft(incident);

      await showDialog<void>(
        context: context,
        builder: (context) {
          return ParentReportDialog(
            draft: draft,
            recipients: availableRecipients,
            onPrepared: (recipient) {
              return _firestoreService.addCurrentParentReportPreparation(
                reportType: draft.type,
                sourceId: draft.sourceId,
                childId: draft.childId,
                childName: draft.childName,
                recipientContactId: recipient.id,
                recipientName: recipient.name,
                recipientEmail: recipient.email,
                preparedByStaffId: widget.staffProfile.id,
                preparedByStaffName:
                    widget.staffProfile.name.trim().isEmpty
                        ? context.l10n.staffLabel
                        : widget.staffProfile.name.trim(),
              );
            },
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.parentReportPrepareFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _preparingReportIds.remove(incident.id));
      }
    }
  }

  Widget _buildModeSelector() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          selected: _mode == IncidentLogMode.create,
          avatar: const Icon(Icons.add_rounded),
          label: Text(context.l10n.createIncident),
          onSelected: (_) {
            setState(() {
              _mode = IncidentLogMode.create;
            });
          },
        ),
        ChoiceChip(
          selected: _mode == IncidentLogMode.view,
          avatar: const Icon(Icons.list_alt_rounded),
          label: Text(context.l10n.viewIncidents),
          onSelected: (_) {
            setState(() {
              _mode = IncidentLogMode.view;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCreateSection(List<ChildProfile> children) {
    return _IncidentSection(
      icon: Icons.add_task_rounded,
      title: context.l10n.createIncident,
      color: const Color(0xFF7E57C2),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedChildId,
            decoration: InputDecoration(
              labelText: context.l10n.selectChild,
              prefixIcon: const Icon(Icons.person_search_rounded),
              border: const OutlineInputBorder(),
            ),
            items:
                children.map((child) {
                  return DropdownMenuItem(
                    value: child.id,
                    child: Text(child.name),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedChildId = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedSeverity,
                  decoration: InputDecoration(
                    labelText: context.l10n.severity,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Low',
                      child: Text(context.l10n.low),
                    ),
                    DropdownMenuItem(
                      value: 'Medium',
                      child: Text(context.l10n.medium),
                    ),
                    DropdownMenuItem(
                      value: 'High',
                      child: Text(context.l10n.high),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedSeverity = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: context.l10n.incidentCategory,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'behaviour',
                      child: Text(context.l10n.behaviour),
                    ),
                    DropdownMenuItem(
                      value: 'injury',
                      child: Text(context.l10n.injury),
                    ),
                    DropdownMenuItem(
                      value: 'safety',
                      child: Text(context.l10n.safety),
                    ),
                    DropdownMenuItem(
                      value: 'emotional',
                      child: Text(context.l10n.emotional),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.l10n.other),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDateTime,
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text(
              _selectedDateTime == null
                  ? context.l10n.useCurrentTime
                  : context.l10n.manualTime(_formatDate(_selectedDateTime!)),
            ),
          ),
          if (_selectedDateTime != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDateTime = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.resetToCurrentTime),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: context.l10n.description,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _actionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: context.l10n.actionTaken,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedFollowUp,
            decoration: InputDecoration(
              labelText: context.l10n.followUp,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'none',
                child: Text(context.l10n.noFollowUp),
              ),
              DropdownMenuItem(
                value: 'required',
                child: Text(context.l10n.followUpRequired),
              ),
              DropdownMenuItem(
                value: 'completed',
                child: Text(context.l10n.followUpCompleted),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedFollowUp = value;
              });
            },
          ),
          if (_selectedFollowUp != 'none') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _followUpController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.followUpNotes,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : () => _saveIncident(children),
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.save_rounded),
              label: Text(
                _isSaving ? context.l10n.saving : context.l10n.saveIncident,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<IncidentLogEntry> _filterIncidents(List<IncidentLogEntry> incidents) {
    return incidents.where((incident) {
      if (incident.isArchived != _showArchived) return false;

      if (_severityFilter != 'All' && incident.severity != _severityFilter) {
        return false;
      }

      if (_selectedChildFilter != 'all' &&
          incident.childId != _selectedChildFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildViewSection(List<ChildProfile> children) {
    return StreamBuilder<List<IncidentLogEntry>>(
      stream: _firestoreService.getCurrentIncidentLogEntries(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _IncidentMessageState(
            icon: Icons.cloud_off_rounded,
            message: context.l10n.error,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = _filterIncidents(snapshot.data!);

        return Column(
          children: [
            _IncidentSection(
              icon:
                  _showArchived
                      ? Icons.archive_rounded
                      : Icons.list_alt_rounded,
              title:
                  _showArchived
                      ? context.l10n.archivedIncidents
                      : context.l10n.viewIncidents,
              color: const Color(0xFF42A5F5),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ChoiceChip(
                        selected: !_showArchived,
                        label: Text(context.l10n.viewIncidents),
                        avatar: const Icon(Icons.list_alt_rounded),
                        onSelected: (_) {
                          setState(() {
                            _showArchived = false;
                          });
                        },
                      ),
                      ChoiceChip(
                        selected: _showArchived,
                        label: Text(context.l10n.archivedIncidents),
                        avatar: const Icon(Icons.archive_rounded),
                        onSelected: (_) {
                          setState(() {
                            _showArchived = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _severityFilter,
                          decoration: InputDecoration(
                            labelText: context.l10n.severity,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text(context.l10n.all),
                            ),
                            DropdownMenuItem(
                              value: 'Low',
                              child: Text(context.l10n.low),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text(context.l10n.medium),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text(context.l10n.high),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _severityFilter = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedChildFilter,
                          decoration: InputDecoration(
                            labelText: context.l10n.filterByChild,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(context.l10n.all),
                            ),
                            ...children.map(
                              (child) => DropdownMenuItem(
                                value: child.id,
                                child: Text(child.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedChildFilter = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.incidentsShown(filtered.length),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _IncidentMessageState(
                icon: Icons.search_off_rounded,
                message:
                    snapshot.data!.isEmpty
                        ? context.l10n.noIncidents
                        : context.l10n.noMatchingIncidents,
              )
            else
              ...filtered.map(_buildIncidentCard),
          ],
        );
      },
    );
  }

  Widget _buildIncidentCard(IncidentLogEntry incident) {
    final severityColor = _severityColor(incident.severity);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: severityColor.withValues(alpha: 0.28),
          width: 2,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          foregroundColor: Colors.white,
          child: Icon(_severityIcon(incident.severity)),
        ),
        title: Text(
          incident.childName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(_formatDate(incident.timestamp)),
        trailing:
            incident.isArchived
                ? const Icon(Icons.archive_rounded)
                : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editIncident(incident);
                    } else if (value == 'archive') {
                      _archiveIncident(incident);
                    } else if (value == 'parent_report') {
                      _prepareParentReport(incident);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'parent_report',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.email_outlined),
                            title: Text(context.l10n.prepareParentReport),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.edit_rounded),
                            title: Text(context.l10n.editIncident),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'archive',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.archive_outlined),
                            title: Text(context.l10n.archiveIncident),
                          ),
                        ),
                      ],
                ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _IncidentChip(
                      icon: _severityIcon(incident.severity),
                      label: context.l10n.severityLabel(
                        _severityLabel(incident.severity),
                      ),
                      color: severityColor,
                    ),
                    _IncidentChip(
                      icon: Icons.category_rounded,
                      label: _categoryLabel(incident.category),
                      color: const Color(0xFF7E57C2),
                    ),
                    _IncidentChip(
                      icon: Icons.person_rounded,
                      label: context.l10n.loggedBy(incident.staffName),
                      color: const Color(0xFF42A5F5),
                    ),
                    _IncidentChip(
                      icon: Icons.follow_the_signs_rounded,
                      label: _followUpLabel(incident.followUpStatus),
                      color: const Color(0xFF26A69A),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _IncidentDetail(
                  title: context.l10n.description,
                  content: incident.description,
                ),
                _IncidentDetail(
                  title: context.l10n.actionTaken,
                  content: incident.actionTaken,
                ),
                if (incident.followUpNotes.isNotEmpty)
                  _IncidentDetail(
                    title: context.l10n.followUpNotes,
                    content: incident.followUpNotes,
                  ),
                if (incident.isArchived && incident.archiveReason.isNotEmpty)
                  _IncidentDetail(
                    title: context.l10n.archiveReason,
                    content: incident.archiveReason,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classroomName = _session.currentClassroomName;

    final title =
        _session.hasClassroomSession
            ? context.l10n.incidentLogClassroom(classroomName)
            : context.l10n.incidentLog;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _firestoreService.getCurrentChildProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _IncidentMessageState(
              icon: Icons.cloud_off_rounded,
              message: context.l10n.error,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data!;

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7F4FF), Color(0xFFF3F8FF)],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _IncidentHeader(
                  title: context.l10n.incidentLog,
                  description: context.l10n.incidentLogIntro,
                ),
                const SizedBox(height: 18),
                _buildModeSelector(),
                const SizedBox(height: 20),
                if (_mode == IncidentLogMode.create)
                  _buildCreateSection(children)
                else
                  _buildViewSection(children),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IncidentEditDialog extends StatefulWidget {
  final IncidentLogEntry incident;

  const _IncidentEditDialog({required this.incident});

  @override
  State<_IncidentEditDialog> createState() => _IncidentEditDialogState();
}

class _IncidentEditDialogState extends State<_IncidentEditDialog> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _actionController;
  late final TextEditingController _followUpController;

  late String _severity;
  late String _category;
  late String _followUpStatus;
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController(
      text: widget.incident.description,
    );
    _actionController = TextEditingController(
      text: widget.incident.actionTaken,
    );
    _followUpController = TextEditingController(
      text: widget.incident.followUpNotes,
    );

    _severity = widget.incident.severity;
    _category = widget.incident.category;
    _followUpStatus = widget.incident.followUpStatus;
    _timestamp = widget.incident.timestamp;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _actionController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );

    if (time == null || !mounted) return;

    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDate() {
    final material = MaterialLocalizations.of(context);

    return '${material.formatMediumDate(_timestamp)} • '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(_timestamp))}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editIncident),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.incident.childName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _severity,
                      decoration: InputDecoration(
                        labelText: context.l10n.severity,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Low',
                          child: Text(context.l10n.low),
                        ),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text(context.l10n.medium),
                        ),
                        DropdownMenuItem(
                          value: 'High',
                          child: Text(context.l10n.high),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _severity = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: context.l10n.incidentCategory,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'behaviour',
                          child: Text(context.l10n.behaviour),
                        ),
                        DropdownMenuItem(
                          value: 'injury',
                          child: Text(context.l10n.injury),
                        ),
                        DropdownMenuItem(
                          value: 'safety',
                          child: Text(context.l10n.safety),
                        ),
                        DropdownMenuItem(
                          value: 'emotional',
                          child: Text(context.l10n.emotional),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(context.l10n.other),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDateTime,
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(_formatDate()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: context.l10n.description,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _actionController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: context.l10n.actionTaken,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _followUpStatus,
                decoration: InputDecoration(
                  labelText: context.l10n.followUp,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'none',
                    child: Text(context.l10n.noFollowUp),
                  ),
                  DropdownMenuItem(
                    value: 'required',
                    child: Text(context.l10n.followUpRequired),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text(context.l10n.followUpCompleted),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _followUpStatus = value);
                  }
                },
              ),
              if (_followUpStatus != 'none') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _followUpController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.l10n.followUpNotes,
                    border: const OutlineInputBorder(),
                  ),
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
            final description = _descriptionController.text.trim();
            final action = _actionController.text.trim();

            if (description.isEmpty || action.isEmpty) return;

            Navigator.pop(
              context,
              widget.incident.copyWith(
                timestamp: _timestamp,
                description: description,
                actionTaken: action,
                severity: _severity,
                category: _category,
                followUpStatus: _followUpStatus,
                followUpNotes: _followUpController.text.trim(),
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

class _IncidentHeader extends StatelessWidget {
  final String title;
  final String description;

  const _IncidentHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF5C6BC0)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_late_rounded,
            color: Colors.white,
            size: 54,
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
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(description, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _IncidentSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.13),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _IncidentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _IncidentChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IncidentDetail extends StatelessWidget {
  final String title;
  final String content;

  const _IncidentDetail({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          SelectableText(content, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _IncidentMessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _IncidentMessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 68, color: const Color(0xFF7E57C2)),
            const SizedBox(height: 15),
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
