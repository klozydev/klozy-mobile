import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Shown while a freshly-uploaded reel's video is still transcoding on Mux
/// (API `status == PROCESSING`). The page polls until it flips to READY.
class ReelProcessingWidget extends StatelessWidget {
  const ReelProcessingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColor.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const DSLoader(),
            const SizedBox(height: DSSpacing.m),
            Text(
              context.l10N.reels_processing_video,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
