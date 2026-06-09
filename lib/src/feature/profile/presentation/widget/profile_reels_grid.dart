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
            borderRadius: BorderRadius.circular(DSBorderRadius.light),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (reel.thumbnailUrl == null)
                  const ColoredBox(color: DSColor.lowBlack)
                else
                  Image.network(reel.thumbnailUrl!, fit: BoxFit.cover),
                const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.visibility_outlined,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
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
