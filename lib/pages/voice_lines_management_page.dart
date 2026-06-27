import 'package:flutter/material.dart';
import '../data/voice_lines.dart';
import '../models/managed_voice_line.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class VoiceLinesManagementPage extends StatefulWidget {
  final StaffProfile staffProfile;

  const VoiceLinesManagementPage({super.key, required this.staffProfile});

  @override
  State<VoiceLinesManagementPage> createState() =>
      _VoiceLinesManagementPageState();
}

class _VoiceLinesManagementPageState extends State<VoiceLinesManagementPage> {
  final FirestoreService _firestoreService = FirestoreService();

  bool get _isIrish => Localizations.localeOf(context).languageCode == 'ga';

  String _localizedLabel(VoiceLine line) =>
      _isIrish ? line.labelGA : line.labelEN;

  String _localizedPhrase(VoiceLine line) =>
      _isIrish ? line.spokenGA : line.spokenEN;

  String _lineTitle(ManagedVoiceLine line) {
    final label = _isIrish ? line.labelGA : line.labelEN;
    final fallback = line.labelEN.trim().isEmpty ? line.spokenEN : line.labelEN;
    return label.trim().isEmpty ? fallback : label;
  }

  String _linePhrase(ManagedVoiceLine line) {
    final phrase = _isIrish ? line.spokenGA : line.spokenEN;
    final fallback =
        line.spokenEN.trim().isEmpty ? line.labelEN : line.spokenEN;
    return phrase.trim().isEmpty ? fallback : phrase;
  }

  Future<void> _showCustomEditor({
    ManagedVoiceLine? existing,
    required int nextSortOrder,
  }) async {
    final result = await showDialog<_VoiceLineFormResult>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _VoiceLineEditorDialog(existing: existing, isIrish: _isIrish),
    );

    if (result == null) return;

    try {
      if (existing == null) {
        await _firestoreService.addCurrentVoiceLine(
          ManagedVoiceLine(
            id: '',
            labelEN: result.labelEN,
            labelGA: result.labelGA,
            spokenEN: result.spokenEN,
            spokenGA: result.spokenGA,
            iconName: 'voice',
            colorHex: '#7E57C2',
            active: true,
            sortOrder: nextSortOrder,
            createdByStaffId: widget.staffProfile.id,
            createdByStaffName: widget.staffProfile.name,
          ),
        );

        if (!mounted) return;
        _showMessage('Voice line added.');
      } else {
        await _firestoreService.updateCurrentVoiceLine(
          existing.copyWith(
            labelEN: result.labelEN,
            labelGA: result.labelGA,
            spokenEN: result.spokenEN,
            spokenGA: result.spokenGA,
          ),
        );

        if (!mounted) return;
        _showMessage('Voice line updated.');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save this voice line.');
    }
  }

  Future<void> _addPreset(VoiceLine preset, int nextSortOrder) async {
    try {
      await _firestoreService.addCurrentVoiceLine(
        preset.toManaged(
          createdByStaffId: widget.staffProfile.id,
          createdByStaffName: widget.staffProfile.name,
          sortOrder: nextSortOrder,
        ),
      );

      if (!mounted) return;
      _showMessage('${preset.labelEN} added.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not add this voice line.');
    }
  }

  Future<void> _addStarterLines(int nextSortOrder) async {
    try {
      for (var index = 0; index < defaultVoiceLines.length; index++) {
        await _firestoreService.addCurrentVoiceLine(
          defaultVoiceLines[index].toManaged(
            createdByStaffId: widget.staffProfile.id,
            createdByStaffName: widget.staffProfile.name,
            sortOrder: nextSortOrder + index,
          ),
        );
      }

      if (!mounted) return;
      _showMessage('Starter voice lines added.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not add starter voice lines.');
    }
  }

