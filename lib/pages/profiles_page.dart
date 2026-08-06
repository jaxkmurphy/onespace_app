import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../widgets/pin_entry_dialog.dart';
import '../widgets/child_icon_unlock_dialog.dart';
import '../widgets/profile_selection_card.dart';
import '../l10n/l10n.dart';

class ProfilesPage extends StatefulWidget {
  final String? schoolId;
  final String? classroomId;
  final String? classroomName;

  const ProfilesPage({
    super.key,
    this.schoolId,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final FirestoreService firestoreService = FirestoreService();
  final ClassroomSessionService session = ClassroomSessionService.instance;

  bool _isRestoringSession = true;
  bool _isLoggingOut = false;

  bool get _isClassroomMode => session.hasClassroomSession;

  @override
  void initState() {
    super.initState();
    _restoreSessionIfNeeded();
  }

  Future<void> _restoreSessionIfNeeded() async {
    if (widget.schoolId != null &&
        widget.classroomId != null &&
        widget.classroomName != null) {
      session.setSession(
        schoolId: widget.schoolId!,
        classroomId: widget.classroomId!,
        classroomName: widget.classroomName!,
      );

      if (mounted) {
        setState(() {
          _isRestoringSession = false;
        });
      }
      return;
    }

    if (session.hasClassroomSession) {
      if (mounted) {
        setState(() {
          _isRestoringSession = false;
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final tokenResult = await user.getIdTokenResult(true);
        final claims = tokenResult.claims ?? {};

        if (claims['role'] == 'classroom' &&
            claims['schoolId'] is String &&
            claims['classroomId'] is String) {
          final schoolId = claims['schoolId'] as String;
          final classroomId = claims['classroomId'] as String;

          final classroom = await firestoreService.getClassroom(
            schoolId: schoolId,
            classroomId: classroomId,
          );

          if (classroom != null && classroom.active) {
            session.setSession(
              schoolId: schoolId,
              classroomId: classroomId,
              classroomName: classroom.name,
            );
          }
        }
      } catch (e) {
        debugPrint('Could not restore classroom session: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isRestoringSession = false;
      });
    }
  }

  Future<bool> _checkPin() async {
    try {
      String? pin;

      if (_isClassroomMode) {
        final classroom = await firestoreService.getClassroom(
          schoolId: session.requireSchoolId,
          classroomId: session.requireClassroomId,
        );

        pin = classroom?.pin;
      } else {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final teacher = await firestoreService.getTeacherInfo(uid);
        pin = teacher.pin;
      }

      if (pin == null || pin.isEmpty) return true;
      if (!mounted) return false;

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PinEntryDialog(correctPin: pin!),
      );

      return ok == true;
    } catch (e) {
      debugPrint('PIN check failed: $e');
      return false;
    }
  }

  Future<void> _goToAddProfile() async {
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/add-profile');
    } else {
      _showSnack(context.l10n.accessDeniedIncorrectPin);
    }
  }

  Future<void> _goToSettings() async {
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/account-settings');
    } else {
      _showSnack(context.l10n.accessDeniedIncorrectPin);
    }
  }

  Future<void> _onStaffTap(StaffProfile profile) async {
    final pinOk = await _checkPin();

    if (pinOk && mounted) {
      Navigator.pushNamed(
        context,
        '/staff-dashboard/${profile.id}',
        arguments: {'profile': profile},
      );
    }
  }

  Future<void> _onChildTap(ChildProfile profile) async {
    if (!profile.profileAccessEnabled) {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(context.l10n.profilePausedTitle),
              content: Text(context.l10n.childProfilePausedMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.ok),
                ),
              ],
            ),
      );
      return;
    }

    bool allowed = false;

    if (profile.accessMode == 'iconSequence') {
      final ok = await showDialog<bool>(
        context: context,
        builder:
            (_) => ChildIconUnlockDialog(
              childName: profile.name,
              correctSequence: profile.iconSequence,
            ),
      );
      allowed = ok == true;
    } else {
      allowed = true;
    }

    if (allowed && mounted) {
      Navigator.pushNamed(
        context,
        '/child-dashboard/${profile.id}',
        arguments: {'profile': profile},
      );
    }
  }

  Future<void> _logout() async {
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
      if (mounted) {
        setState(() {
          _isLoggingOut = true;
        });
      }

      await FirebaseAuth.instance.signOut();
      session.clearSession();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Stream<List<StaffProfile>> _staffProfilesStream() {
    return firestoreService.getCurrentStaffProfiles();
  }

  Stream<List<ChildProfile>> _childProfilesStream() {
    return firestoreService.getCurrentChildProfiles();
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringSession || _isLoggingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final staffStream = _staffProfilesStream();
    final childStream = _childProfilesStream();

    final title =
        _isClassroomMode ? session.currentClassroomName : context.l10n.profiles;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: context.l10n.logout,
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<StaffProfile>>(
          stream: staffStream,
          builder: (context, staffSnap) {
            return StreamBuilder<List<ChildProfile>>(
              stream: childStream,
              builder: (context, childSnap) {
                final staffLoading =
                    staffSnap.connectionState == ConnectionState.waiting;
                final childLoading =
                    childSnap.connectionState == ConnectionState.waiting;

                if (staffLoading || childLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (staffSnap.hasError) {
                  return Center(
                    child: Text(
                      context.l10n.staffLoadError(staffSnap.error.toString()),
                    ),
                  );
                }

                if (childSnap.hasError) {
                  return Center(
                    child: Text(
                      context.l10n.childrenLoadError(
                        childSnap.error.toString(),
                      ),
                    ),
                  );
                }

                final staffProfiles = staffSnap.data ?? [];
                final childProfiles = childSnap.data ?? [];

                return _ProfilesBody(
                  isClassroomMode: _isClassroomMode,
                  classroomName: session.currentClassroomName,
                  staffProfiles: staffProfiles,
                  childProfiles: childProfiles,
                  onStaffTap: _onStaffTap,
                  onChildTap: _onChildTap,
                  onGoToAddProfile: _goToAddProfile,
                  onGoToSettings: _goToSettings,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfilesBody extends StatelessWidget {
  final bool isClassroomMode;
  final String classroomName;
  final List<StaffProfile> staffProfiles;
  final List<ChildProfile> childProfiles;
  final ValueChanged<StaffProfile> onStaffTap;
  final ValueChanged<ChildProfile> onChildTap;
  final VoidCallback onGoToAddProfile;
  final VoidCallback onGoToSettings;

  const _ProfilesBody({
    required this.isClassroomMode,
    required this.classroomName,
    required this.staffProfiles,
    required this.childProfiles,
    required this.onStaffTap,
    required this.onChildTap,
    required this.onGoToAddProfile,
    required this.onGoToSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3F0FF),
            colourScheme.surface,
            const Color(0xFFE8F7F4),
          ],
        ),
      ),
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('profiles-page'),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfilesHeroCard(
                  isClassroomMode: isClassroomMode,
                  classroomName: classroomName,
                  staffCount: staffProfiles.length,
                  childCount: childProfiles.length,
                ),
                const SizedBox(height: 22),
                _ProfilesSection(
                  icon: Icons.badge_rounded,
                  title: context.l10n.staffProfiles,
                  subtitle: context.l10n.chooseStaffProfileForTools,
                  color: colourScheme.primary,
                  emptyMessage: context.l10n.noStaffProfilesFound,
                  children:
                      staffProfiles
                          .map(
                            (staff) => ProfileSelectionCard(
                              name: staff.name,
                              subtitle: context.l10n.staffProfile,
                              icon: Icons.person_rounded,
                              color: colourScheme.primary,
                              isChild: false,
                              onTap: () => onStaffTap(staff),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 18),
                _ProfilesSection(
                  icon: Icons.child_care_rounded,
                  title: context.l10n.childProfiles,
                  subtitle: context.l10n.chooseChildProfileForSpace,
                  color: const Color(0xFF26A69A),
                  emptyMessage: context.l10n.noChildProfilesShort,
                  children:
                      childProfiles.map((child) {
                        final enabled = child.profileAccessEnabled;

                        return Opacity(
                          opacity: enabled ? 1.0 : 0.62,
                          child: ProfileSelectionCard(
                            name: child.name,
                            subtitle:
                                enabled
                                    ? context.l10n.ageValue(child.age)
                                    : context.l10n.profilePausedTalkToTeacher,
                            icon:
                                enabled
                                    ? Icons.child_care_rounded
                                    : Icons.lock_rounded,
                            color:
                                enabled
                                    ? const Color(0xFF26A69A)
                                    : colourScheme.error,
                            isChild: true,
                            onTap: () => onChildTap(child),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 18),
                _AdminActionsCard(
                  isClassroomMode: isClassroomMode,
                  onGoToAddProfile: onGoToAddProfile,
                  onGoToSettings: onGoToSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilesHeroCard extends StatelessWidget {
  final bool isClassroomMode;
  final String classroomName;
  final int staffCount;
  final int childCount;

  const _ProfilesHeroCard({
    required this.isClassroomMode,
    required this.classroomName,
    required this.staffCount,
    required this.childCount,
  });

  @override
  Widget build(BuildContext context) {
    final title = isClassroomMode ? classroomName : context.l10n.profiles;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF26A69A)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 680;

          final heading = Expanded(
            child: Column(
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: isWide ? TextAlign.start : TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.chooseProfile,
                  textAlign: isWide ? TextAlign.start : TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );

          final stats = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: isWide ? WrapAlignment.end : WrapAlignment.center,
            children: [
              _HeroStatChip(
                icon: Icons.badge_rounded,
                label: context.l10n.staffProfiles,
                value: staffCount.toString(),
              ),
              _HeroStatChip(
                icon: Icons.child_care_rounded,
                label: context.l10n.childProfiles,
                value: childCount.toString(),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.62),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 18),
                heading,
                const SizedBox(width: 16),
                stats,
              ],
            );
          }

          return Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.62),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [heading]),
              const SizedBox(height: 14),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilesSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String emptyMessage;
  final List<Widget> children;

  const _ProfilesSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: icon,
            title: title,
            subtitle: subtitle,
            color: color,
          ),
          const SizedBox(height: 16),
          if (children.isEmpty)
            _EmptyProfileSection(message: emptyMessage)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 2 : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: 112,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) => children[index],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AdminActionsCard extends StatelessWidget {
  final bool isClassroomMode;
  final VoidCallback onGoToAddProfile;
  final VoidCallback onGoToSettings;

  const _AdminActionsCard({
    required this.isClassroomMode,
    required this.onGoToAddProfile,
    required this.onGoToSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colourScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colourScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: Icons.admin_panel_settings_rounded,
            title: context.l10n.adminActions,
            subtitle: context.l10n.manageProfilesAndAppOptions,
            color: colourScheme.primary,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final addProfileCard = ProfileSelectionCard(
                name: context.l10n.addProfile,
                subtitle: context.l10n.createProfilesIntro,
                icon: Icons.person_add_rounded,
                color: colourScheme.primary,
                onTap: onGoToAddProfile,
              );

              final settingsCard = ProfileSelectionCard(
                name:
                    isClassroomMode
                        ? context.l10n.appSettings
                        : context.l10n.accountSettings,
                subtitle:
                    isClassroomMode
                        ? context.l10n.languageAppOptions
                        : context.l10n.managePinAccountOptions,
                icon: Icons.settings_rounded,
                color: Colors.grey,
                onTap: onGoToSettings,
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: addProfileCard),
                    const SizedBox(width: 12),
                    Expanded(child: settingsCard),
                  ],
                );
              }

              return Column(
                children: [
                  addProfileCard,
                  const SizedBox(height: 12),
                  settingsCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyProfileSection extends StatelessWidget {
  final String message;

  const _EmptyProfileSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
