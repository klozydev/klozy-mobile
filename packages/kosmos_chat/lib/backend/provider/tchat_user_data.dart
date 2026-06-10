import 'package:flutter/material.dart';
import 'package:core_kosmos/core_kosmos.dart';

import 'package:kosmos_chat/backend/controller/cache/hive_controller.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';

final tchatUserListProvider = ChangeNotifierProvider<TchatUserData>((ref) {
  return TchatUserData();
});

class TchatUserData with ChangeNotifier {
  final List<String> _userId = [];
  List<SocialUser> userList = [];
  List<String> _cachedUserId = [];

  late final Future<Map<String, dynamic>> Function(String) _fetchUserData;

  TchatUserData() {
    _fetchUserData = getTchatBackEndConfig().tchatInterface.getUserData;
  }

  Future<void> loadUserData(String userId) async {
    final data = await _fetchUserData(userId);
    final userData =
        SocialUser.fromJson({...data, "id": ""}).copyWith(id: userId);
    userList.add(userData);
    await backendCacheControllerUser.save(userData, userId, userData.toJson);
  }

  Future<void> addUserToList(String userId) async {
    if (_userId.contains(userId) && !_cachedUserId.contains(userId)) {
      printWarning("User $userId already loaded, ingore it");
      return;
    }
    _cachedUserId.removeWhere((e) => e == userId);
    _userId.add(userId);
    await loadUserData(userId);
    notifyListeners();
  }

  void clear([bool notify = true]) {
    _userId.clear();
    userList.clear();
    if (notify) notifyListeners();
  }

  SocialUser? getById(String userId) =>
      userList.firstWhereOrNull((element) => element.id == userId);

  Future<void> initCache(List<String> userIds) async {
    _cachedUserId = List.from(userIds);
    userList = List.from(await backendCacheControllerUser.load(
        (data, id) => SocialUser.fromJson(data).copyWith(id: id), userIds));
    notifyListeners();
  }
}
