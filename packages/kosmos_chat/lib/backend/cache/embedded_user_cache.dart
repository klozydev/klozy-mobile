import 'package:cloud_firestore/cloud_firestore.dart';

/// In-memory cache of participant display data for the chat. Two sources feed it,
/// both avoiding any per-row REST/Firestore round-trip at render time:
///  1. `tchat.usersData` embedded in each thread doc (written by the backend) —
///     the thread-list query returns it for free.
///  2. a single batched read of `chat_users/{id}` for every participant, done
///     once when the thread snapshot arrives (covers threads written before the
///     embedded data existed).
/// Either way the rows resolve names/avatars from memory — all at once, instant.
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

  /// Display data for a participant, or null if nothing has populated it.
  static Map<String, dynamic>? get(String id) => _data[id];

  static bool has(String id) => _data.containsKey(id);

  static void clear() => _data.clear();

  /// Batch-read `chat_users/{id}` for [ids] not already cached, in one round of
  /// `whereIn` queries (chunked at 10, Firestore's limit). This is what makes
  /// the thread list resolve every participant together instead of one by one.
  static Future<void> prefetchFromChatUsers(Iterable<String> ids) async {
    final List<String> missing = <String>[
      for (final String id in ids)
        if (id.isNotEmpty && !_data.containsKey(id)) id,
    ];
    if (missing.isEmpty) return;

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final List<Future<void>> reads = <Future<void>>[];
    for (int i = 0; i < missing.length; i += 10) {
      final List<String> chunk = missing.sublist(
        i,
        i + 10 > missing.length ? missing.length : i + 10,
      );
      reads.add(
        db
            .collection('chat_users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get()
            .then((QuerySnapshot<Map<String, dynamic>> snap) {
              for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                  in snap.docs) {
                _data[doc.id] = doc.data();
              }
            })
            .catchError((Object _) {}),
      );
    }
    await Future.wait(reads);
  }
}
