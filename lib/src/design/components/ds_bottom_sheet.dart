import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Klozy modal bottom sheet panel: popup surface, 24px top corners, drag handle,
/// optional title + close. Use [DSBottomSheet.show] to present it. Mirrors the
/// prototype `Sheet`.
class DSBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  const DSBottomSheet({super.key, this.title, required this.child});

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      builder: (_) => DSBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      decoration: const BoxDecoration(
        color: DSColor.popupBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: DSColor.onSurface12, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: DSColor.onSurface15,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.titleLarge,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: DSColor.onSurface45,
                    ),
                  ),
                ],
              ),
            ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                28 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
