import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../widgets/pin_entry_dialog.dart';
import '../widgets/child_icon_unlock_dialog.dart';
import '../widgets/profile_selection_card.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  final firestoreService = FirestoreService();

  Future<bool> _checkPin() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final teacher = await firestoreService.getTeacherInfo(uid);
      final pin = teacher.pin;

      if (pin == null || pin.isEmpty) return true;
      if (!mounted) return false;

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PinEntryDialog(correctPin: pin),
      );

      return ok == true;
    } catch (e) {
      print('PIN check failed: $e');
      return false;
    }
  }

  Future<void> _goToAddProfile() async {
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/add-profile');
    } else {
      _showSnack('Access denied: incorrect PIN');
    }
  }

  Future<void> _goToSettings() async {
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/account-settings');
    } else {
      _showSnack('Access denied: incorrect PIN');
    }
  }

  Future<void> _onStaffTap(StaffProfile profile) async {
    final pinOk = await _checkPin();
    if (pinOk && mounted) {
      Navigator.pushNamed(context, '/staff-dashboard', arguments: profile);
    }
  }

  Future<void> _onChildTap(ChildProfile profile) async {
    bool allowed = false;

    if (profile.accessMode == 'iconSequence') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => ChildIconUnlockDialog(
          childName: profile.name,
          correctSequence: profile.iconSequence,
        ),
      );
      allowed = ok == true;
    } else {
      allowed = true;
    }

    if (allowed && mounted) {
      Navigator.pushNamed(context, '/child-dashboard', arguments: profile);
    }
  }

  Future<void> _onDeleteStaffProfile(String profileId) async {
    final confirmed = await _checkPin();
    if (!confirmed) {
      _showSnack('Access denied: incorrect PIN');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await firestoreService.deleteStaffProfile(uid, profileId);
      _showSnack('Staff profile deleted');
    } catch (e) {
      _showSnack('Failed to delete staff profile: $e');
    }
  }

  Future<void> _onDeleteChildProfile(String profileId) async {
    final confirmed = await _checkPin();
    if (!confirmed) {
      _showSnack('Access denied: incorrect PIN');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await firestoreService.deleteChildProfile(uid, profileId);
      _showSnack('Child profile deleted');
    } catch (e) {
      _showSnack('Failed to delete child profile: $e');
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getText(text))),
    );
  }

  String _getText(String en) {
    final isGa = Localizations.localeOf(context).languageCode == 'ga';
    final map = {
      'Profiles': 'Próifílí',
      'Staff Profiles': 'Próifílí Foirne',
      'Child Profiles': 'Próifílí Páistí',
      'Choose a profile to continue':
          'Roghnaigh próifíl le leanúint ar aghaidh',
      'Staff profile': 'Próifíl foirne',
      'Child profile': 'Próifíl páiste',
      'No staff profiles found': 'Gan próifílí foirne',
      'No child profiles found': 'Gan próifílí páistí',
      'Age': 'Aois',
      'Add Profile': 'Cuir Próifíl Leis',
      'Account Settings': 'Socruithe Cuntais',
      'Admin Actions': 'Gníomhartha Riaracháin',
      'Create staff or child profiles': 'Cruthaigh próifílí foirne nó páistí',
      'Manage PIN and account options': 'Bainistigh PIN agus roghanna cuntais',
      'Access denied: incorrect PIN': 'Diúltaíodh rochtain: PIN mícheart',
      'Staff profile deleted': 'Scriosadh próifíl an fhostaí',
      'Child profile deleted': 'Scriosadh próifíl an pháiste',
    };
    return isGa && map.containsKey(en) ? map[en]! : en;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final staffStream = firestoreService.getStaffProfiles(uid);
    final childStream = firestoreService.getChildProfiles(uid);

    return Scaffold(
    appBar: AppBar(
    title: const Text('Profiles'),
    actions: [
      IconButton(
        icon: const Icon(Icons.admin_panel_settings),
        tooltip: 'Admin Dashboard',
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/admin-dashboard',
            arguments: {
              'schoolId': 'YOUR_SCHOOL_ID_HERE',
              'schoolName': 'Test School',
            },
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text(
                'Are you sure you want to logout?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
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
                    child: Text('Error loading staff: ${staffSnap.error}'),
                  );
                }

                if (childSnap.hasError) {
                  return Center(
                    child: Text('Error loading children: ${childSnap.error}'),
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
                                  _getText('Choose a profile to continue'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            _getText('Staff Profiles'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          if (staffProfiles.isEmpty)
                            _EmptyProfileSection(
                              message: _getText('No staff profiles found'),
                            )
                          else
                            ...staffProfiles.map(
                              (staff) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProfileSelectionCard(
                                  name: staff.name,
                                  subtitle: _getText('Staff profile'),
                                  icon: Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  isChild: false,
                                  onTap: () => _onStaffTap(staff),
                                  onDelete: () =>
                                      _onDeleteStaffProfile(staff.id),
                                ),
                              ),
                            ),

                          const SizedBox(height: 18),

                          Text(
                            _getText('Child Profiles'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          if (childProfiles.isEmpty)
                            _EmptyProfileSection(
                              message: _getText('No child profiles found'),
                            )
                          else
                            ...childProfiles.map(
                              (child) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProfileSelectionCard(
                                  name: child.name,
                                  subtitle: '${_getText("Age")}: ${child.age}',
                                  icon: Icons.child_care,
                                  color: const Color(0xFF26A69A),
                                  isChild: true,
                                  onTap: () => _onChildTap(child),
                                  onDelete: () =>
                                      _onDeleteChildProfile(child.id),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          Text(
                            _getText('Admin Actions'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 700;

                              final addProfileCard = ProfileSelectionCard(
                                name: _getText('Add Profile'),
                                subtitle: _getText(
                                  'Create staff or child profiles',
                                ),
                                icon: Icons.person_add,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: _goToAddProfile,
                              );

                              final settingsCard = ProfileSelectionCard(
                                name: _getText('Account Settings'),
                                subtitle: _getText(
                                  'Manage PIN and account options',
                                ),
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

  const _EmptyProfileSection({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}