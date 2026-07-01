import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../models/child_profile.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import 'incident_log_page.dart';

class ClassroomDetailsPage extends StatefulWidget {
  final String schoolId;
  final String classroomId;

  const ClassroomDetailsPage({
    super.key,
    required this.schoolId,
    required this.classroomId,
  });

  @override
  State<ClassroomDetailsPage> createState() => _ClassroomDetailsPageState();
}

class _ClassroomDetailsPageState extends State<ClassroomDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();

  final _firestoreService = FirestoreService();
  final _session = ClassroomSessionService.instance;

  Classroom? _classroom;
  String _schoolCode = '';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSavingFeatures = false;
  bool _active = true;
  Set<ClassroomFeature> _enabledFeatures = ClassroomFeature.allEnabled();

  @override
  void initState() {
    super.initState();
    _loadClassroom();
  }

  Future<void> _loadClassroom() async {
    try {
      final classroom = await _firestoreService.getClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
      );
      final school = await _firestoreService.getSchool(widget.schoolId);

      if (!mounted) return;

      if (classroom == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.classroomNotFound)));
        Navigator.pop(context);
        return;
      }

      setState(() {
        _classroom = classroom;
        _schoolCode = school?.schoolCode ?? '';
        _nameController.text = classroom.name;
        _codeController.text = classroom.classroomCode;
        _pinController.text = classroom.pin;
        _active = classroom.active;
        _enabledFeatures = classroom.enabledFeatures;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.classroomLoadError(e.toString()))),
      );
    }
  }

  Future<void> _saveClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
        name: _nameController.text,
        classroomCode: _codeController.text,
        pin: _pinController.text,
        active: _active,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.classroomUpdated)));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('classroom code is already in use')
                ? context.l10n.classroomCodeInUse
                : context.l10n.classroomUpdateError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deactivateClassroom() async {
    final shouldDeactivate = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.deactivateClassroom),
            content: Text(context.l10n.deactivateClassroomConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.deactivate),
              ),
            ],
          ),
    );

    if (shouldDeactivate != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.deactivateClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.classroomDeactivated)),
      );

      setState(() {
        _active = false;
        _classroom = _classroom?.copyWith(active: false);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.classroomDeactivateError(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _reactivateClassroom() async {
    final shouldReactivate = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.reactivateClassroom),
            content: Text(context.l10n.reactivateClassroomConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.reactivate),
              ),
            ],
          ),
    );

    if (shouldReactivate != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.reactivateClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.classroomReactivated)),
      );

      setState(() {
        _active = true;
        _classroom = _classroom?.copyWith(active: true);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.classroomReactivateError(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyAllAccessDetails() async {
    final classroom = _classroom;
    if (classroom == null) return;

    final details = [
      '${context.l10n.schoolCode}: $_schoolCode',
      '${context.l10n.classroomCode}: ${classroom.classroomCode}',
      '${context.l10n.classroomPin}: ${classroom.pin}',
    ].join('\n');

    await _copyToClipboard(details, context.l10n.classroomAccessDetailsCopied);
  }

  void _openClassroomProfiles() {
    final classroom = _classroom;
    if (classroom == null) return;

    _session.setSession(
      schoolId: widget.schoolId,
      classroomId: widget.classroomId,
      classroomName: classroom.name,
    );

    Navigator.pushNamed(
      context,
      '/profiles',
      arguments: {
        'schoolId': widget.schoolId,
        'classroomId': widget.classroomId,
        'classroomName': classroom.name,
      },
    );
  }

  void _openClassroomRoute(String routeName) {
    final classroom = _classroom;
    if (classroom == null) return;

    _session.setSession(
      schoolId: widget.schoolId,
      classroomId: widget.classroomId,
      classroomName: classroom.name,
    );

    Navigator.pushNamed(context, routeName);
  }

  void _openBodyCheckOverview() {
    final classroom = _classroom;
    if (classroom == null) return;

    _session.setSession(
      schoolId: widget.schoolId,
      classroomId: widget.classroomId,
      classroomName: classroom.name,
    );

    Navigator.pushNamed(
      context,
      '/body-check-overview',
      arguments: {
        'firestoreService': _firestoreService,
        'teacherUid': widget.classroomId,
      },
    );
  }

  void _openIncidentLog() {
    final classroom = _classroom;
    if (classroom == null) return;

    _session.setSession(
      schoolId: widget.schoolId,
      classroomId: widget.classroomId,
      classroomName: classroom.name,
    );

    final adminProfile = StaffProfile(
      id: 'school-admin',
      name: context.l10n.schoolAdminStaffName,
      role: context.l10n.schoolAdminStaffName,
      teacherUid: widget.classroomId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentLogPage(staffProfile: adminProfile),
      ),
    );
  }

  Future<void> _setFeatureEnabled({
    required ClassroomFeature feature,
    required bool enabled,
  }) async {
    final previousFeatures = Set<ClassroomFeature>.from(_enabledFeatures);
    final updatedFeatures = Set<ClassroomFeature>.from(_enabledFeatures);

    if (enabled) {
      updatedFeatures.add(feature);
    } else {
      updatedFeatures.remove(feature);
    }

    setState(() {
      _enabledFeatures = updatedFeatures;
      _isSavingFeatures = true;
    });

    try {
      await _firestoreService.updateClassroomEnabledFeatures(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
        enabledFeatures: updatedFeatures,
      );

      if (!mounted) return;

      setState(() {
        _classroom = _classroom?.copyWith(enabledFeatures: updatedFeatures);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _enabledFeatures = previousFeatures;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update classroom features: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFeatures = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classroom = _classroom;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.classroomDetails)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : classroom == null
              ? Center(child: Text(context.l10n.classroomNotFound))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 840),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ClassroomOverviewCard(
                          classroom: classroom,
                          firestoreService: _firestoreService,
                          schoolId: widget.schoolId,
                          classroomId: widget.classroomId,
                          schoolCode: _schoolCode,
                          onCopyAllAccessDetails: _copyAllAccessDetails,
                          onOpenProfiles: _openClassroomProfiles,
                          onOpenSchedule:
                              () => _openClassroomRoute('/staffSchedule'),
                          onOpenZones:
                              () => _openClassroomRoute('/zone-overview'),
                          onOpenBodyChecks: _openBodyCheckOverview,
                          onOpenIncidents: _openIncidentLog,
                          onCopySchoolCode:
                              () => _copyToClipboard(
                                _schoolCode,
                                context.l10n.schoolCodeCopied,
                              ),
                          onCopyClassroomCode:
                              () => _copyToClipboard(
                                classroom.classroomCode,
                                context.l10n.classroomCodeCopied,
                              ),
                          onCopyClassroomPin:
                              () => _copyToClipboard(
                                classroom.pin,
                                context.l10n.classroomPinCopied,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _FeatureSettingsCard(
                          enabledFeatures: _enabledFeatures,
                          isSaving: _isSavingFeatures,
                          onFeatureChanged: (feature, enabled) {
                            _setFeatureEnabled(
                              feature: feature,
                              enabled: enabled,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildEditCard(classroom),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildEditCard(Classroom classroom) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.classroomInformation,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(context.l10n.classroomAccessInfo),

              const SizedBox(height: 22),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.classroomName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.enterClassroomName;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: context.l10n.classroomCode,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.enterClassroomCode;
                  }

                  if (value.trim().length < 3) {
                    return context.l10n.classroomCodeMinLength;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              Text(
                context.l10n.classroomCodeChangeInfo,
                style: const TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.classroomPin,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.enterClassroomPin;
                  }

                  if (value.trim().length < 4) {
                    return context.l10n.classroomPinMinLength;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                value: _active,
                title: Text(context.l10n.classroomActive),
                subtitle: Text(context.l10n.classroomInactiveInfo),
                onChanged:
                    _isSaving
                        ? null
                        : (value) {
                          setState(() {
                            _active = value;
                          });
                        },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? context.l10n.saving
                        : context.l10n.saveClassroom,
                  ),
                  onPressed: _isSaving ? null : _saveClassroom,
                ),
              ),

              const SizedBox(height: 12),

              if (classroom.active)
                OutlinedButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(context.l10n.deactivateClassroom),
                  onPressed: _isSaving ? null : _deactivateClassroom,
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(context.l10n.reactivateClassroom),
                  onPressed: _isSaving ? null : _reactivateClassroom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassroomOverviewCard extends StatelessWidget {
  final Classroom classroom;
  final FirestoreService firestoreService;
  final String schoolId;
  final String classroomId;
  final String schoolCode;
  final VoidCallback onCopyAllAccessDetails;
  final VoidCallback onOpenProfiles;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenZones;
  final VoidCallback onOpenBodyChecks;
  final VoidCallback onOpenIncidents;
  final VoidCallback onCopySchoolCode;
  final VoidCallback onCopyClassroomCode;
  final VoidCallback onCopyClassroomPin;

  const _ClassroomOverviewCard({
    required this.classroom,
    required this.firestoreService,
    required this.schoolId,
    required this.classroomId,
    required this.schoolCode,
    required this.onCopyAllAccessDetails,
    required this.onOpenProfiles,
    required this.onOpenSchedule,
    required this.onOpenZones,
    required this.onOpenBodyChecks,
    required this.onOpenIncidents,
    required this.onCopySchoolCode,
    required this.onCopyClassroomCode,
    required this.onCopyClassroomPin,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 650;

                final title = Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colourScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.meeting_room_rounded,
                        color: colourScheme.onPrimaryContainer,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classroom.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${context.l10n.classroomCode}: ${classroom.classroomCode}',
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final status = Align(
                  alignment:
                      isWide ? Alignment.centerRight : Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      classroom.active
                          ? Icons.check_circle_outline
                          : Icons.archive_outlined,
                      size: 18,
                    ),
                    label: Text(
                      classroom.active
                          ? context.l10n.active
                          : context.l10n.inactive,
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 16),
                      status,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 12), status],
                );
              },
            ),

            const SizedBox(height: 18),

            StreamBuilder<List<StaffProfile>>(
              stream: firestoreService.getClassroomStaffProfiles(
                schoolId: schoolId,
                classroomId: classroomId,
              ),
              builder: (context, staffSnapshot) {
                return StreamBuilder<List<ChildProfile>>(
                  stream: firestoreService.getClassroomChildProfiles(
                    schoolId: schoolId,
                    classroomId: classroomId,
                  ),
                  builder: (context, childSnapshot) {
                    final staffCount = staffSnapshot.data?.length ?? 0;
                    final childCount = childSnapshot.data?.length ?? 0;

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ClassroomStatChip(
                          icon: Icons.badge_outlined,
                          label: context.l10n.staffProfiles,
                          value: staffCount.toString(),
                        ),
                        _ClassroomStatChip(
                          icon: Icons.child_care_outlined,
                          label: context.l10n.childProfiles,
                          value: childCount.toString(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            Text(
              context.l10n.accessDetails,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (schoolCode.isNotEmpty) ...[
              _AccessDetailRow(
                icon: Icons.school_outlined,
                label: context.l10n.schoolCode,
                value: schoolCode,
                onCopy: onCopySchoolCode,
              ),
              const SizedBox(height: 8),
            ],
            _AccessDetailRow(
              icon: Icons.badge_outlined,
              label: context.l10n.classroomCode,
              value: classroom.classroomCode,
              onCopy: onCopyClassroomCode,
            ),
            const SizedBox(height: 8),
            _AccessDetailRow(
              icon: Icons.lock_outline,
              label: context.l10n.classroomPin,
              value: classroom.pin,
              onCopy: onCopyClassroomPin,
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                icon: const Icon(Icons.copy_all_rounded),
                label: Text(context.l10n.copyAllLoginDetails),
                onPressed: onCopyAllAccessDetails,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              context.l10n.quickActions,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickActionButton(
                  icon: Icons.groups_rounded,
                  label: context.l10n.profiles,
                  onPressed: onOpenProfiles,
                ),
                _QuickActionButton(
                  icon: Icons.schedule_rounded,
                  label: context.l10n.openSchedule,
                  onPressed: onOpenSchedule,
                ),
                _QuickActionButton(
                  icon: Icons.mood_rounded,
                  label: context.l10n.openZonesOverview,
                  onPressed: onOpenZones,
                ),
                _QuickActionButton(
                  icon: Icons.health_and_safety_outlined,
                  label: context.l10n.viewBodyCheckReports,
                  onPressed: onOpenBodyChecks,
                ),
                _QuickActionButton(
                  icon: Icons.warning_amber_rounded,
                  label: context.l10n.openIncidentLog,
                  onPressed: onOpenIncidents,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSettingsCard extends StatelessWidget {
  final Set<ClassroomFeature> enabledFeatures;
  final bool isSaving;
  final void Function(ClassroomFeature feature, bool enabled) onFeatureChanged;

  const _FeatureSettingsCard({
    required this.enabledFeatures,
    required this.isSaving,
    required this.onFeatureChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colourScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: colourScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classroom features',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Choose which tools are available in this classroom.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...ClassroomFeature.values.map((feature) {
              return SwitchListTile(
                value: enabledFeatures.contains(feature),
                onChanged:
                    isSaving
                        ? null
                        : (enabled) => onFeatureChanged(feature, enabled),
                title: Text(feature.adminLabel),
                subtitle: Text(feature.adminDescription),
                secondary: Icon(_iconForFeature(feature)),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _iconForFeature(ClassroomFeature feature) {
    switch (feature) {
      case ClassroomFeature.todayOverview:
        return Icons.dashboard_rounded;
      case ClassroomFeature.schedules:
        return Icons.schedule_rounded;
      case ClassroomFeature.zones:
        return Icons.mood_rounded;
      case ClassroomFeature.points:
        return Icons.star_rounded;
      case ClassroomFeature.whenThen:
        return Icons.view_kanban_rounded;
      case ClassroomFeature.visualTimer:
        return Icons.timer_rounded;
      case ClassroomFeature.bodyCheck:
        return Icons.health_and_safety_outlined;
      case ClassroomFeature.circleTime:
        return Icons.groups_rounded;
      case ClassroomFeature.quizzes:
        return Icons.quiz_rounded;
      case ClassroomFeature.associationPairs:
        return Icons.extension_rounded;
      case ClassroomFeature.numberSequence:
        return Icons.pin_rounded;
      case ClassroomFeature.oddOneOut:
        return Icons.psychology_alt_rounded;
      case ClassroomFeature.emotionDetective:
        return Icons.manage_search_rounded;
      case ClassroomFeature.wordLearning:
        return Icons.menu_book_rounded;
      case ClassroomFeature.incidentLog:
        return Icons.warning_amber_rounded;
      case ClassroomFeature.handover:
        return Icons.description_rounded;
      case ClassroomFeature.iconReset:
        return Icons.lock_reset_rounded;
      case ClassroomFeature.calmingSounds:
        return Icons.headphones_rounded;
      case ClassroomFeature.calmPlan:
        return Icons.spa_rounded;
      case ClassroomFeature.classroomHelper:
        return Icons.volunteer_activism_rounded;
      case ClassroomFeature.voiceLines:
        return Icons.record_voice_over_rounded;
      case ClassroomFeature.backgroundPicker:
        return Icons.palette_rounded;
    }
  }
}

class _AccessDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _AccessDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colourScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colourScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colourScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colourScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.copy,
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}

class _ClassroomStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ClassroomStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colourScheme.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colourScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color: colourScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
