import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// AI marker — the gold sparkle used to flag AI-suggested fields/content.
/// Ports the prototype `KSparkle`.
class DSSparkle extends StatelessWidget {
  final double size;
  final Color color;

  const DSSparkle({super.key, this.size = 14, this.color = DSColor.primary});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome, size: size, color: color);
  }
}
