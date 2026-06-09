import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Tappable 1–5 star selector.
class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 38,
                color: i <= rating ? DSColor.primary : DSColor.onSurface32,
              ),
            ),
          ),
      ],
    );
  }
}
