import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';

class FollowUserRowWidget extends StatelessWidget {
  final FollowUser user;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  const FollowUserRowWidget({
    super.key,
    required this.user,
    required this.onTap,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 23,
              backgroundColor: DSColor.lowBlack,
              backgroundImage: user.avatarUrl == null
                  ? null
                  : NetworkImage(user.avatarUrl!),
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 22, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      ),
                      if (user.isPro) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1FE0CE7D),
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.chip,
                            ),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: 8,
                              fontWeight: DSFontWeight.bold,
                              color: DSColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (user.handle.isNotEmpty)
                    Text(
                      '@${user.handle}',
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodySmall,
                        color: DSColor.onSurface45,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onToggleFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: user.isFollowing
                      ? DSColor.onSurface07
                      : DSColor.primary,
                  borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                  border: user.isFollowing
                      ? Border.all(color: DSColor.onSurface15, width: 0.5)
                      : null,
                ),
                child: Text(
                  user.isFollowing
                      ? context.l10N.profile_following
                      : context.l10N.profile_follow,
                  style: TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: DSFontWeight.semiBold,
                    color: user.isFollowing
                        ? DSColor.onSurface75
                        : DSColor.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
