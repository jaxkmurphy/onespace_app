import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../services/firestore_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final FirestoreService _firestore = FirestoreService();
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late Teacher _teacher;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final t = await _firestore.getTeacherInfo(uid);
    setState(() {
      _teacher = t;
      _loading = false;
    });
  }

  Future<void> _savePin() async {
    final pin = _pinCtrl.text.trim();
    final pin2 = _confirmCtrl.text.trim();

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin) || pin != pin2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs must be 4 digits and match')),
      );
      return;
    }

    if ((_teacher.pin ?? '').isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Overwrite existing PIN?'),
          content: const Text('This will replace your current PIN. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final updated = _teacher.copyWith(pin: pin);
    await _firestore.setTeacherInfo(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN updated')),
    );

    setState(() {
      _teacher = updated;
      _pinCtrl.clear();
      _confirmCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (_teacher.pin ?? '').isEmpty ? 'No PIN set' : 'PIN is set',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinCtrl,
              decoration: const InputDecoration(labelText: 'New PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            TextField(
              controller: _confirmCtrl,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
