import 'dart:async';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kosmos_chat/backend/controller/status_controller.dart';
import 'package:kosmos_chat/backend/model/tchat_status/tchat_status_model.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

final statusProvider = ChangeNotifierProvider<StatusProvider>((ref) {
  return StatusProvider(ref);
});

class StatusProvider with ChangeNotifier {
  List<TchatStatusModel> _statusList = [];
  List<TchatStatusModel> get statusList => _statusList;

  StreamSubscription? _statusSubscription;

  Ref _ref;

  StatusProvider(this._ref);

  void init() async {
    if (_statusSubscription != null) {
      await _statusSubscription!.cancel();
    }
    _statusList = [];

    _statusSubscription = FirebaseDatabase.instance
        .ref("tchat/status")
        .onValue
        .listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      final Map<String, dynamic> data = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      for (final item in data.keys) {
        if ((_ref
                    .read(tchatListProvider(
                        FirebaseAuth.instance.currentUser!.uid))
                    .tchatList ??
                [])
            .where((element) => element.id == item)
            .isEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          if (FirebaseAuth.instance.currentUser?.uid == null ||
              _ref
                      .read(tchatListProvider(
                          FirebaseAuth.instance.currentUser!.uid))
                      .tchatList ==
                  null) continue;
        }
        if (_statusList.where((element) => element.tchatId == item).isEmpty) {
          _statusList.add(TchatStatusModel(tchatId: item, status: []));
        }
        TchatStatusModel tchatStatus =
            _statusList.firstWhere((element) => element.tchatId == item);
        final List<TchatUserStatusModel> tmp = List.from([]);
        for (final i in (data[item] ?? {}).keys) {
          Map<String, dynamic>? maps = (data[item][i] as Map<Object?, Object?>)
              .map<String, dynamic>(
                  (key, value) => MapEntry(key.toString(), value as dynamic));
          if (maps["status"] == null) {
            continue;
          }
          tmp.add(TchatUserStatusModel(
            userId: i,
            status: stringToEnum(TchatingStatus.values, maps["status"])!,
            lastUpdate:
                DateTime.fromMillisecondsSinceEpoch(maps["lastUpdate"] as int),
          ));
        }
        tchatStatus = tchatStatus.copyWith(status: tmp);
        _statusList[_statusList
            .indexWhere((element) => element.tchatId == item)] = tchatStatus;
      }
      notifyListeners();
    });
  }

  TchatUserStatusModel? getTchatingStatus(String tchatId,
      [bool isGroup = false]) {
    final TchatStatusModel? tchatStatus =
        _statusList.firstWhereOrNull((element) => element.tchatId == tchatId);
    final Iterable<TchatUserStatusModel>? userStatus = tchatStatus?.status
        .where((element) =>
            element.userId != FirebaseAuth.instance.currentUser!.uid);

    final TchatUserStatusModel? t = userStatus?.firstWhereOrNull((element) =>
        element.status != TchatingStatus.offline &&
        element.status != TchatingStatus.online);
    if (t != null) {
      return t;
    } else {
      if (isGroup &&
          (userStatus
                      ?.where(
                          (element) => element.status == TchatingStatus.online)
                      .length ??
                  0) >
              1) {
        return TchatUserStatusModel(
          userId: (userStatus
                      ?.where(
                          (element) => element.status == TchatingStatus.online)
                      .length ??
                  2)
              .toString(),
          status: TchatingStatus.multipleOnline,
        );
      }
      return (userStatus?.isEmpty ?? true) ? null : userStatus!.first;
    }
  }
}
