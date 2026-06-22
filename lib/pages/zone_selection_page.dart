import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';
import '../l10n/zone_localizations.dart';

class ZoneSelectionPage extends StatefulWidget {
  final String? teacherUid;
  final ChildProfile child;

  const ZoneSelectionPage({super.key, this.teacherUid, required this.child});

  @override
  State<ZoneSelectionPage> createState() => _ZoneSelectionPageState();
}

class _ZoneSelectionPageState extends State<ZoneSelectionPage> {
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedZone;
  bool _isSaving = false;

  static const List<_ZoneInfo> zones = [
    _ZoneInfo(
      value: 'blue',
      name: 'Blue Zone',
      colour: Color(0xFF425DAC),
      icon: Icons.water_drop_rounded,
      description:
          'My body is running slowly. I may need rest, comfort or gentle movement.',
      feelings: ['Tired', 'Sad', 'Bored', 'Unwell', 'Slow'],
    ),
    _ZoneInfo(
      value: 'green',
      name: 'Green Zone',
      colour: Color(0xFF33975F),
      icon: Icons.eco_rounded,
      description:
          'My body feels calm and comfortable. I may feel ready to learn or play.',
      feelings: ['Calm', 'Focused', 'Happy', 'Content', 'Ready'],
    ),
    _ZoneInfo(
      value: 'yellow',
      name: 'Yellow Zone',
      colour: Color(0xFFF2D43D),
      icon: Icons.bolt_rounded,
      description:
          'My energy is rising. I may need help slowing down or finding focus.',
      feelings: ['Worried', 'Excited', 'Frustrated', 'Silly', 'Restless'],
    ),
    _ZoneInfo(
      value: 'red',
      name: 'Red Zone',
      colour: Color(0xFFC72D2C),
      icon: Icons.local_fire_department_rounded,
      description:
          'My feelings are very intense. I may need space, safety and support.',
      feelings: [
        'Angry',
        'Panicked',
        'Terrified',
        'Overwhelmed',
        'Out of control',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedZone = widget.child.zone?.toLowerCase();
  }

  Future<void> _selectZone(_ZoneInfo zone) async {
    if (_isSaving) return;

    final previousZone = _selectedZone;

    setState(() {
      _selectedZone = zone.value;
      _isSaving = true;
    });

    try {
      await _firestoreService.setCurrentChildZone(
        childId: widget.child.id,
        zone: zone.value,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.zoneSelected(
              localizedZoneName(context.l10n, zone.value),
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _selectedZone = previousZone;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.zoneUpdateFailed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.howAreYouFeeling)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIntroduction(),
                      const SizedBox(height: 20),
                      if (isWide) _buildWideLayout() else _buildNarrowLayout(),
                      const SizedBox(height: 20),
                      _buildReminder(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.helloChild(widget.child.name),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.chooseCurrentZone,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.everyZoneOkay,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildZoneCard(zones[0])),
              const SizedBox(width: 16),
              Expanded(child: _buildZoneCard(zones[1])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildZoneCard(zones[2])),
              const SizedBox(width: 16),
              Expanded(child: _buildZoneCard(zones[3])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        for (int index = 0; index < zones.length; index++) ...[
          _buildZoneCard(zones[index]),
          if (index < zones.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildZoneCard(_ZoneInfo zone) {
    final selected = _selectedZone == zone.value;

    return Semantics(
      button: true,
      selected: selected,
      label: localizedZoneName(context.l10n, zone.value),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: selected ? 7 : 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isSaving ? null : () => _selectZone(zone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: zone.colour.withValues(alpha: selected ? 0.28 : 0.14),
              border: Border.all(
                color:
                    selected
                        ? zone.colour
                        : zone.colour.withValues(alpha: 0.35),
                width: selected ? 4 : 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: zone.colour,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        zone.icon,
                        color:
                            zone.value == 'yellow'
                                ? Colors.black87
                                : Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        localizedZoneName(context.l10n, zone.value),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              zone.value == 'yellow'
                                  ? Colors.black87
                                  : zone.colour,
                        ),
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: zone.colour,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color:
                              zone.value == 'yellow'
                                  ? Colors.black87
                                  : Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  localizedZoneChildDescription(context.l10n, zone.value),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.iMightFeel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children:
                      localizedZoneFeelings(context.l10n, zone.value).map((
                        feeling,
                      ) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: zone.colour.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            feeling,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                ),
                const Spacer(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: zone.colour,
                      foregroundColor:
                          zone.value == 'yellow'
                              ? Colors.black87
                              : Colors.white,
                    ),
                    onPressed: _isSaving ? null : () => _selectZone(zone),
                    icon: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                    ),
                    label: Text(
                      selected
                          ? context.l10n.thisIsMyZone
                          : context.l10n.chooseZone(
                            localizedZoneName(context.l10n, zone.value),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminder() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              context.l10n.noBadZones,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneInfo {
  final String value;
  final String name;
  final Color colour;
  final IconData icon;
  final String description;
  final List<String> feelings;

  const _ZoneInfo({
    required this.value,
    required this.name,
    required this.colour,
    required this.icon,
    required this.description,
    required this.feelings,
  });
}
