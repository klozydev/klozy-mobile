import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Static voice-note waveform with a progress underline.
///
/// Bar heights are derived deterministically from the bar index so the
/// waveform stays stable across rebuilds. The [progress] underline spans a
/// fraction of the full width in [accent].
class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    super.key,
    required this.barCount,
    required this.progress,
    required this.barColor,
    required this.accent,
  });

  final int barCount;
  final double progress;
  final Color barColor;
  final Color accent;

  double _barHeight(int i) {
    final double base =
        4 + (math.sin(i * 1.7 + 0.6).abs() * 13).roundToDouble();
    return base + (i % 4);
  }

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: 22,
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(barCount, (int i) {
              return Padding(
                padding: EdgeInsets.only(right: i == barCount - 1 ? 0 : 2),
                child: Container(
                  width: 2.5,
                  height: _barHeight(i),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: Container(height: 2, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
