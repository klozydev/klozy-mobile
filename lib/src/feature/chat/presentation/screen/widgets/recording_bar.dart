import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Active-recording composer: cancel (trash), pulsing dot + elapsed timer, and
/// the stop-and-send button.
class RecordingBar extends StatefulWidget {
  const RecordingBar({
    super.key,
    required this.elapsed,
    required this.onCancel,
    required this.onStop,
  });

  /// Elapsed label, e.g. `0:07`.
  final String elapsed;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  @override
  State<RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<RecordingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColor.surface,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: widget.onCancel,
              child: const Icon(
                Icons.delete_outline,
                color: DSColor.danger,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.35).animate(_pulse),
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: DSColor.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.elapsed,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10N.chat_recording,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface45,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onStop,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: DSColor.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: DSColor.surface,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
