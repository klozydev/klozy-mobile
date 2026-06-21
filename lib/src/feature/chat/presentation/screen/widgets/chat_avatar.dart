import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Circular initial avatar, tinted to a per-participant colour (15% fill,
/// full-strength glyph) derived deterministically from the participant id —
/// matching the design's coloured monogram avatars.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    required this.initial,
    required this.seed,
    this.size = 48,
    this.avatarUrl,
  });

  final String initial;
  final String seed;
  final double size;
  final String? avatarUrl;

  static const List<Color> _palette = <Color>[
    DSColor.primary, // gold
    Color(0xFFC58BE0), // purple
    Color(0xFF7DC5E0), // blue
    DSColor.chatPositive, // sage
    Color(0xFFE0A57D), // amber
  ];

  Color get _tint {
    if (seed.isEmpty) return _palette.first;
    final int hash = seed.codeUnits.fold<int>(0, (int a, int c) => a + c);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final Color tint = _tint;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _monogram(tint),
        ),
      );
    }
    return _monogram(tint);
  }

  Widget _monogram(Color tint) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: dsFontFamily,
          fontWeight: DSFontWeight.bold,
          fontSize: size * 0.375,
          color: tint,
        ),
      ),
    );
  }
}
