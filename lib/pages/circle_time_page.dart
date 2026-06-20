import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/circle_time_day.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class CircleTimePage extends StatefulWidget {
  final String teacherUid;
  final ChildProfile? childProfile;

  const CircleTimePage({
    super.key,
    required this.teacherUid,
    this.childProfile,
  });

  @override
  State<CircleTimePage> createState() => _CircleTimePageState();
}

class _CircleTimePageState extends State<CircleTimePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, Offset> _localPositions = {};

  bool _isSavingWeather = false;
  bool _isSavingMessage = false;

  bool get isChildMode => widget.childProfile != null;

  static const double circleSize = 90;

  static const List<_WeatherOption> weatherOptions = [
    _WeatherOption(
      value: 'sunny',
      label: 'Sunny',
      icon: Icons.wb_sunny_rounded,
      color: Colors.orange,
    ),
    _WeatherOption(
      value: 'cloudy',
      label: 'Cloudy',
      icon: Icons.cloud_rounded,
      color: Colors.blueGrey,
    ),
    _WeatherOption(
      value: 'rainy',
      label: 'Rainy',
      icon: Icons.water_drop_rounded,
      color: Colors.blue,
    ),
    _WeatherOption(
      value: 'windy',
      label: 'Windy',
      icon: Icons.air_rounded,
      color: Colors.teal,
    ),
    _WeatherOption(
      value: 'snowy',
      label: 'Snowy',
      icon: Icons.ac_unit_rounded,
      color: Colors.lightBlue,
    ),
    _WeatherOption(
      value: 'foggy',
      label: 'Foggy',
      icon: Icons.foggy,
      color: Colors.grey,
    ),
  ];

  String get _todayKey {
    final today = DateTime.now();

    return '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  String get _currentSeason {
    final month = DateTime.now().month;

    if (month == 12 || month <= 2) {
      return 'Winter';
    }

    if (month <= 5) {
      return 'Spring';
    }

    if (month <= 8) {
      return 'Summer';
    }

    return 'Autumn';
  }

  IconData get _seasonIcon {
    switch (_currentSeason) {
      case 'Winter':
        return Icons.ac_unit_rounded;
      case 'Spring':
        return Icons.local_florist_rounded;
      case 'Summer':
        return Icons.wb_sunny_rounded;
      case 'Autumn':
        return Icons.eco_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Future<void> _saveWeather(
    CircleTimeDay day,
    String weather,
  ) async {
    if (_isSavingWeather) return;

    setState(() {
      _isSavingWeather = true;
    });

    try {
      await _firestoreService.saveCurrentCircleTimeDay(
        day.copyWith(weather: weather),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save the weather: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingWeather = false;
        });
      }
    }
  }

  Future<void> _editMessage(CircleTimeDay day) async {
    final controller = TextEditingController(text: day.message);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Today’s Message'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 120,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Example: Today we are going to the library!',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || !mounted) return;

    setState(() {
      _isSavingMessage = true;
    });

    try {
      await _firestoreService.saveCurrentCircleTimeDay(
        day.copyWith(message: result),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save today’s message: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMessage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isChildMode ? 'My Circle Time' : 'Circle Time',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDailySection(),
            const SizedBox(height: 4),
            Expanded(
              child: _buildPeopleSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySection() {
    return StreamBuilder<CircleTimeDay>(
      stream: _firestoreService.getCurrentCircleTimeDay(_todayKey),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load today’s Circle Time information.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          );
        }

        final day = snapshot.data ?? CircleTimeDay(id: _todayKey);

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;

                final dateSection = _buildDateSection();
                final weatherSection = _buildWeatherSection(day);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: dateSection),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: weatherSection,
                          ),
                        ],
                      )
                    else ...[
                      dateSection,
                      const SizedBox(height: 18),
                      weatherSection,
                    ],
                    const Divider(height: 30),
                    _buildMessageSection(day),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSection() {
    final formattedDate =
        MaterialLocalizations.of(context).formatFullDate(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.calendar_today_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    _seasonIcon,
                    size: 19,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentSeason,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSection(CircleTimeDay day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is the weather like today?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (isChildMode)
          _buildSelectedWeather(day.weather)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weatherOptions.map((option) {
              final selected = day.weather == option.value;

              return ChoiceChip(
                selected: selected,
                onSelected: _isSavingWeather
                    ? null
                    : (_) => _saveWeather(day, option.value),
                avatar: Icon(
                  option.icon,
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : option.color,
                  size: 21,
                ),
                label: Text(option.label),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSelectedWeather(String weather) {
    _WeatherOption? selected;

    for (final option in weatherOptions) {
      if (option.value == weather) {
        selected = option;
        break;
      }
    }

    if (selected == null) {
      return Text(
        'The weather has not been selected yet.',
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: selected.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected.color.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected.icon,
            color: selected.color,
            size: 30,
          ),
          const SizedBox(width: 10),
          Text(
            selected.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(CircleTimeDay day) {
    final hasMessage = day.message.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.campaign_rounded,
          color: Theme.of(context).colorScheme.secondary,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today’s Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                hasMessage
                    ? day.message
                    : isChildMode
                        ? 'There is no message for today yet.'
                        : 'Add a short message or special activity for today.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        if (!isChildMode)
          IconButton(
            tooltip: hasMessage ? 'Edit message' : 'Add message',
            onPressed:
                _isSavingMessage ? null : () => _editMessage(day),
            icon: _isSavingMessage
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    hasMessage ? Icons.edit_rounded : Icons.add_rounded,
                  ),
          ),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return StreamBuilder<List<ChildProfile>>(
      stream: _firestoreService.getCurrentChildProfiles(),
      builder: (context, childSnapshot) {
        if (childSnapshot.hasError) {
          return const Center(
            child: Text('Could not load child profiles.'),
          );
        }

        if (!childSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<ChildProfile> children = childSnapshot.data!;

        if (isChildMode) {
          children = children
              .where(
                (child) => child.id == widget.childProfile!.id,
              )
              .toList();

          return _buildBoard(
            children: children,
            staff: const [],
          );
        }

        return StreamBuilder<List<StaffProfile>>(
          stream: _firestoreService.getCurrentStaffProfiles(),
          builder: (context, staffSnapshot) {
            if (staffSnapshot.hasError) {
              return const Center(
                child: Text('Could not load staff profiles.'),
              );
            }

            if (!staffSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return _buildBoard(
              children: children,
              staff: staffSnapshot.data!,
            );
          },
        );
      },
    );
  }

  Widget _buildBoard({
    required List<ChildProfile> children,
    required List<StaffProfile> staff,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final people = <_CirclePerson>[
              for (int i = 0; i < children.length; i++)
                _CirclePerson(
                  keyId: 'child_${children[i].id}',
                  name: children[i].name,
                  type: 'Child',
                  savedX: children[i].circleTimeX,
                  savedY: children[i].circleTimeY,
                  onSave: ({
                    required double x,
                    required double y,
                    required String side,
                  }) async {
                    await _firestoreService
                        .updateCurrentChildCircleTimePosition(
                      childId: children[i].id,
                      x: x,
                      y: y,
                      side: side,
                    );
                  },
                ),
              if (!isChildMode)
                for (int i = 0; i < staff.length; i++)
                  _CirclePerson(
                    keyId: 'staff_${staff[i].id}',
                    name: staff[i].name,
                    type: 'Staff',
                    savedX: staff[i].circleTimeX,
                    savedY: staff[i].circleTimeY,
                    onSave: ({
                      required double x,
                      required double y,
                      required String side,
                    }) async {
                      await _firestoreService
                          .updateCurrentStaffCircleTimePosition(
                        staffId: staff[i].id,
                        x: x,
                        y: y,
                        side: side,
                      );
                    },
                  ),
            ];

            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFFE0B2),
                        child: _buildBoardSide(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFBBDEFB),
                        child: _buildBoardSide(
                          icon: Icons.school_rounded,
                          label: 'School',
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: (screenWidth / 2) - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.black26,
                  ),
                ),
                for (final person in people)
                  _buildCircle(
                    person: person,
                    people: people,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardSide({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Center(
      child: Opacity(
        opacity: 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 70,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle({
    required _CirclePerson person,
    required List<_CirclePerson> people,
    required double screenWidth,
    required double screenHeight,
  }) {
    final savedPosition = _getStartingPosition(
      person: person,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );

    final currentPosition =
        _localPositions[person.keyId] ?? savedPosition;

    return Positioned(
      left: currentPosition.dx,
      top: currentPosition.dy,
      child: Semantics(
        label: '${person.name}, ${person.type}',
        child: GestureDetector(
          onPanUpdate: (details) {
            final current =
                _localPositions[person.keyId] ?? savedPosition;

            final maxLeft = math.max(
              0.0,
              screenWidth - circleSize,
            );

            final maxTop = math.max(
              0.0,
              screenHeight - circleSize,
            );

            final newLeft = (current.dx + details.delta.dx).clamp(
              0.0,
              maxLeft,
            );

            final newTop = (current.dy + details.delta.dy).clamp(
              0.0,
              maxTop,
            );

            setState(() {
              _localPositions[person.keyId] = Offset(
                newLeft,
                newTop,
              );
            });
          },
          onPanEnd: (_) async {
            final position =
                _localPositions[person.keyId] ?? savedPosition;

            final adjusted = _findNearestFreePosition(
              movingKey: person.keyId,
              startPosition: position,
              people: people,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );

            setState(() {
              _localPositions[person.keyId] = adjusted;
            });

            final centerX = adjusted.dx + (circleSize / 2);
            final centerY = adjusted.dy + (circleSize / 2);

            final normalizedX = centerX / screenWidth;
            final normalizedY = centerY / screenHeight;
            final side = normalizedX < 0.5 ? 'home' : 'school';

            try {
              await person.onSave(
                x: normalizedX,
                y: normalizedY,
                side: side,
              );
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Could not save ${person.name}’s position.',
                  ),
                ),
              );
            }
          },
          child: Container(
            width: circleSize,
            height: circleSize,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: person.type == 'Staff'
                  ? Colors.purple
                  : _getChildCircleColor(
                      currentPosition,
                      screenWidth,
                    ),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                person.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getChildCircleColor(
    Offset position,
    double screenWidth,
  ) {
    final centerX = position.dx + (circleSize / 2);

    return centerX < screenWidth / 2
        ? const Color(0xFFEF6C00)
        : const Color(0xFF1976D2);
  }

  Offset _getStartingPosition({
    required _CirclePerson person,
    required double screenWidth,
    required double screenHeight,
  }) {
    final maxLeft = math.max(0.0, screenWidth - circleSize);
    final maxTop = math.max(0.0, screenHeight - circleSize);

    final savedLeft =
        (person.savedX * screenWidth) - (circleSize / 2);

    final savedTop =
        (person.savedY * screenHeight) - (circleSize / 2);

    return Offset(
      savedLeft.clamp(0.0, maxLeft),
      savedTop.clamp(0.0, maxTop),
    );
  }

  Offset _findNearestFreePosition({
    required String movingKey,
    required Offset startPosition,
    required List<_CirclePerson> people,
    required double screenWidth,
    required double screenHeight,
  }) {
    Offset position = startPosition;

    final maxLeft = math.max(0.0, screenWidth - circleSize);
    final maxTop = math.max(0.0, screenHeight - circleSize);

    for (int i = 0; i < 20; i++) {
      if (!_wouldOverlap(
        movingKey: movingKey,
        newPosition: position,
        people: people,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      )) {
        return position;
      }

      position = Offset(
        (position.dx + 18).clamp(0.0, maxLeft),
        (position.dy + 18).clamp(0.0, maxTop),
      );
    }

    return position;
  }

  bool _wouldOverlap({
    required String movingKey,
    required Offset newPosition,
    required List<_CirclePerson> people,
    required double screenWidth,
    required double screenHeight,
  }) {
    final newRect = Rect.fromLTWH(
      newPosition.dx,
      newPosition.dy,
      circleSize,
      circleSize,
    );

    for (final person in people) {
      if (person.keyId == movingKey) continue;

      final otherPosition = _localPositions[person.keyId] ??
          _getStartingPosition(
            person: person,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          );

      final otherRect = Rect.fromLTWH(
        otherPosition.dx,
        otherPosition.dy,
        circleSize,
        circleSize,
      );

      if (newRect.overlaps(otherRect)) {
        return true;
      }
    }

    return false;
  }
}

class _WeatherOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _WeatherOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CirclePerson {
  final String keyId;
  final String name;
  final String type;
  final double savedX;
  final double savedY;

  final Future<void> Function({
    required double x,
    required double y,
    required String side,
  }) onSave;

  const _CirclePerson({
    required this.keyId,
    required this.name,
    required this.type,
    required this.savedX,
    required this.savedY,
    required this.onSave,
  });
}