/// In-memory cache of participant display data embedded in each thread doc
/// (`tchat.usersData`). The thread-list query returns every doc in one shot, so
/// populating this from those docs lets the client resolve all participant
/// names/avatars with zero per-user reads — instant, no one-by-one loading.
class EmbeddedUserCache {
  EmbeddedUserCache._();

  static final Map<String, Map<String, dynamic>> _data =
      <String, Map<String, dynamic>>{};

  /// Merge a thread doc's `usersData` map ({ id/uid: {display fields} }).
  static void putAll(Object? usersData) {
    if (usersData is! Map) return;
    usersData.forEach((Object? key, Object? value) {
      if (key is String && value is Map) {
        _data[key] = Map<String, dynamic>.from(value);
      }
    });
  }

  /// Display data for a participant, or null if no thread embedded it.
  static Map<String, dynamic>? get(String id) => _data[id];

  static void clear() => _data.clear();
}
