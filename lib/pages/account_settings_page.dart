import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../services/classroom_session_service.dart';
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
  final ClassroomSessionService _session = ClassroomSessionService.instance;

  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Teacher? _teacher;
  bool _loading = true;
  late Locale _selectedLocale;

  bool get _isClassroomMode => _session.hasClassroomSession;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.locale;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_isClassroomMode) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final teacher = await _firestore.getTeacherInfo(uid);

    if (!mounted) return;

    setState(() {
      _teacher = teacher;
      _loading = false;
    });
  }

  Future<void> _savePin() async {
    if (_isClassroomMode) return;

    final teacher = _teacher;
    if (teacher == null) return;

    final pin = _pinCtrl.text.trim();
    final pin2 = _confirmCtrl.text.trim();
    final isGa = _selectedLocale.languageCode == 'ga';

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin) || pin != pin2) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isGa
                ? 'Ní mór do na PIN a bheith ina 4 dhigit agus comhoiriúnach.'
                : 'PINs must be 4 digits and match.',
          ),
        ),
      );
      return;
    }

    if ((teacher.pin ?? '').isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            isGa ? 'An PIN atá ann a athscríobh?' : 'Overwrite existing PIN?',
          ),
          content: Text(
            isGa
                ? 'Athróidh sé seo do PIN reatha. Lean ort?'
                : 'This will replace your current PIN. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isGa ? 'Cealaigh' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final updated = teacher.copyWith(pin: pin);
    await _firestore.setTeacherInfo(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isGa ? 'PIN nuashonraithe' : 'PIN updated'),
      ),
    );

    setState(() {
      _teacher = updated;
      _pinCtrl.clear();
      _confirmCtrl.clear();
    });
  }

  String _text(String en, String ga) {
    return _selectedLocale.languageCode == 'ga' ? ga : en;
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colourScheme = Theme.of(context).colorScheme;
    final teacher = _teacher;
    final pinIsSet = (teacher?.pin ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isClassroomMode
              ? _text('App Settings', 'Socruithe Aipe')
              : _text('Account Settings', 'Socruithe Cuntais'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: colourScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Icon(
                              Icons.settings_rounded,
                              size: 44,
                              color: colourScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _isClassroomMode
                                ? _text(
                                    'Manage app settings',
                                    'Bainistigh socruithe na haipe',
                                  )
                                : _text(
                                    'Manage your account',
                                    'Bainistigh do chuntas',
                                  ),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isClassroomMode
                                ? _text(
                                    'Choose the app language and general app options.',
                                    'Roghnaigh teanga na haipe agus roghanna ginearálta.',
                                  )
                                : _text(
                                    'Set your PIN and choose the app language.',
                                    'Socraigh do PIN agus roghnaigh teanga an aip.',
                                  ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (!_isClassroomMode) ...[
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: pinIsSet
                                    ? Colors.green.withOpacity(0.14)
                                    : Colors.orange.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                pinIsSet
                                    ? Icons.lock_rounded
                                    : Icons.lock_open_rounded,
                                color: pinIsSet ? Colors.green : Colors.orange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pinIsSet
                                        ? _text(
                                            'PIN is set',
                                            'Tá PIN socraithe',
                                          )
                                        : _text(
                                            'No PIN set',
                                            'Níl PIN socraithe',
                                          ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _text(
                                      'The account PIN protects staff-only areas.',
                                      'Cosnaíonn PIN an chuntais limistéir don fhoireann amháin.',
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _text('Change PIN', 'Athraigh PIN'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _text(
                                'Enter a new 4-digit PIN.',
                                'Cuir PIN nua 4 dhigit isteach.',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _pinCtrl,
                              decoration: InputDecoration(
                                labelText: _text('New PIN', 'PIN Nua'),
                                prefixIcon: const Icon(Icons.pin_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _confirmCtrl,
                              decoration: InputDecoration(
                                labelText:
                                    _text('Confirm PIN', 'Deimhnigh PIN'),
                                prefixIcon:
                                    const Icon(Icons.verified_user_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _savePin,
                              icon: const Icon(Icons.save_rounded),
                              label: Text(_text('Save PIN', 'Sábháil PIN')),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],

                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _text('Language', 'Teanga'),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _text(
                              'Choose the app language.',
                              'Roghnaigh teanga an aip.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LanguageOption(
                            label: 'English',
                            icon: Icons.language,
                            selected: _selectedLocale.languageCode == 'en',
                            onTap: () {
                              const locale = Locale('en');
                              setState(() => _selectedLocale = locale);
                              widget.onLocaleChange(locale);
                            },
                          ),
                          const SizedBox(height: 12),
                          _LanguageOption(
                            label: 'Gaeilge',
                            icon: Icons.translate,
                            selected: _selectedLocale.languageCode == 'ga',
                            onTap: () {
                              const locale = Locale('ga');
                              setState(() => _selectedLocale = locale);
                              widget.onLocaleChange(locale);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colourScheme.primary.withOpacity(0.14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected ? colourScheme.primary : Theme.of(context).dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? colourScheme.primary : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? colourScheme.primary : null,
                      ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: colourScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}