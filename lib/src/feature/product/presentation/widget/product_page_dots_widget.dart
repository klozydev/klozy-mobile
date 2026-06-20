import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

class ProductPageDotsWidget extends StatelessWidget {
  const ProductPageDotsWidget({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: active ? 22 : 6,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            color: active
                ? DSColor.primary
                : Colors.white.withValues(alpha: 0.32),
          ),
        );
      }),
    );
  }
}
