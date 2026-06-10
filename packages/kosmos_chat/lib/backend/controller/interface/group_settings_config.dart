import 'dart:async';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/cupertino.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

abstract class GroupConfigInterface {
  const GroupConfigInterface();

  FutureOr<void> onGroupImageClick(
      TchatModel tchat, BuildContext context, WidgetRef ref) {
    throw UnimplementedError();
  }

  FutureOr<void> reportGroupMember(
    BuildContext context,
    WidgetRef ref,
    String tchatId,
    String userId,
  ) {
    throw UnimplementedError();
  }

  FutureOr<void> addUserToGroup(
    BuildContext context,
    WidgetRef ref,
    TchatModel tchat,
  ) {
    throw UnimplementedError();
  }

  FutureOr<void> onGroupNameClick(
      TchatModel tchat, BuildContext context, WidgetRef ref) {
    throw UnimplementedError();
  }

  FutureOr<void> actionDeleteUserFromGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
    SocialUser user,
  ) {
    throw UnimplementedError();
  }

  FutureOr<void> actionMoreEventGroupSettings(
    BuildContext context,
    WidgetRef ref,
    String salonId,
    SocialUser user,
    bool isAdmin,
    bool isBlocked,
    bool isMute,
  ) {
    throw UnimplementedError();
  }

  FutureOr<void> leaveGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
  ) {
    throw UnimplementedError();
  }

  FutureOr<void> deleteMyGroup(
    BuildContext context,
    WidgetRef ref,
    String salonId,
  ) {
    throw UnimplementedError();
  }
}
