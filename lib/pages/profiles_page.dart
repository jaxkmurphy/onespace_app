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

  Future<void> _onDeleteStaffProfile(String profileId) async {
    final l10n = context.l10n;
    final confirmed = await _checkPin();

    if (!confirmed) {
      _showSnack(l10n.accessDeniedIncorrectPin);
      return;
    }

    try {
      await firestoreService.deleteCurrentStaffProfile(profileId);
      _showSnack(l10n.staffProfileDeleted);
    } catch (e) {
      _showSnack(l10n.staffProfileDeleteFailed(e.toString()));
    }
  }

  Future<void> _onDeleteChildProfile(String profileId) async {
    final l10n = context.l10n;
    final confirmed = await _checkPin();

    if (!confirmed) {
      _showSnack(l10n.accessDeniedIncorrectPin);
      return;
    }

    try {
      await firestoreService.deleteCurrentChildProfile(profileId);
      _showSnack(l10n.childProfileDeleted);
    } catch (e) {
      _showSnack(l10n.childProfileDeleteFailed(e.toString()));
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
      session.clearSession();

      await FirebaseAuth.instance.signOut();

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
    if (_isRestoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final staffStream = _staffProfilesStream();
    final childStream = _childProfilesStream();

    final title =
        _isClassroomMode ? session.currentClassroomName : context.l10n.profiles;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.groups_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.l10n.chooseProfile,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                if (_isClassroomMode) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    session.currentClassroomName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            context.l10n.staffProfiles,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          if (staffProfiles.isEmpty)
                            _EmptyProfileSection(
                              message: context.l10n.noStaffProfilesFound,
                            )
                          else
                            ...staffProfiles.map(
                              (staff) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProfileSelectionCard(
                                  name: staff.name,
                                  subtitle: context.l10n.staffProfile,
                                  icon: Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                  isChild: false,
                                  onTap: () => _onStaffTap(staff),
                                  onDelete:
                                      () => _onDeleteStaffProfile(staff.id),
                                ),
                              ),
                            ),

                          const SizedBox(height: 18),

                          Text(
                            context.l10n.childProfiles,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          if (childProfiles.isEmpty)
                            _EmptyProfileSection(
                              message: context.l10n.noChildProfilesShort,
                            )
                          else
                            ...childProfiles.map(
                              (child) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProfileSelectionCard(
                                  name: child.name,
                                  subtitle: context.l10n.ageValue(child.age),
                                  icon: Icons.child_care,
                                  color: const Color(0xFF26A69A),
                                  isChild: true,
                                  onTap: () => _onChildTap(child),
                                  onDelete:
                                      () => _onDeleteChildProfile(child.id),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          Text(
                            context.l10n.adminActions,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;

                              final addProfileCard = ProfileSelectionCard(
                                name: context.l10n.addProfile,
                                subtitle: context.l10n.createProfilesIntro,
                                icon: Icons.person_add,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: _goToAddProfile,
                              );

                              final settingsCard = ProfileSelectionCard(
                                name:
                                    _isClassroomMode
                                        ? context.l10n.appSettings
                                        : context.l10n.accountSettings,
                                subtitle:
                                    _isClassroomMode
                                        ? context.l10n.languageAppOptions
                                        : context.l10n.managePinAccountOptions,
                                icon: Icons.settings,
                                color: Colors.grey,
                                onTap: _goToSettings,
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

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyProfileSection extends StatelessWidget {
  final String message;

  const _EmptyProfileSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
