import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between a Firestore [Timestamp] and a Dart [DateTime].
///
/// Reads tolerate the legacy shapes the old chat wrote: native [Timestamp],
/// raw millisecond `int`, or `null`. Writes produce a native [Timestamp] so
/// documents stay byte-compatible with the existing data + backend mirror.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
