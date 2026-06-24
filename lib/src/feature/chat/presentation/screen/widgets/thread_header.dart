import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_avatar.dart';
import 'package:klozy/src/router/app_router.dart';

/// Thread screen header: back chevron, participant avatar + name (+ real rating
/// subtitle, never a faked presence string), and the overflow menu.
class ThreadHeader extends StatelessWidget {
  const ThreadHeader({
    super.key,
    required this.other,
    required this.onBack,
    required this.onMenu,
  });

  final ChatParticipant other;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  void _openProfile(BuildContext context) =>
      context.router.push(UserProfileRoute(userId: other.id));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColor.chatHeaderBackground,
        border: Border(
          bottom: BorderSide(color: DSColor.onSurface08, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.chevron_left,
                  color: DSColor.onSurface,
                  size: 28,
                ),
                splashRadius: 22,
              ),
              GestureDetector(
                onTap: () => _openProfile(context),
                child: ChatAvatar(
                  initial: other.initial,
                  seed: other.id,
                  avatarUrl: other.avatarUrl,
                  size: 34,
                ),
              ),
              const SizedBox(width: 10),
              // Tapping the name / avatar opens the participant's public profile.
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openProfile(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        other.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: DSColor.onSurface,
                        ),
                      ),
                      if (other.rating > 0)
                        Text(
                          '★ ${other.rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodySmall,
                            color: DSColor.chatPositive,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onMenu,
                icon: const Icon(
                  Icons.more_horiz,
                  color: DSColor.onSurface,
                  size: 22,
                ),
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