  Future<void> _toggleActive(ManagedVoiceLine line) async {
    try {
      await _firestoreService.setCurrentVoiceLineActive(
        voiceLineId: line.id,
        active: !line.active,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not update this voice line.');
    }
  }

  Future<void> _deleteVoiceLine(ManagedVoiceLine line) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete voice line?'),
            content: Text(
              'This will remove "${line.labelEN}" from the classroom voice lines.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.deleteCurrentVoiceLine(line.id);

      if (!mounted) return;
      _showMessage('Voice line deleted.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not delete this voice line.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildHeader({required int nextSortOrder}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 680;

          final icon = Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: Colors.white,
              size: 38,
            ),
          );

          final copy = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voice Lines',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isIrish
                      ? 'Manage the phrases children can use. Add Irish text now; English can be added later.'
                      : 'Manage the phrases children can use. Add English text now; Irish can be added later.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );

          final button = FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5E35B1),
            ),
            onPressed: () => _showCustomEditor(nextSortOrder: nextSortOrder),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create custom'),
          );

          if (isWide) {
            return Row(
              children: [
                icon,
                const SizedBox(width: 16),
                copy,
                const SizedBox(width: 16),
                button,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(height: 14),
              Row(children: [copy]),
              const SizedBox(height: 16),
              button,
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.30),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: Color(0xFFFF8F00)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Starter voice lines are suggestions only. Once added, staff can enable, disable, edit or delete them like any other line.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF7E57C2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagedLines(List<ManagedVoiceLine> lines, int nextSortOrder) {
    if (lines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E3FF)),
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                color: Color(0xFF7E57C2),
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No voice lines are active yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Add the six starter lines, choose from the preset library, or create your own.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _addStarterLines(nextSortOrder),
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: const Text('Add starter voice lines'),
            ),
          ],
        ),
      );
    }

    return _voiceLineWrap(
      lines
          .map(
            (line) =>
                _buildManagedLineCard(line: line, nextSortOrder: nextSortOrder),
          )
          .toList(),
    );
  }

  Widget _buildManagedLineCard({
    required ManagedVoiceLine line,
    required int nextSortOrder,
  }) {
    final color = voiceLineColorFromHex(line.colorHex);
    final icon = voiceLineIconForName(line.iconName);

    return _LineShell(
      color: color,
      isMuted: !line.active,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LineIcon(color: color, icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lineTitle(line),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      line.active ? 'Available to children' : 'Hidden',
                      style: TextStyle(
                        color: line.active ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: line.active, onChanged: (_) => _toggleActive(line)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _linePhrase(line),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      () => _showCustomEditor(
                        existing: line,
                        nextSortOrder: nextSortOrder,
                      ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => _deleteVoiceLine(line),
                icon: const Icon(Icons.delete_rounded),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetLibrary(
    List<ManagedVoiceLine> managedLines,
    int nextSortOrder,
  ) {
    final addedPresetKeys =
        managedLines
            .map((line) => line.presetKey)
            .where((key) => key.trim().isNotEmpty)
            .toSet();

    return _voiceLineWrap(
      addableVoiceLinePresets.map((preset) {
        final isAdded = addedPresetKeys.contains(preset.key);
        return _buildPresetCard(
          preset: preset,
          isAdded: isAdded,
          nextSortOrder: nextSortOrder,
        );
      }).toList(),
    );
  }

  Widget _buildPresetCard({
    required VoiceLine preset,
    required bool isAdded,
    required int nextSortOrder,
  }) {
    return _LineShell(
      color: preset.color,
      isMuted: isAdded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LineIcon(color: preset.color, icon: preset.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedLabel(preset),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localizedPhrase(preset),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  isAdded ? null : () => _addPreset(preset, nextSortOrder),
              icon: Icon(isAdded ? Icons.check_rounded : Icons.add_rounded),
              label: Text(isAdded ? 'Added' : 'Add preset'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voiceLineWrap(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 920
                ? 3
                : constraints.maxWidth >= 620
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 14)) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children:
              children
                  .map(
                    (child) =>
                        SizedBox(width: width, height: 192, child: child),
                  )
                  .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: const Text('Voice Lines'),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<ManagedVoiceLine>>(
          stream: _firestoreService.getCurrentVoiceLines(),
          builder: (context, snapshot) {
            final managedLines = snapshot.data ?? [];
            final nextSortOrder =
                managedLines.isEmpty
                    ? defaultVoiceLines.length
                    : managedLines
                            .map((line) => line.sortOrder)
                            .reduce((a, b) => a > b ? a : b) +
                        1;

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(nextSortOrder: nextSortOrder),
                        const SizedBox(height: 14),
                        _buildInfoNotice(),
                        _sectionTitle(
                          'Available voice lines',
                          'Enable, disable, edit or delete the lines children can use.',
                          Icons.record_voice_over_rounded,
                        ),
                        _buildManagedLines(managedLines, nextSortOrder),
                        _sectionTitle(
                          'Preset library',
                          'Common phrases staff can add when needed.',
                          Icons.library_add_rounded,
                        ),
                        _buildPresetLibrary(managedLines, nextSortOrder),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VoiceLineEditorDialog extends StatefulWidget {
  final ManagedVoiceLine? existing;
  final bool isIrish;

  const _VoiceLineEditorDialog({required this.existing, required this.isIrish});

  @override
  State<_VoiceLineEditorDialog> createState() => _VoiceLineEditorDialogState();
}

class _VoiceLineEditorDialogState extends State<_VoiceLineEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _spokenController;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    final existingLabel =
        widget.isIrish ? existing?.labelGA ?? '' : existing?.labelEN ?? '';
    final existingSpoken =
        widget.isIrish ? existing?.spokenGA ?? '' : existing?.spokenEN ?? '';

    _labelController = TextEditingController(text: existingLabel);
    _spokenController = TextEditingController(text: existingSpoken);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _spokenController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final label = _labelController.text.trim();
    final spoken = _spokenController.text.trim();
    final existing = widget.existing;

    Navigator.pop(
      context,
      _VoiceLineFormResult(
        labelEN:
            widget.isIrish
                ? (existing?.labelEN.trim().isNotEmpty == true
                    ? existing!.labelEN
                    : label)
                : label,
        labelGA:
            widget.isIrish
                ? label
                : (existing?.labelGA.trim().isNotEmpty == true
                    ? existing!.labelGA
                    : label),
        spokenEN:
            widget.isIrish
                ? (existing?.spokenEN.trim().isNotEmpty == true
                    ? existing!.spokenEN
                    : spoken)
                : spoken,
        spokenGA:
            widget.isIrish
                ? spoken
                : (existing?.spokenGA.trim().isNotEmpty == true
                    ? existing!.spokenGA
                    : spoken),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final languageName = widget.isIrish ? 'Irish' : 'English';

    return AlertDialog(
      title: Text(isEditing ? 'Edit voice line' : 'Create custom voice line'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter this line in $languageName. The other language will use this text until translation is added.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: '$languageName button name',
                    hintText: widget.isIrish ? 'Cabhair' : 'Help',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _spokenController,
                  decoration: InputDecoration(
                    labelText: '$languageName audio text',
                    hintText:
                        widget.isIrish
                            ? 'Tá cabhair ag teastáil uaim.'
                            : 'I need help.',
                  ),
                  validator: _required,
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save changes' : 'Create'),
        ),
      ],
    );
  }
}

class _LineShell extends StatelessWidget {
  final Color color;
  final Widget child;
  final bool isMuted;

  const _LineShell({
    required this.color,
    required this.child,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isMuted ? Colors.white.withValues(alpha: 0.62) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isMuted
                  ? Colors.grey.withValues(alpha: 0.20)
                  : color.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isMuted ? 0.03 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LineIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _LineIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 29),
    );
  }
}

class _VoiceLineFormResult {
  final String labelEN;
  final String labelGA;
  final String spokenEN;
  final String spokenGA;

  const _VoiceLineFormResult({
    required this.labelEN,
    required this.labelGA,
    required this.spokenEN,
    required this.spokenGA,
  });
}
