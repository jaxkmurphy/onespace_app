import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/classroom.dart';
import '../models/classroom_feature.dart';
import '../models/school.dart';
import '../services/firestore/admin_firestore_service.dart';
import '../services/firestore_service.dart';

enum _ClassroomFilter { all, active, inactive }

class AdminDashboardPage extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const AdminDashboardPage({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirestoreService _firestoreService = FirestoreService();

  _ClassroomFilter _filter = _ClassroomFilter.all;

  List<Classroom> _filteredClassrooms(List<Classroom> classrooms) {
    return switch (_filter) {
      _ClassroomFilter.all => classrooms,
      _ClassroomFilter.active =>
        classrooms.where((classroom) => classroom.active).toList(),
      _ClassroomFilter.inactive =>
        classrooms.where((classroom) => !classroom.active).toList(),
    };
  }

  String _filterLabel(BuildContext context, _ClassroomFilter filter) {
    return switch (filter) {
      _ClassroomFilter.all => context.l10n.all,
      _ClassroomFilter.active => context.l10n.active,
      _ClassroomFilter.inactive => context.l10n.inactive,
    };
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.logout),
            content: Text(context.l10n.logoutConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.logout),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolFuture = _firestoreService.getSchool(widget.schoolId);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.schoolAdminTitle(widget.schoolName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: context.l10n.schoolSettings,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/school-settings',
                arguments: {'schoolId': widget.schoolId},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.logout,
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<School?>(
              future: schoolFuture,
              builder: (context, schoolSnapshot) {
                final school = schoolSnapshot.data;

                return StreamBuilder<List<Classroom>>(
                  stream: _firestoreService.getClassrooms(widget.schoolId),
                  builder: (context, classroomSnapshot) {
                    final classrooms = classroomSnapshot.data ?? [];
                    final classroomLimit = school?.classroomLimit ?? 3;
                    final usedClassrooms = classrooms.length;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school?.name ?? widget.schoolName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.schoolCodeValue(
                                school?.schoolCode ?? context.l10n.loading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.classroomsUsed(
                                usedClassrooms,
                                classroomLimit,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.statusValue(
                                (school?.active ?? true)
                                    ? context.l10n.active
                                    : context.l10n.inactive,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<SchoolAdminOverview>(
                              future: _firestoreService.getSchoolAdminOverview(
                                widget.schoolId,
                              ),
                              builder: (context, overviewSnapshot) {
                                if (!overviewSnapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final overview = overviewSnapshot.data!;

                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _AdminStatChip(
                                      icon: Icons.meeting_room_outlined,
                                      label: context.l10n.activeClassrooms,
                                      value:
                                          overview.activeClassrooms.toString(),
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.archive_outlined,
                                      label: context.l10n.inactiveClassrooms,
                                      value:
                                          overview.inactiveClassrooms
                                              .toString(),
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.badge_outlined,
                                      label: context.l10n.staffProfiles,
                                      value:
                                          overview.totalStaffProfiles
                                              .toString(),
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.child_care_outlined,
                                      label: context.l10n.childProfiles,
                                      value:
                                          overview.totalChildProfiles
                                              .toString(),
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.pending_actions_rounded,
                                      label: 'Body checks',
                                      value:
                                          overview.uncheckedBodyChecks
                                              .toString(),
                                      isAlert: overview.uncheckedBodyChecks > 0,
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.notifications_active_outlined,
                                      label: 'Calm requests',
                                      value:
                                          overview.activeCalmRequests
                                              .toString(),
                                      isAlert: overview.activeCalmRequests > 0,
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.volunteer_activism_outlined,
                                      label: 'Helper requests',
                                      value:
                                          overview.pendingHelperRequests
                                              .toString(),
                                      isAlert:
                                          overview.pendingHelperRequests > 0,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            _ClassroomFilterBar(
              selected: _filter,
              labelFor: (filter) => _filterLabel(context, filter),
              onChanged: (filter) {
                setState(() {
                  _filter = filter;
                });
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<Classroom>>(
                stream: _firestoreService.getClassrooms(widget.schoolId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        context.l10n.classroomsLoadError(
                          snapshot.error.toString(),
                        ),
                      ),
                    );
                  }

                  final classrooms = snapshot.data ?? [];
                  final filteredClassrooms = _filteredClassrooms(classrooms);

                  if (classrooms.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noClassroomsYet,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (filteredClassrooms.isEmpty) {
                    return Center(
                      child: Text(
                        '${_filterLabel(context, _filter)}: 0',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredClassrooms.length,
                    itemBuilder: (context, index) {
                      final classroom = filteredClassrooms[index];

                      return _ClassroomListCard(
                        classroom: classroom,
                        schoolId: widget.schoolId,
                        firestoreService: _firestoreService,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/classroom-details',
                            arguments: {
                              'schoolId': widget.schoolId,
                              'classroomId': classroom.id,
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addClassroom),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-classroom',
                    arguments: {'schoolId': widget.schoolId},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassroomFilterBar extends StatelessWidget {
  final _ClassroomFilter selected;
  final String Function(_ClassroomFilter filter) labelFor;
  final ValueChanged<_ClassroomFilter> onChanged;

  const _ClassroomFilterBar({
    required this.selected,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ClassroomFilter>(
      segments:
          _ClassroomFilter.values.map((filter) {
            return ButtonSegment<_ClassroomFilter>(
              value: filter,
              label: Text(labelFor(filter)),
            );
          }).toList(),
      selected: {selected},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _ClassroomListCard extends StatelessWidget {
  final Classroom classroom;
  final String schoolId;
  final FirestoreService firestoreService;
  final VoidCallback onTap;

  const _ClassroomListCard({
    required this.classroom,
    required this.schoolId,
    required this.firestoreService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = !classroom.active;
    final colourScheme = Theme.of(context).colorScheme;

    return Card(
      color:
          inactive
              ? colourScheme.surfaceContainerHighest.withValues(alpha: 0.55)
              : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      inactive
                          ? colourScheme.surfaceContainerHighest
                          : colourScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  inactive ? Icons.archive_outlined : Icons.meeting_room,
                  color:
                      inactive
                          ? colourScheme.outline
                          : colourScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            classroom.name,
                            style: TextStyle(
                              color: inactive ? colourScheme.outline : null,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            classroom.active
                                ? context.l10n.active
                                : context.l10n.inactive,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.classroomListSummary(
                        classroom.classroomCode,
                        classroom.active ? context.l10n.yes : context.l10n.no,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${classroom.enabledFeatures.length}/${ClassroomFeature.values.length} features enabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colourScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<ClassroomAdminHealth>(
                      future: firestoreService.getClassroomAdminHealth(
                        schoolId: schoolId,
                        classroomId: classroom.id,
                      ),
                      builder: (context, snapshot) {
                        final health = snapshot.data;

                        if (health == null) {
                          return const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniStatusPill(
                              icon: Icons.badge_outlined,
                              label: '${health.staffProfiles} staff',
                            ),
                            _MiniStatusPill(
                              icon: Icons.child_care_outlined,
                              label: '${health.childProfiles} children',
                            ),
                            _MiniStatusPill(
                              icon: Icons.notifications_active_outlined,
                              label: '${health.totalAlerts} alerts',
                              isAlert: health.totalAlerts > 0,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAlert;

  const _MiniStatusPill({
    required this.icon,
    required this.label,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final background =
        isAlert
            ? colourScheme.errorContainer.withValues(alpha: 0.8)
            : colourScheme.surfaceContainerHighest.withValues(alpha: 0.75);
    final foreground =
        isAlert ? colourScheme.onErrorContainer : colourScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isAlert;

  const _AdminStatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isAlert
                ? colourScheme.errorContainer.withValues(alpha: 0.75)
                : colourScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                isAlert
                    ? colourScheme.onErrorContainer
                    : colourScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color:
                  isAlert
                      ? colourScheme.onErrorContainer
                      : colourScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
