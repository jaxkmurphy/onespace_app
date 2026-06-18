import 'package:flutter/material.dart';
import '../models/child_profile.dart';
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

  bool get isChildMode => widget.childProfile != null;

  static const double circleSize = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isChildMode ? 'My Circle Time' : 'Circle Time',
        ),
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _firestoreService.getCurrentChildProfiles(),
        builder: (context, childSnapshot) {
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
      ),
    );
  }

  Widget _buildBoard({
    required List<ChildProfile> children,
    required List<StaffProfile> staff,
  }) {
    return LayoutBuilder(
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
              savedSide: children[i].circleTimeSide,
              defaultIndex: i,
              onSave: ({
                required double x,
                required double y,
                required String side,
              }) async {
                await _firestoreService.updateCurrentChildCircleTimePosition(
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
                savedSide: staff[i].circleTimeSide,
                defaultIndex: children.length + i,
                onSave: ({
                  required double x,
                  required double y,
                  required String side,
                }) async {
                  await _firestoreService.updateCurrentStaffCircleTimePosition(
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
                    color: Colors.orange.shade100,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            size: 80,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.blue.shade100,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 80,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'School',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: screenWidth / 2,
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

    final currentPosition = _localPositions[person.keyId] ?? savedPosition;

    return Positioned(
      left: currentPosition.dx,
      top: currentPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          final current = _localPositions[person.keyId] ?? savedPosition;

          final newLeft = (current.dx + details.delta.dx).clamp(
            0.0,
            screenWidth - circleSize,
          );

          final newTop = (current.dy + details.delta.dy).clamp(
            0.0,
            screenHeight - circleSize,
          );

          setState(() {
            _localPositions[person.keyId] = Offset(
              newLeft,
              newTop,
            );
          });
        },
        onPanEnd: (_) async {
          final position = _localPositions[person.keyId] ?? savedPosition;

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

          await person.onSave(
            x: normalizedX,
            y: normalizedY,
            side: side,
          );
        },
        child: Container(
          width: circleSize,
          height: circleSize,
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
          ),
          child: Center(
            child: Text(
              person.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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

    return centerX < screenWidth / 2 ? Colors.orange : Colors.blue;
  }

  Offset _getStartingPosition({
    required _CirclePerson person,
    required double screenWidth,
    required double screenHeight,
  }) {
    final savedLeft = (person.savedX * screenWidth) - (circleSize / 2);
    final savedTop = (person.savedY * screenHeight) - (circleSize / 2);

    return Offset(
      savedLeft.clamp(
        0.0,
        screenWidth - circleSize,
      ),
      savedTop.clamp(
        0.0,
        screenHeight - circleSize,
      ),
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
        (position.dx + 18).clamp(
          0.0,
          screenWidth - circleSize,
        ),
        (position.dy + 18).clamp(
          0.0,
          screenHeight - circleSize,
        ),
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
      if (person.keyId == movingKey) {
        continue;
      }

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

class _CirclePerson {
  final String keyId;
  final String name;
  final String type;
  final double savedX;
  final double savedY;
  final String savedSide;
  final int defaultIndex;

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
    required this.savedSide,
    required this.defaultIndex,
    required this.onSave,
  });
}