import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Horizontal thumbnail strip shown at top of the Recap step.
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
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return GestureDetector(
              onTap: onEditTapped,
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: DSColor.card,
                  borderRadius: BorderRadius.circular(DSBorderRadius.image),
                  border: Border.all(color: DSColor.primary),
                ),
                child: const Center(
                  child: Icon(Icons.edit, color: DSColor.primary),
                ),
              ),
            );
          }
          final path = photoPaths[index - 1];
          // Defensive: callers normally pass local file paths, but fall back
          // to a network render when only uploaded URLs are available.
          final bool isRemote =
              path.startsWith('http://') || path.startsWith('https://');
          return Container(
            width: 72,
            margin: const EdgeInsets.only(left: DSSpacing.xxs),
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
