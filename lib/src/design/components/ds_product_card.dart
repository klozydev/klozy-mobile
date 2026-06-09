import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// [DSProductCard] — carte produit pour grille 2 colonnes.
///
/// Utilisée sur :
/// - Home / Feed  : [isLiked] = false (like togglable)
/// - Wishlist     : [isLiked] = true  (liked par défaut, togglable)
///
/// Structure :
///   AspectRatio(3/4) — zone image
///     ├── [image] (NetworkImage ou placeholder DSColor.lowBlack)
///     ├── [badge] optionnel — chip condition top-left (DSBorderRadius.chip)
///     └── _LikeButton — bottom-right, backdrop blur, DSColor.danger si liked
///   Padding — zone info
///     ├── title  : bodyMedium / medium / onSurface85
///     ├── meta   : bodySmall  / regular / onSurface45
///     └── price  : bodyLarge  / semiBold / onSurface
///
/// Tokens :
/// - card bg     : [DSColor.card]
/// - radius      : [DSBorderRadius.card] (18)
/// - info padding: [DSSpacing.xxs+2] h · [DSSpacing.xxs+1] top · [DSSpacing.xs-1] bottom
class DSProductCard extends StatefulWidget {
  final String title;
  final String meta;
  final String price;
  final int likes;
  final String? badge;
  final bool isLiked;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onLikeChanged;

  const DSProductCard({
    super.key,
    required this.title,
    required this.meta,
    required this.price,
    this.likes = 0,
    this.badge,
    this.isLiked = false,
    this.image,
    this.onTap,
    this.onLikeChanged,
  });

  @override
  State<DSProductCard> createState() => _DSProductCardState();
}

class _DSProductCardState extends State<DSProductCard> {
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.card),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────────────────
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.image != null)
                    Image(image: widget.image!, fit: BoxFit.cover)
                  else
                    const ColoredBox(color: DSColor.lowBlack),
                  if (widget.badge != null)
                    Positioned(
                      top: DSSpacing.xxs,
                      left: DSSpacing.xxs,
                      child: _Badge(label: widget.badge!),
                    ),
                  Positioned(
                    bottom: DSSpacing.xxs,
                    right: DSSpacing.xxs,
                    child: _LikeButton(
                      liked: _liked,
                      count: widget.likes + (_liked && !widget.isLiked ? 1 : 0),
                      onTap: () {
                        setState(() => _liked = !_liked);
                        widget.onLikeChanged?.call(_liked);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // ── Info zone ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface85,
                      height: DSFontHeight.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.meta,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                      height: DSFontHeight.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface,
                      height: DSFontHeight.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _Badge ────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xxs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(DSBorderRadius.chip),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: 9,
          fontWeight: DSFontWeight.semiBold,
          color: DSColor.onSurface75,
          letterSpacing: 0.07,
        ),
      ),
    );
  }
}

// ── _LikeButton ───────────────────────────────────────────────────────────

class _LikeButton extends StatelessWidget {
  final bool liked;
  final int count;
  final VoidCallback onTap;
  const _LikeButton({
    required this.liked,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSBorderRadius.heavy),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.xxs,
              vertical: 5,
            ),
            color: Colors.black54,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 13,
                  color: liked ? DSColor.danger : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11,
                    fontWeight: DSFontWeight.semiBold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
