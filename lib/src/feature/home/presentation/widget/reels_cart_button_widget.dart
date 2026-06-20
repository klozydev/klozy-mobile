import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Cart shortcut styled for the immersive Reels tab: a translucent blurred
/// circle with a white bag icon, pinned top-right over the video. Mirrors the
/// design's overlay cart (rgba(0,0,0,0.4) + blur).
class ReelsCartButtonWidget extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const ReelsCartButtonWidget({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x66000000),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x2EFFFFFF), width: 0.5),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: DSColor.primary,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: 9,
                          fontWeight: DSFontWeight.bold,
                          color: DSColor.surface,
                          height: 1,
                        ),
                      ),
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
