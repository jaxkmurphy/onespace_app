import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../services/firestore_service.dart';

class AccountSettingsPage extends StatefulWidget {
  final Locale locale;
  final void Function(Locale) onLocaleChange;

  const AccountSettingsPage({
    super.key,
    required this.locale,
    required this.onLocaleChange,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final FirestoreService _firestore = FirestoreService();
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late Teacher _teacher;
  bool _loading = true;
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadTeacher();
    _selectedLocale = widget.locale;
  }

  Future<void> _loadTeacher() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final t = await _firestore.getTeacherInfo(uid);
    if (mounted) {
      setState(() {
        _teacher = t;
        _loading = false;
      });
    }
  }

  Future<void> _savePin() async {
    final pin = _pinCtrl.text.trim();
    final pin2 = _confirmCtrl.text.trim();

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin) || pin != pin2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_selectedLocale.languageCode == 'ga'
                ? 'Ní mór do na PIN a bheith ina 4 dhigit agus comhoiriúnach.'
                : 'PINs must be 4 digits and match')),
      );
      return;
    }

    if ((_teacher.pin ?? '').isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_selectedLocale.languageCode == 'ga'
              ? 'An PIN atá ann a athscríobh?'
              : 'Overwrite existing PIN?'),
          content: Text(_selectedLocale.languageCode == 'ga'
              ? 'Athróidh sé seo do PIN reatha. Lean ort?'
              : 'This will replace your current PIN. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_selectedLocale.languageCode == 'ga' ? 'Cealaigh' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_selectedLocale.languageCode == 'ga' ? 'OK' : 'OK'),
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
      SnackBar(
          content: Text(_selectedLocale.languageCode == 'ga'
              ? 'PIN nuashonraithe'
              : 'PIN updated')),
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

    final isGa = _selectedLocale.languageCode == 'ga';

    return Scaffold(
      appBar: AppBar(title: Text(isGa ? 'Socruithe Cuntais' : 'Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (_teacher.pin ?? '').isEmpty
                  ? (isGa ? 'Níl PIN socraithe' : 'No PIN set')
                  : (isGa ? 'Tá PIN socraithe' : 'PIN is set'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinCtrl,
              decoration: InputDecoration(labelText: isGa ? 'PIN Nua' : 'New PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            TextField(
              controller: _confirmCtrl,
              decoration: InputDecoration(labelText: isGa ? 'Deimhnigh PIN' : 'Confirm PIN'),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              child: Text(isGa ? 'Sábháil PIN' : 'Save PIN'),
            ),
            const SizedBox(height: 40),
            Text(isGa ? 'Roghnaigh Teanga' : 'Select Language',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            DropdownButton<Locale>(
              value: _selectedLocale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ga'), child: Text('Gaeilge')),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  setState(() => _selectedLocale = locale);
                  widget.onLocaleChange(locale);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}