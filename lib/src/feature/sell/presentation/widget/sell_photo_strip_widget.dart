import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_dashed_rounded_border_painter.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Horizontal thumbnail strip shown at the top of the Recap step: the photos
/// first (cover highlighted), then a trailing dashed "Edit" tile.
class SellPhotoStripWidget extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback onEditTapped;

  const SellPhotoStripWidget({
    super.key,
    required this.photoPaths,
    required this.onEditTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length + 1,
        itemBuilder: (BuildContext context, int index) {
          // Trailing edit tile.
          if (index == photoPaths.length) {
            return GestureDetector(
              onTap: onEditTapped,
              child: Container(
                width: 64,
                margin: const EdgeInsets.only(left: DSSpacing.xxs),
                child: CustomPaint(
                  painter: const DSDashedRoundedBorderPainter(
                    color: DSColor.onSurface24,
                    radius: DSBorderRadius.image,
                    strokeWidth: 1.5,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: DSColor.onSurface05,
                      borderRadius: BorderRadius.circular(DSBorderRadius.image),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: DSColor.onSurface60,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10N.sell_photo_edit,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: 10,
                            fontWeight: DSFontWeight.medium,
                            color: DSColor.onSurface45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final String path = photoPaths[index];
          final bool isRemote = path.startsWith('http');
          final bool isCover = index == 0;
          return Container(
            width: 64,
            margin: EdgeInsets.only(left: index == 0 ? 0 : DSSpacing.xxs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSBorderRadius.image),
              border: Border.all(
                color: isCover ? DSColor.primary : DSColor.onSurface10,
                width: isCover ? 1.5 : 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DSBorderRadius.image),
              child: isRemote
                  ? Image.network(path, fit: BoxFit.cover)
                  : Image.file(File(path), fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}
