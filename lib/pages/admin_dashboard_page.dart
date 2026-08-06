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
      body: FutureBuilder<School?>(
        future: schoolFuture,
        builder: (context, schoolSnapshot) {
          final school = schoolSnapshot.data;

          return StreamBuilder<List<Classroom>>(
            stream: _firestoreService.getClassrooms(widget.schoolId),
            builder: (context, classroomSnapshot) {
              final classrooms = classroomSnapshot.data ?? [];
              final filteredClassrooms = _filteredClassrooms(classrooms);
              final classroomLimit = school?.classroomLimit ?? 3;

              return ListView(
                key: const PageStorageKey<String>('admin-dashboard'),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.32),
                            Theme.of(context).colorScheme.surface,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        school?.name ?? widget.schoolName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 14,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            context.l10n.schoolCodeValue(
                                              school?.schoolCode ??
                                                  context.l10n.loading,
                                            ),
                                          ),
                                          Text(
                                            context.l10n.classroomsUsed(
                                              classrooms.length,
                                              classroomLimit,
                                            ),
                                          ),
                                          Text(
                                            context.l10n.statusValue(
                                              (school?.active ?? true)
                                                  ? context.l10n.active
                                                  : context.l10n.inactive,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (schoolSnapshot.connectionState ==
                                    ConnectionState.waiting)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
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
                                  spacing: 8,
                                  runSpacing: 8,
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
                                      label: context.l10n.adminStatBodyChecks,
                                      value:
                                          overview.uncheckedBodyChecks
                                              .toString(),
                                      isAlert: overview.uncheckedBodyChecks > 0,
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.notifications_active_outlined,
                                      label: context.l10n.adminStatCalmRequests,
                                      value:
                                          overview.activeCalmRequests
                                              .toString(),
                                      isAlert: overview.activeCalmRequests > 0,
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.volunteer_activism_outlined,
                                      label:
                                          context.l10n.adminStatHelperRequests,
                                      value:
                                          overview.pendingHelperRequests
                                              .toString(),
                                      isAlert:
                                          overview.pendingHelperRequests > 0,
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.badge_outlined,
                                      label: context.l10n.staffContacts,
                                      value:
                                          overview.totalStaffContacts
                                              .toString(),
                                    ),
                                    _AdminStatChip(
                                      icon: Icons.family_restroom_outlined,
                                      label: context.l10n.guardianContacts,
                                      value:
                                          overview.totalGuardianContacts
                                              .toString(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    icon: Icons.contact_mail_outlined,
                    title: context.l10n.contactDirectory,
                    subtitle: context.l10n.contactDirectoryAdminSubtitle,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/contact-directory',
                        arguments: {'schoolId': widget.schoolId},
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ClassroomFilterBar(
                          selected: _filter,
                          labelFor: (filter) => _filterLabel(context, filter),
                          onChanged: (filter) {
                            setState(() {
                              _filter = filter;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (classroomSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      classrooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (classroomSnapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          context.l10n.classroomsLoadError(
                            classroomSnapshot.error.toString(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (classrooms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          context.l10n.noClassroomsYet,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (filteredClassrooms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          '${_filterLabel(context, _filter)}: 0',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...filteredClassrooms.map((classroom) {
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
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colourScheme.secondaryContainer.withValues(alpha: 0.45),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colourScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colourScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
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
        borderRadius: BorderRadius.circular(24),
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
                      context.l10n.classroomFeaturesEnabledShort(
                        classroom.enabledFeatures.length,
                        ClassroomFeature.values.length,
                      ),
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
                              label: context.l10n.adminMiniStaffCount(
                                health.staffProfiles,
                              ),
                            ),
                            _MiniStatusPill(
                              icon: Icons.child_care_outlined,
                              label: context.l10n.adminMiniChildCount(
                                health.childProfiles,
                              ),
                            ),
                            _MiniStatusPill(
                              icon: Icons.notifications_active_outlined,
                              label: context.l10n.adminMiniAlertCount(
                                health.totalAlerts,
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color:
            isAlert
                ? colourScheme.errorContainer.withValues(alpha: 0.75)
                : colourScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
