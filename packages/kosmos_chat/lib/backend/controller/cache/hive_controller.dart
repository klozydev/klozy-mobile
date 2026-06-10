import 'package:core_kosmos/core_kosmos.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/model/adaptater/media_model.g.dart';
import 'package:kosmos_chat/backend/model/adaptater/message_model.g.dart';
import 'package:kosmos_chat/backend/model/adaptater/tchat_model.g.dart';
import 'package:kosmos_chat/backend/model/adaptater/timestamp.g.dart';
import 'package:path_provider/path_provider.dart';

final CachedTchatController<TchatModel> backendCacheControllerTchat =
    CachedTchatController<TchatModel>();
final CachedTchatController<SocialUser> backendCacheControllerUser =
    CachedTchatController<SocialUser>();
final CachedTchatController<MessageModel> backendCacheControllerMessage =
    CachedTchatController<MessageModel>();

class CachedTchatController<T> {
  Box? _hive;

  void close() async {
    await Hive.close();
    await _hive?.close();
  }

  Future<void> init(String boxName) async {
    await Hive.initFlutter();
    // ignore: invalid_use_of_visible_for_testing_member
    Hive.resetAdapters();

    Hive.registerAdapter(TimestampAdapter());
    Hive.registerAdapter(TchatModelAdapter());
    Hive.registerAdapter(MessageModelAdapter());
    Hive.registerAdapter(MediaModelAdapter());

    final path = (await getApplicationDocumentsDirectory()).path;

    _hive = await Hive.openBox(boxName, path: path);

    printInfo("Hive $boxName status : ${_hive?.isOpen}");
  }

  /// Permet de sauvegarder un tchat dans le cache
  Future<void> save(
      T value, String id, Map<String, dynamic> Function() toJson) async {
    await _hive?.put(id, toJson());
  }

  /// Permet de récupérer tous les tchats du cache
  /// et de preload les données.
  /// Une fois que le stream prendra la main, les données
  /// seront automatiquement mise à jour dans le
  /// provider via les [T.id].
  Future<List<T>> load(T Function(Map<String, dynamic>, String) fromJson,
      [List<String>? neededKeys]) async {
    final List<T> ret = [];

    final hiveKeys = _hive?.keys ?? [];
    final keys = neededKeys != null
        ? hiveKeys.where((element) => neededKeys.contains(element))
        : hiveKeys;

    for (final key in keys) {
      final value = await _hive?.get(key);
      ret.add(fromJson(Map.from(value), key));
    }

    return ret;
  }

  Future<List<T>> loadIf(T Function(Map<String, dynamic>, String) fromJson,
      bool Function(Map<String, dynamic>) verifier,
      [List<String>? neededKeys]) async {
    final List<T> ret = [];

    final hiveKeys = _hive?.keys ?? [];
    final keys = neededKeys != null
        ? hiveKeys.where((element) => neededKeys.contains(element))
        : hiveKeys;

    for (final key in keys) {
      final value = await _hive?.get(key);
      if (verifier(Map.from(value))) ret.add(fromJson(Map.from(value), key));
    }

    return ret;
  }

  /// Permet de supprimer un tchat du cache
  Future<void> delete(String tchatId) async {
    await _hive?.delete(tchatId);
  }

  /// Permet de supprimer tous les tchats du cache
  Future<void> deleteAll() async {
    await _hive?.clear();
  }
}
