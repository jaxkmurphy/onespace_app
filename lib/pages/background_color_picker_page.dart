import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class BackgroundColorPickerPage extends StatefulWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const BackgroundColorPickerPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  @override
  State<BackgroundColorPickerPage> createState() =>
      _BackgroundColorPickerPageState();
}

class _BackgroundColorPickerPageState extends State<BackgroundColorPickerPage> {
  static const List<_BackgroundOption> colourOptions = [
    _BackgroundOption(
      name: 'Cloud White',
      description: 'Bright and simple',
      hex: '#FFFFFF',
      icon: Icons.cloud_rounded,
    ),
    _BackgroundOption(
      name: 'Bubblegum Pink',
      description: 'Happy and warm',
      hex: '#FFB7D5',
      icon: Icons.favorite_rounded,
    ),
    _BackgroundOption(
      name: 'Sky Blue',
      description: 'Calm and clear',
      hex: '#8FD8FF',
      icon: Icons.cloud_rounded,
    ),
    _BackgroundOption(
      name: 'Mint Green',
      description: 'Fresh and gentle',
      hex: '#9EF0C5',
      icon: Icons.eco_rounded,
    ),
    _BackgroundOption(
      name: 'Sunny Yellow',
      description: 'Bright and cheerful',
      hex: '#FFE680',
      icon: Icons.wb_sunny_rounded,
    ),
    _BackgroundOption(
      name: 'Lavender Purple',
      description: 'Soft and cosy',
      hex: '#CDB4FF',
      icon: Icons.auto_awesome_rounded,
    ),
    _BackgroundOption(
      name: 'Ocean Teal',
      description: 'Cool and focused',
      hex: '#7DE2D1',
      icon: Icons.water_drop_rounded,
    ),
    _BackgroundOption(
      name: 'Peach Orange',
      description: 'Warm and friendly',
      hex: '#FFBC80',
      icon: Icons.local_fire_department_rounded,
    ),
  ];

  late String _selectedHex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final currentHex = widget.child.backgroundColorHex?.toUpperCase();

    _selectedHex =
        colourOptions.any((option) => option.hex == currentHex)
            ? currentHex!
            : '#FFFFFF';
  }

  Color _colourFromHex(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Future<void> _saveColour() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.firestoreService.updateCurrentChildBackgroundColor(
        childId: widget.child.id,
        colorHex: _selectedHex,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.backgroundColourUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.backgroundColourUpdateFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColour = _colourFromHex(_selectedHex);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chooseMyBackground)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildIntroduction(),
                            const SizedBox(height: 18),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildPreview(selectedColour),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(child: _buildPalette()),
                                ],
                              )
                            else ...[
                              _buildPreview(selectedColour),
                              const SizedBox(height: 18),
                              _buildPalette(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildSaveBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.format_paint_rounded,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.makeItYours,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(context.l10n.chooseComfortableDashboardColour),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(Color selectedColour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.preview,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(minHeight: 390),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: selectedColour,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.12),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.blue.withValues(alpha: 0.16),
                    child: const Icon(
                      Icons.child_care_rounded,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      context.l10n.welcomeChild(widget.child.name),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildPreviewFeature(
                icon: Icons.schedule_rounded,
                label: context.l10n.my_schedule,
                colour: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildPreviewFeature(
                icon: Icons.star_rounded,
                label: context.l10n.my_points,
                colour: Colors.amber,
              ),
              const SizedBox(height: 12),
              _buildPreviewFeature(
                icon: Icons.color_lens_rounded,
                label: context.l10n.myZones,
                colour: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewFeature({
    required IconData icon,
    required String label,
    required Color colour,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colour.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colour.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colour),
          ),
          const SizedBox(width: 13),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.colourChoices,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (int index = 0; index < colourOptions.length; index++) ...[
          _buildColourOption(colourOptions[index]),
          if (index < colourOptions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildColourOption(_BackgroundOption option) {
    final selected = _selectedHex == option.hex;
    final colour = _colourFromHex(option.hex);

    return Card(
      margin: EdgeInsets.zero,
      elevation: selected ? 5 : 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            _isSaving
                ? null
                : () {
                  setState(() {
                    _selectedHex = option.hex;
                  });
                },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colour,
            border: Border.all(
              color:
                  selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black.withValues(alpha: 0.10),
              width: selected ? 4 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(option.icon, color: Colors.black87),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedOptionName(option),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _localizedOptionDescription(option),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveColour,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving
                      ? context.l10n.saving
                      : context.l10n.useThisBackground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedOptionName(_BackgroundOption option) => switch (option.hex) {
    '#FFFFFF' => context.l10n.backgroundClassicWhite,
    '#FFB7D5' => context.l10n.backgroundSoftRose,
    '#8FD8FF' => context.l10n.backgroundClearSky,
    '#9EF0C5' => context.l10n.backgroundFreshMint,
    '#FFE680' => context.l10n.backgroundWarmSunshine,
    '#CDB4FF' => context.l10n.backgroundSoftLavender,
    '#7DE2D1' => context.l10n.backgroundGentleGrey,
    '#FFBC80' => context.l10n.backgroundWarmPeach,
    _ => option.name,
  };

  String _localizedOptionDescription(_BackgroundOption option) => switch (option
      .hex) {
    '#FFFFFF' => context.l10n.backgroundClassicWhiteDescription,
    '#FFB7D5' => context.l10n.backgroundSoftRoseDescription,
    '#8FD8FF' => context.l10n.backgroundClearSkyDescription,
    '#9EF0C5' => context.l10n.backgroundFreshMintDescription,
    '#FFE680' => context.l10n.backgroundWarmSunshineDescription,
    '#CDB4FF' => context.l10n.backgroundSoftLavenderDescription,
    '#7DE2D1' => context.l10n.backgroundGentleGreyDescription,
    '#FFBC80' => context.l10n.backgroundWarmPeachDescription,
    _ => option.description,
  };
}

class _BackgroundOption {
  final String name;
  final String description;
  final String hex;
  final IconData icon;

  const _BackgroundOption({
    required this.name,
    required this.description,
    required this.hex,
    required this.icon,
  });
}
