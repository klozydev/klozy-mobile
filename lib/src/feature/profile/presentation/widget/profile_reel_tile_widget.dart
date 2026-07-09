import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';

/// Single reel tile: thumbnail, bottom gradient scrim, play badge and view
/// count. Shared card visuals used by [ProfileReelsSliverGrid] inside a
/// sliver grid.
class ProfileReelTileWidget extends StatelessWidget {
  final ProfileReel reel;
  final VoidCallback onTap;

  const ProfileReelTileWidget({
    super.key,
    required this.reel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSBorderRadius.cardSmall),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DSNetworkImage(
              imageUrl: reel.thumbnailUrl,
              borderRadius: DSBorderRadius.cardSmall,
              // Missing or broken/expired Mux thumbnail (404) → neutral tile.
              fallback: const ColoredBox(color: DSColor.lowBlack),
            ),
            // Bottom gradient scrim.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: <double>[0.55, 1],
                  colors: <Color>[Colors.transparent, Color(0x99000000)],
                ),
              ),
            ),
            // Top-right play badge.
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0x66000000),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            // Bottom-left view count.
            Positioned(
              left: 8,
              bottom: 7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: 11,
                    color: Color(0xD9FFFFFF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reel.views}',
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 10,
                      fontWeight: DSFontWeight.semiBold,
                      color: Colors.white,
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
