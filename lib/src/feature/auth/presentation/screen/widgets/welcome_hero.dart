import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/auth/presentation/screen/widgets/diagonal_stripes_painter.dart';

/// Full-bleed editorial hero for the welcome screen. Mirrors the prototype:
/// a placeholder fashion shot faded into black, with the brand gold glow.
/// (Real photo asset pending — the placeholder fill stands in for it.)
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Placeholder editorial shot: dark diagonal-gradient fill + hairlines.
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[Color(0xFF1A1A1F), Color(0xFF101013)],
            ),
            border: Border.fromBorderSide(
              BorderSide(color: DSColor.onSurface08, width: 0.5),
            ),
          ),
          child: CustomPaint(
            painter: const DiagonalStripesPainter(color: DSColor.onSurface05),
            child: Center(
              child: Text(
                context.l10N.auth_hero_placeholder,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: DSColor.onSurface35,
                ),
              ),
            ),
          ),
        ),
        // Bottom-weighted black scrim so the foreground text stays legible.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x73000000),
                Color(0x8C000000),
                Color(0xE6000000),
                Color(0xFF000000),
              ],
              stops: <double>[0.0, 0.42, 0.74, 1.0],
            ),
          ),
        ),
        // Subtle gold glow centered on the brand block.
        Align(
          alignment: const Alignment(0, -0.32),
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[Color(0x22E0CE7D), Color(0x00E0CE7D)],
                stops: <double>[0.0, 0.65],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
