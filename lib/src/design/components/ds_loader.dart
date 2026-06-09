import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// Classic circular spinner in the brand gold. Used for page/section loading
/// states (mirrors the prototype's `k-spin` gold loader).
class DSLoader extends StatelessWidget {
  final Color? _color;
  final double _size;

  const DSLoader({super.key, Color? color, double size = 24})
    : _color = color,
      _size = size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _size,
        height: _size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_color ?? DSColor.primary),
        ),
      ),
    );
  }
}
