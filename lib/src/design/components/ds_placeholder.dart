import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_diagonal_hatch_painter.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Imagery placeholder — a dark diagonal-gradient fill with faint hatch lines
/// and an optional mono label. Ports the prototype `Placeholder`.
class DSPlaceholder extends StatelessWidget {
  final String? label;
  final double radius;
  final bool accent;

  const DSPlaceholder({
    super.key,
    this.label,
    this.radius = DSBorderRadius.image,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: accent
                ? const <Color>[Color(0xFF1A1710), Color(0xFF0E0D09)]
                : const <Color>[Color(0xFF1A1A1F), Color(0xFF101013)],
          ),
          border: Border.all(color: DSColor.onSurface08, width: 0.5),
        ),
        child: CustomPaint(
          painter: DSDiagonalHatchPainter(
            color: accent ? const Color(0x0FE0CE7D) : DSColor.onSurface05,
          ),
          child: Center(
            child: label == null || label!.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      label!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 0.4,
                        color: accent
                            ? const Color(0x80E0CE7D)
                            : DSColor.onSurface35,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
