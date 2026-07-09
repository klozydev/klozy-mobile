import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

const double _kScrimHeight = DSSpacing.xxxl * 3;

class ProductTopScrimWidget extends StatelessWidget {
  const ProductTopScrimWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kScrimHeight,
      decoration: BoxDecoration(
        // Multi-stop, ease-out alpha ramp so the scrim melts into the photo
        // with no visible band/seam. Small opacity steps near the tail make the
        // fade-out gentle while the top plateau keeps the status bar and glass
        // controls legible over light photos.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            DSColor.surface.withValues(alpha: 0.55),
            DSColor.surface.withValues(alpha: 0.45),
            DSColor.surface.withValues(alpha: 0.30),
            DSColor.surface.withValues(alpha: 0.16),
            DSColor.surface.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.25, 0.45, 0.65, 0.82, 1.0],
        ),
      ),
    );
  }
}
