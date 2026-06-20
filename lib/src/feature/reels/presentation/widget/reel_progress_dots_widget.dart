import 'package:flutter/material.dart';

/// Vertical position indicator down the right edge of the reels viewer, mirroring
/// the prototype: a tall pill marks the current reel, short dashes the rest.
class ReelProgressDotsWidget extends StatelessWidget {
  final int count;
  final int current;

  const ReelProgressDotsWidget({
    super.key,
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: i == current ? 18 : 4,
            margin: const EdgeInsets.symmetric(vertical: 2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i == current
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}
