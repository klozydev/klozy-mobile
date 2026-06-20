import 'package:flutter/widgets.dart';

/// One piece of a multi-item set (e.g. the jersey + shorts of a kit).
/// A null [photo] means the piece was not photographed.
class DSSetPiece {
  final String name;
  final String subLabel;
  final ImageProvider? photo;

  const DSSetPiece({required this.name, required this.subLabel, this.photo});
}
