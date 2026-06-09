import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';

class ProfileActionsWidget extends StatelessWidget {
  final SocialProfile profile;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onEdit;
  final VoidCallback onOrders;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  const ProfileActionsWidget({
    super.key,
    required this.profile,
    required this.onFollow,
    required this.onMessage,
    required this.onEdit,
    required this.onOrders,
    required this.onNotifications,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (profile.isMe) {
      return Row(
        children: <Widget>[
          Expanded(
            child: DSButtonOutline(
              text: context.l10N.profile_edit,
              onPressed: onEdit,
            ),
          ),
          const SizedBox(width: 10),
          _iconBtn(Icons.shopping_bag_outlined, onOrders),
          const SizedBox(width: 10),
          _iconBtn(Icons.notifications_none_rounded, onNotifications),
          const SizedBox(width: 10),
          _iconBtn(Icons.settings_outlined, onSettings),
        ],
      );
    }
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
        _iconBtn(Icons.chat_bubble_outline_rounded, onMessage),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: DSColor.onSurface07,
          borderRadius: BorderRadius.circular(DSBorderRadius.input),
          border: Border.all(color: DSColor.onSurface15, width: 0.5),
        ),
        child: Icon(icon, size: 20, color: DSColor.onSurface75),
      ),
    );
  }
}
