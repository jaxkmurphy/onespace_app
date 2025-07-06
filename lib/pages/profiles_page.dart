import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../widgets/pin_entry_dialog.dart';

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
    if (!mounted) return;
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/add-profile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_getText('Access denied: incorrect PIN'))),
      );
    }
  }

  Future<void> _goToSettings() async {
    if (!mounted) return;
    final pinOk = await _checkPin();
    if (!mounted) return;

    if (pinOk) {
      Navigator.pushNamed(context, '/account-settings');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_getText('Access denied: incorrect PIN'))),
      );
    }
  }

  Future<void> _onStaffTap(StaffProfile profile) async {
    final pinOk = await _checkPin();
    if (pinOk && mounted) {
      Navigator.pushNamed(context, '/staff-dashboard', arguments: profile);
    }
  }

  Future<void> _onChildTap(ChildProfile profile) async {
    if (mounted) {
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getText(text))));
  }

  String _getText(String en) {
    final isGa = Localizations.localeOf(context).languageCode == 'ga';
    final map = {
      'Profiles': 'Próifílí',
      'No staff profiles found': 'Gan próifílí foirne',
      'No child profiles found': 'Gan próifílí páistí',
      'Age': 'Aois',
      'Add Profile': 'Cuir Próifíl Leis',
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
        title: Text(_getText('Profiles')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _goToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<StaffProfile>>(
              stream: staffStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error loading staff: ${snap.error}'));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text(_getText('No staff profiles found')));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final s = list[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(s.name),
                      onTap: () => _onStaffTap(s),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _onDeleteStaffProfile(s.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<ChildProfile>>(
              stream: childStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error loading children: ${snap.error}'));
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(child: Text(_getText('No child profiles found')));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final ch = list[i];
                    return ListTile(
                      leading: const Icon(Icons.child_care),
                      title: Text(ch.name),
                      subtitle: Text('${_getText("Age")}: ${ch.age}'),
                      onTap: () => _onChildTap(ch),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _onDeleteChildProfile(ch.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddProfile,
        tooltip: _getText('Add Profile'),
        child: const Icon(Icons.add),
      ),
    );
  }
}