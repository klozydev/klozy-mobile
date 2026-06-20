import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_set_composition_view.dart';
import 'package:klozy/src/design/components/ds_set_piece.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// One row of [DSSetComposition]: thumbnail (or placeholder) + name/sub + a
/// status tag (Photo ✓ / Add CTA / No photo).
class DSSetCompositionPieceRow extends StatelessWidget {
  final DSSetPiece piece;
  final DSSetCompositionView view;
  final Color accentColor;
  final bool showDivider;
  final VoidCallback? onAddPhoto;

  const DSSetCompositionPieceRow({
    super.key,
    required this.piece,
    required this.view,
    required this.accentColor,
    required this.showDivider,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xxs),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(color: DSColor.onSurface07, width: 0.5),
              ),
            )
          : null,
      child: Row(
        children: <Widget>[
          _thumbnail(),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  piece.name,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 13.5,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.onSurface85,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  piece.subLabel,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11.5,
                    color: DSColor.onSurface35,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.xxs),
          _statusTag(context),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    if (piece.photo != null) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DSColor.onSurface10, width: 0.5),
          image: DecorationImage(image: piece.photo!, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: DSColor.onSurface07,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DSColor.onSurface15, width: 1),
      ),
      child: Icon(
        view == DSSetCompositionView.owner
            ? Icons.add_rounded
            : Icons.image_not_supported_outlined,
        size: 16,
        color: DSColor.onSurface35,
      ),
    );
  }

  Widget _statusTag(BuildContext context) {
    if (piece.photo != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_rounded, size: 13, color: accentColor),
          const SizedBox(width: 4),
          Text(
            context.l10N.ds_set_composition_photo,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 11,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      );
    }
    if (view == DSSetCompositionView.owner) {
      return GestureDetector(
        onTap: onAddPhoto,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.camera_alt_outlined,
                size: 12,
                color: DSColor.surface,
              ),
              const SizedBox(width: 5),
              Text(
                context.l10N.ds_set_composition_add,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: 11,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.surface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Text(
      context.l10N.ds_set_composition_no_photo,
      style: const TextStyle(
        fontFamily: dsFontFamily,
        fontSize: 11,
        color: DSColor.onSurface24,
      ),
    );
  }
}
