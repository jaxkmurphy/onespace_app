import 'package:flutter/material.dart';
import '../l10n/body_check_localizations.dart';
import '../l10n/l10n.dart';

enum BodyMapView { front, back }

class BodyMapSelector extends StatefulWidget {
  final String? selectedBodyPart;
  final ValueChanged<String> onBodyPartSelected;
  final bool enabled;

  const BodyMapSelector({
    super.key,
    required this.selectedBodyPart,
    required this.onBodyPartSelected,
    this.enabled = true,
  });

  @override
  State<BodyMapSelector> createState() => _BodyMapSelectorState();
}

class _BodyMapSelectorState extends State<BodyMapSelector> {
  BodyMapView _view = BodyMapView.front;

  static const List<_BodyRegion> regions = [
    // Front
    _BodyRegion(
      label: 'Head',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.37, 0.02, 0.26, 0.16),
    ),
    _BodyRegion(
      label: 'Throat',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.42, 0.17, 0.16, 0.08),
    ),
    _BodyRegion(
      label: 'Chest',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.32, 0.23, 0.36, 0.18),
    ),
    _BodyRegion(
      label: 'Tummy',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.35, 0.40, 0.30, 0.16),
    ),
    _BodyRegion(
      label: 'Left arm',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.16, 0.22, 0.20, 0.35),
    ),
    _BodyRegion(
      label: 'Right arm',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.64, 0.22, 0.20, 0.35),
    ),
    _BodyRegion(
      label: 'Left hand',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.07, 0.54, 0.20, 0.14),
    ),
    _BodyRegion(
      label: 'Right hand',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.73, 0.54, 0.20, 0.14),
    ),
    _BodyRegion(
      label: 'Left leg',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.30, 0.54, 0.21, 0.35),
    ),
    _BodyRegion(
      label: 'Right leg',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.49, 0.54, 0.21, 0.35),
    ),
    _BodyRegion(
      label: 'Left foot',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.25, 0.87, 0.25, 0.12),
    ),
    _BodyRegion(
      label: 'Right foot',
      view: BodyMapView.front,
      rect: Rect.fromLTWH(0.50, 0.87, 0.25, 0.12),
    ),

    // Back
    _BodyRegion(
      label: 'Back of head',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.37, 0.02, 0.26, 0.16),
    ),
    _BodyRegion(
      label: 'Neck',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.42, 0.17, 0.16, 0.08),
    ),
    _BodyRegion(
      label: 'Upper back',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.32, 0.23, 0.36, 0.20),
    ),
    _BodyRegion(
      label: 'Lower back',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.35, 0.42, 0.30, 0.14),
    ),
    _BodyRegion(
      label: 'Left arm',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.16, 0.22, 0.20, 0.35),
    ),
    _BodyRegion(
      label: 'Right arm',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.64, 0.22, 0.20, 0.35),
    ),
    _BodyRegion(
      label: 'Left hand',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.07, 0.54, 0.20, 0.14),
    ),
    _BodyRegion(
      label: 'Right hand',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.73, 0.54, 0.20, 0.14),
    ),
    _BodyRegion(
      label: 'Left leg',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.30, 0.54, 0.21, 0.35),
    ),
    _BodyRegion(
      label: 'Right leg',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.49, 0.54, 0.21, 0.35),
    ),
    _BodyRegion(
      label: 'Left foot',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.25, 0.87, 0.25, 0.12),
    ),
    _BodyRegion(
      label: 'Right foot',
      view: BodyMapView.back,
      rect: Rect.fromLTWH(0.50, 0.87, 0.25, 0.12),
    ),
  ];

  List<_BodyRegion> get _visibleRegions {
    return regions.where((region) => region.view == _view).toList();
  }

  void _handleTap(TapDownDetails details, Size size) {
    if (!widget.enabled || size.width <= 0 || size.height <= 0) {
      return;
    }

    final normalisedPosition = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    for (final region in _visibleRegions.reversed) {
      if (region.rect.contains(normalisedPosition)) {
        widget.onBodyPartSelected(region.label);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<BodyMapView>(
          segments: [
            ButtonSegment(
              value: BodyMapView.front,
              icon: const Icon(Icons.accessibility_new_rounded),
              label: Text(context.l10n.bodyMapFront),
            ),
            ButtonSegment(
              value: BodyMapView.back,
              icon: const Icon(Icons.accessibility_rounded),
              label: Text(context.l10n.bodyMapBack),
            ),
          ],
          selected: {_view},
          onSelectionChanged:
              widget.enabled
                  ? (selection) {
                    setState(() {
                      _view = selection.first;
                    });
                  }
                  : null,
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colourScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: colourScheme.outlineVariant, width: 2),
            ),
            child: AspectRatio(
              aspectRatio: 0.62,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return Semantics(
                    label: context.l10n.bodyDiagramSemantics(
                      _view == BodyMapView.front
                          ? context.l10n.bodyMapFront
                          : context.l10n.bodyMapBack,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown:
                          widget.enabled
                              ? (details) => _handleTap(details, size)
                              : null,
                      child: CustomPaint(
                        painter: _BodyPainter(
                          view: _view,
                          selectedBodyPart: widget.selectedBodyPart,
                          regions: _visibleRegions,
                          bodyColour: colourScheme.primaryContainer,
                          outlineColour: colourScheme.onPrimaryContainer,
                          highlightColour: colourScheme.error,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child:
              widget.selectedBodyPart == null
                  ? Container(
                    key: const ValueKey('nothing-selected'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colourScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_rounded),
                        const SizedBox(width: 11),
                        Expanded(child: Text(context.l10n.tapSoreBodyPart)),
                      ],
                    ),
                  )
                  : Container(
                    key: ValueKey(widget.selectedBodyPart),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colourScheme.errorContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colourScheme.error),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: colourScheme.error,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            context.l10n.bodyPartSelected(
                              localizedBodyPart(
                                context.l10n,
                                widget.selectedBodyPart!,
                              ),
                            ),
                            style: TextStyle(
                              color: colourScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            context.l10n.chooseBodyPartList,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          leading: const Icon(Icons.list_alt_rounded),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _visibleRegions.map((region) {
                      final selected = widget.selectedBodyPart == region.label;

                      return ChoiceChip(
                        selected: selected,
                        label: Text(
                          localizedBodyPart(context.l10n, region.label),
                        ),
                        onSelected:
                            widget.enabled
                                ? (_) {
                                  widget.onBodyPartSelected(region.label);
                                }
                                : null,
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BodyRegion {
  final String label;
  final BodyMapView view;
  final Rect rect;

  const _BodyRegion({
    required this.label,
    required this.view,
    required this.rect,
  });
}

class _BodyPainter extends CustomPainter {
  final BodyMapView view;
  final String? selectedBodyPart;
  final List<_BodyRegion> regions;
  final Color bodyColour;
  final Color outlineColour;
  final Color highlightColour;

  const _BodyPainter({
    required this.view,
    required this.selectedBodyPart,
    required this.regions,
    required this.bodyColour,
    required this.outlineColour,
    required this.highlightColour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final bodyPaint =
        Paint()
          ..color = bodyColour
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = outlineColour.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

    final limbPaint =
        Paint()
          ..color = bodyColour
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.115
          ..strokeCap = StrokeCap.round;

    final limbOutlinePaint =
        Paint()
          ..color = outlineColour.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (width * 0.115) + 4
          ..strokeCap = StrokeCap.round;

    // Arms
    final leftShoulder = Offset(width * 0.37, height * 0.26);
    final leftElbow = Offset(width * 0.25, height * 0.47);
    final leftHand = Offset(width * 0.17, height * 0.64);

    final rightShoulder = Offset(width * 0.63, height * 0.26);
    final rightElbow = Offset(width * 0.75, height * 0.47);
    final rightHand = Offset(width * 0.83, height * 0.64);

    _drawLimb(
      canvas,
      [leftShoulder, leftElbow, leftHand],
      limbOutlinePaint,
      limbPaint,
    );

    _drawLimb(
      canvas,
      [rightShoulder, rightElbow, rightHand],
      limbOutlinePaint,
      limbPaint,
    );

    // Legs
    final leftHip = Offset(width * 0.44, height * 0.52);
    final leftKnee = Offset(width * 0.40, height * 0.73);
    final leftFoot = Offset(width * 0.36, height * 0.94);

    final rightHip = Offset(width * 0.56, height * 0.52);
    final rightKnee = Offset(width * 0.60, height * 0.73);
    final rightFoot = Offset(width * 0.64, height * 0.94);

    _drawLimb(
      canvas,
      [leftHip, leftKnee, leftFoot],
      limbOutlinePaint,
      limbPaint,
    );

    _drawLimb(
      canvas,
      [rightHip, rightKnee, rightFoot],
      limbOutlinePaint,
      limbPaint,
    );

    // Torso
    final torsoPath =
        Path()
          ..moveTo(width * 0.37, height * 0.22)
          ..quadraticBezierTo(
            width * 0.50,
            height * 0.19,
            width * 0.63,
            height * 0.22,
          )
          ..lineTo(width * 0.61, height * 0.50)
          ..quadraticBezierTo(
            width * 0.50,
            height * 0.56,
            width * 0.39,
            height * 0.50,
          )
          ..close();

    canvas.drawPath(torsoPath, bodyPaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Neck
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.44, height * 0.15, width * 0.12, height * 0.10),
      const Radius.circular(12),
    );

    canvas.drawRRect(neckRect, bodyPaint);
    canvas.drawRRect(neckRect, outlinePaint);

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 0.50, height * 0.10),
        width: width * 0.23,
        height: height * 0.15,
      ),
      bodyPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 0.50, height * 0.10),
        width: width * 0.23,
        height: height * 0.15,
      ),
      outlinePaint,
    );

    _drawBodyDetails(canvas, size, outlinePaint);

    _drawSelectedRegion(canvas, size);
  }

  void _drawLimb(
    Canvas canvas,
    List<Offset> points,
    Paint outlinePaint,
    Paint bodyPaint,
  ) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, bodyPaint);
  }

  void _drawBodyDetails(Canvas canvas, Size size, Paint detailPaint) {
    final width = size.width;
    final height = size.height;

    final softerPaint =
        Paint()
          ..color = detailPaint.color.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    if (view == BodyMapView.front) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(width * 0.50, height * 0.34),
          width: width * 0.18,
          height: height * 0.08,
        ),
        0,
        3.14,
        false,
        softerPaint,
      );

      canvas.drawCircle(
        Offset(width * 0.50, height * 0.46),
        width * 0.012,
        softerPaint,
      );
    } else {
      canvas.drawLine(
        Offset(width * 0.50, height * 0.24),
        Offset(width * 0.50, height * 0.51),
        softerPaint,
      );

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(width * 0.50, height * 0.31),
          width: width * 0.25,
          height: height * 0.10,
        ),
        0,
        3.14,
        false,
        softerPaint,
      );
    }
  }

  void _drawSelectedRegion(Canvas canvas, Size size) {
    if (selectedBodyPart == null) return;

    _BodyRegion? selectedRegion;

    for (final region in regions) {
      if (region.label == selectedBodyPart) {
        selectedRegion = region;
        break;
      }
    }

    if (selectedRegion == null) return;

    final rect = Rect.fromLTWH(
      selectedRegion.rect.left * size.width,
      selectedRegion.rect.top * size.height,
      selectedRegion.rect.width * size.width,
      selectedRegion.rect.height * size.height,
    );

    final highlightPaint =
        Paint()
          ..color = highlightColour.withValues(alpha: 0.32)
          ..style = PaintingStyle.fill;

    final highlightOutline =
        Paint()
          ..color = highlightColour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final highlight = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    canvas.drawRRect(highlight, highlightPaint);
    canvas.drawRRect(highlight, highlightOutline);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) {
    return oldDelegate.view != view ||
        oldDelegate.selectedBodyPart != selectedBodyPart ||
        oldDelegate.bodyColour != bodyColour ||
        oldDelegate.outlineColour != outlineColour ||
        oldDelegate.highlightColour != highlightColour;
  }
}
