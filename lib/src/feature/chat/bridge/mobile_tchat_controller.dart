import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/chat/bridge/user_data_mapper.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

/// Bridges the chat package's [TchatController] into mobile:
/// - user lookups resolve via mobile's REST API (not Firestore `users`)
/// - opening a thread uses mobile's auto_route-10 typed route
class MobileTchatController extends TchatController {
  const MobileTchatController();

  @override
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final profile = await locator<SocialRepository>().getProfile(userId);
      return socialProfileToChatUserMap(profile);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<void> openTchat(
    BuildContext context,
    WidgetRef ref,
    TchatModel tchat,
  ) async {
    assert(tchat.id != null, 'tchat.id required');
    ref.read(messageListProvider).init(tchat.id!);
    if (context.mounted) {
      await context.router.push(ChatThreadRoute(tchatId: tchat.id!));
    }
  }
}
