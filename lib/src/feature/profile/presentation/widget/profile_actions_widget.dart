import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';

/// Public-profile action row: Follow / Following pill + message button.
///
/// The self profile has no action row — its bag / bell / gear live in the
/// app bar (matching the final design).
class ProfileActionsWidget extends StatelessWidget {
  final SocialProfile profile;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const ProfileActionsWidget({
    super.key,
    required this.profile,
    required this.onFollow,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: profile.isFollowing
              ? DSButtonOutline(
                  text: context.l10N.profile_following,
                  onPressed: onFollow,
                )
              : DSButtonElevated(
                  text: context.l10N.profile_follow,
                  onPressed: onFollow,
                ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onMessage,
          child: Container(
            width: 52,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(DSBorderRadius.input),
              border: Border.all(color: DSColor.onSurface24, width: 0.5),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 20,
              color: DSColor.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
