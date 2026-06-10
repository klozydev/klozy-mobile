import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

const double _kScrimHeight = DSSpacing.xxxl * 2.5;

class ProductTopScrimWidget extends StatelessWidget {
  const ProductTopScrimWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kScrimHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[DSColor.surface.withOpacity(0.6), Colors.transparent],
          stops: const <double>[0.0, 1.0],
        ),
      ),
    );
  }
}
