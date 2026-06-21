import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Process-wide, in-memory (per-session) cache of GET responses. Holds nothing
/// across app restarts and never touches disk. Entries are grouped so a feature
/// can drop all of its cached responses on a related mutation.
///
/// Only requests explicitly marked cacheable (see [cacheable]) are stored, so
/// transactional / always-fresh endpoints are never accidentally cached.
@lazySingleton
class SessionCache {
  final Map<String, Response<dynamic>> _store = <String, Response<dynamic>>{};
  final Map<String, Set<String>> _groups = <String, Set<String>>{};

  Response<dynamic>? get(String key) => _store[key];

  void put(String key, Response<dynamic> response, {String? group}) {
    _store[key] = response;
    if (group != null) {
      (_groups[group] ??= <String>{}).add(key);
    }
  }

  /// Drops every cached response in [group] (e.g. after a product is edited).
  void invalidateGroup(String group) {
    final Set<String>? keys = _groups.remove(group);
    if (keys == null) return;
    for (final String key in keys) {
      _store.remove(key);
    }
  }

  /// Wipes everything — call on sign-out so the next user starts clean.
  void clear() {
    _store.clear();
    _groups.clear();
  }
}

/// Request extra keys read by the cache interceptor.
const String kCacheFlag = 'session_cache';
const String kCacheGroup = 'session_cache_group';

/// Marks a GET request as cacheable for the current session, tagged with
/// [group] so it can be invalidated together with related reads.
Options cacheable(String group) =>
    Options(extra: <String, dynamic>{kCacheFlag: true, kCacheGroup: group});
