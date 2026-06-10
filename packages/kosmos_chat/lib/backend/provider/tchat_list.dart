import 'dart:async';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/provider/status.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';

import 'package:path_provider/path_provider.dart';

import '../utils/utils.dart';

final tchatListProvider =
    ChangeNotifierProvider.family<TchatListProvider, String>((ref, uid) {
  return TchatListProvider(ref, uid);
});

class TchatListProvider with ChangeNotifier {
  StreamSubscription? _subscription;

  Map<String, TchatModel>? _tchatList;
  List<TchatModel>? get tchatList {
    if (_tchatList == null) return null;
    List<TchatModel> _ = [..._tchatList!.values];
    _.sort((a, b) => b.lastMessageSentAt == null && a.lastMessageSentAt == null
        ? 0
        : b.lastMessageSentAt == null && a.lastMessageSentAt != null
            ? -1
            : b.lastMessageSentAt != null && a.lastMessageSentAt == null
                ? 1
                : b.lastMessageSentAt!.compareTo(a.lastMessageSentAt!));

    return _;
  }

  late TchatBackEndConfig _backEndConfig;

  late final Ref _ref;
  late final String uid;

  bool isInit = false;

  String? appPath;

  StreamSubscription<User?>? _authStateChanges;

  TchatListProvider(this._ref, this.uid) {
    _backEndConfig = getTchatBackEndConfig();

    _authStateChanges =
        FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null && !isInit) {
        init();
      } else {
        clear();
      }
    });
  }

  Future<void> init() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    _subscription?.cancel();

    appPath = (await getApplicationDocumentsDirectory()).path;


    /// Load all tchat in cache
    List<TchatModel> preloadTchat =
        List.from(await backendCacheControllerTchat.load((data, id) {
      return TchatModel.fromJson(data).copyWith(id: id);
    }));
    // tchatList to Map
    _tchatList = {for (var e in preloadTchat) "${e.id}": e};
    notifyListeners();

    /// Get all user id in cache and init list with data
    List<String> userIds = [];
    for (final TchatModel item in (_tchatList?.values ?? [])) {
      userIds.addAll(item.participants);
    }
    notifyListeners();

    /// Init status stream
    _ref.read(statusProvider).init();

    await _ref.read(tchatUserListProvider).initCache(userIds);

    /// Refresh Ui
    notifyListeners();

    /// Load server Data.
    _subscription = _backEndConfig.tchatInterface.streamTchatList(
      _tchatList!,
      _ref.read(tchatUserListProvider).addUserToList,
      notifyListeners,
      backendCacheControllerTchat,
    );
  }

  void clear([bool notify = true]) {
    isInit = false;
    _tchatList?.clear();
    _tchatList = null;
    _subscription?.cancel();
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _authStateChanges?.cancel();
    _authStateChanges = null;
    super.dispose();
  }

  void removeTchat(String s) {
    _tchatList?.remove(s);
    notifyListeners();
  }

  bool hasUnseenMessage() {
    for (final TchatModel item in (_tchatList?.values ?? [])) {
      final r = item.lastMessageSeenBy
          .doesNotContain(FirebaseAuth.instance.currentUser!.uid);
      if (r) return true;
    }
    return false;
  }
}
