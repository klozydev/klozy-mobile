import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';

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
          duration: const Duration(milliseconds: 200),
          width: active ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
