import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

class ProfileReelsGrid extends StatelessWidget {
  final List<ProfileReel> reels;
  final ValueChanged<ProfileReel> onTap;

  const ProfileReelsGrid({super.key, required this.reels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) {
      return ProfileTabEmpty(
        icon: Icons.movie_outlined,
        label: context.l10N.profile_no_reels,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 9 / 16,
      ),
      itemCount: reels.length,
      itemBuilder: (BuildContext context, int i) {
        final ProfileReel reel = reels[i];
        return GestureDetector(
          onTap: () => onTap(reel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSBorderRadius.cardSmall),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (reel.thumbnailUrl == null)
                  const ColoredBox(color: DSColor.lowBlack)
                else
                  Image.network(reel.thumbnailUrl!, fit: BoxFit.cover),
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
      },
    );
  }
}
