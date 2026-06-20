import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ZoneOverviewPage extends StatelessWidget {
  final String? teacherUid;

  const ZoneOverviewPage({
    super.key,
    this.teacherUid,
  });

  static const List<_ZoneDisplay> zones = [
    _ZoneDisplay(
      value: 'blue',
      name: 'Blue Zone',
      colour: Color(0xFF425DAC),
      icon: Icons.water_drop_rounded,
      description: 'Low energy, tired, sad or unwell.',
    ),
    _ZoneDisplay(
      value: 'green',
      name: 'Green Zone',
      colour: Color(0xFF33975F),
      icon: Icons.eco_rounded,
      description: 'Calm, focused, comfortable and ready.',
    ),
    _ZoneDisplay(
      value: 'yellow',
      name: 'Yellow Zone',
      colour: Color(0xFFF2D43D),
      icon: Icons.bolt_rounded,
      description: 'Worried, excited, frustrated or restless.',
    ),
    _ZoneDisplay(
      value: 'red',
      name: 'Red Zone',
      colour: Color(0xFFC72D2C),
      icon: Icons.local_fire_department_rounded,
      description: 'Very intense feelings requiring support.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones Overview'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChildProfile>>(
          stream: firestoreService.getCurrentChildProfiles(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load classroom zones.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final children = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context, children),
                          const SizedBox(height: 20),
                          if (children.isEmpty)
                            _buildEmptyClassroom(context)
                          else if (isWide)
                            _buildWideLayout(context, children)
                          else
                            _buildNarrowLayout(context, children),
                          if (children.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _buildUnselectedSection(context, children),
                          ],
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

  Widget _buildHeader(
    BuildContext context,
    List<ChildProfile> children,
  ) {
    final selectedCount = children.where((child) {
      final zone = child.zone?.trim() ?? '';
      return zone.isNotEmpty;
    }).length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            final title = Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 34,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classroom Zones',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A live view of how children are feeling.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            );

            final totals = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStat(
                  context,
                  label: 'Children',
                  value: children.length.toString(),
                  icon: Icons.child_care_rounded,
                ),
                const SizedBox(width: 10),
                _buildStat(
                  context,
                  label: 'Checked in',
                  value: selectedCount.toString(),
                  icon: Icons.check_circle_rounded,
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 20),
                  totals,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: 18),
                totals,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      flex: 0,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 110,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    List<ChildProfile> children,
  ) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildZoneCard(
                  context,
                  zones[0],
                  children,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildZoneCard(
                  context,
                  zones[1],
                  children,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildZoneCard(
                  context,
                  zones[2],
                  children,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildZoneCard(
                  context,
                  zones[3],
                  children,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<ChildProfile> children,
  ) {
    return Column(
      children: [
        for (int index = 0; index < zones.length; index++) ...[
          _buildZoneCard(
            context,
            zones[index],
            children,
          ),
          if (index < zones.length - 1)
            const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildZoneCard(
    BuildContext context,
    _ZoneDisplay zone,
    List<ChildProfile> allChildren,
  ) {
    final children = allChildren.where((child) {
      return child.zone?.toLowerCase() == zone.value;
    }).toList()
      ..sort(
        (first, second) => first.name.compareTo(second.name),
      );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: zone.colour.withValues(alpha: 0.15),
          border: Border.all(
            color: zone.colour.withValues(alpha: 0.45),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: zone.colour,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    zone.icon,
                    color: zone.value == 'yellow'
                        ? Colors.black87
                        : Colors.white,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        zone.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 42,
                    minHeight: 42,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: zone.colour,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    children.length.toString(),
                    style: TextStyle(
                      color: zone.value == 'yellow'
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (children.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'No children are currently in this zone.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: children.map((child) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: zone.colour,
                      foregroundColor: zone.value == 'yellow'
                          ? Colors.black87
                          : Colors.white,
                      child: Text(
                        child.name.isEmpty
                            ? '?'
                            : child.name[0].toUpperCase(),
                      ),
                    ),
                    label: Text(
                      child.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnselectedSection(
    BuildContext context,
    List<ChildProfile> children,
  ) {
    final unselected = children.where((child) {
      final zone = child.zone?.trim() ?? '';

      return !zones.any(
        (item) => item.value == zone.toLowerCase(),
      );
    }).toList()
      ..sort(
        (first, second) => first.name.compareTo(second.name),
      );

    if (unselected.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Every child has completed their zone check-in.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  'Not checked in',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unselected.map((child) {
                return Chip(
                  avatar: const CircleAvatar(
                    child: Icon(
                      Icons.person_rounded,
                      size: 17,
                    ),
                  ),
                  label: Text(child.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyClassroom(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 54,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No child profiles found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a child profile before using the Zones Overview.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneDisplay {
  final String value;
  final String name;
  final Color colour;
  final IconData icon;
  final String description;

  const _ZoneDisplay({
    required this.value,
    required this.name,
    required this.colour,
    required this.icon,
    required this.description,
  });
}